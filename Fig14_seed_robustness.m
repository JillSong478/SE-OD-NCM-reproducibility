
clear; clc;

% 按实际文件名修改
k_vals = [0.7 0.8 0.95];
k_tags = {'07','08','095'};
seedList = 1:3;

Results = [];

for ik = 1:length(k_vals)

    X = [];

    for s = seedList

        filename = sprintf('HI_plot_%s_seed%d.mat', ...
            k_tags{ik}, s);

        A = load(filename);

        % 使用与Fig.14一致的log10(HI+1)
        if isfield(A,'HI_map')
            H = log10(A.HI_map + 1);
        elseif isfield(A,'HI_plot')
            H = A.HI_plot;
        else
            error('%s 中找不到HI_map或HI_plot',filename);
        end

        H = H(:);

        if ~isempty(X)
            assert(length(H)==size(X,1), ...
                '不同随机种子的矩阵尺寸不一致');
        end

        X(:,end+1) = H;
    end

    % 1. 三个种子的两两相关系数
    R = corrcoef(X);

    idx = triu(true(length(seedList)),1);
    r = R(idx);

    % 2. 每个参数点的随机波动
    pixelSD = std(X,0,2);
    meanSD = mean(pixelSD);

    % 3. 零/非零HI区域一致性
    % HI_plot = log10(HI+1)，零对应HI=0
    B = X > log10(1+1e-8);

    agreement = 100 * mean(all(B == B(:,1),2));

    fprintf('\nk = %.2f\n',k_vals(ik));
    fprintf('Pairwise Pearson r: ');
    fprintf('%.4f ',r);
    fprintf('\n');

    fprintf('Mean pointwise SD = %.4f\n',meanSD);
    fprintf('Zero/nonzero agreement = %.2f%%\n',agreement);

    Results = [Results;
        k_vals(ik), min(r), max(r), meanSD, agreement];

end

T = array2table(Results, ...
    'VariableNames',{'k','r_min','r_max', ...
    'MeanLogSD','RegionAgreement_percent'});

disp(T);
writetable(T,'Fig14_seed_robustness_summary.csv');
