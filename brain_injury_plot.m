% 已知变量：
% HI_plot_1, HI_plot_2, HI_plot_3   % 每个大小应为 length(tau_vals) × length(Obath_vals)
% tau_vals
% Obath_vals
HI_plot_1 = importdata('HI_plot_095_seed1.mat');
HI_plot_2 = importdata('HI_plot_08_seed1.mat');
HI_plot_3 = importdata('HI_plot_3.mat');



figure;
set(gcf, 'Units', 'normalized', 'Position', [0.18 0.08 0.55 0.82]);

% 三个图统一颜色范围
cmin = min([HI_plot_1(:); HI_plot_2(:); HI_plot_3(:)]);
cmax = max([HI_plot_1(:); HI_plot_2(:); HI_plot_3(:)]);

tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

% ---------- Panel 1 ----------
nexttile;
imagesc(Obath_vals, tau_vals, HI_plot_1);
axis xy;
caxis([cmin cmax]);
colormap(parula);
ylabel('\tau_{KCC2} (ms)');
title('k = 0.95', 'FontWeight', 'normal');
set(gca, 'FontSize', 12, 'LineWidth', 1.1);
set(gca, 'XTickLabel', []);   % 前两个panel不显示横坐标数字

% ---------- Panel 2 ----------
nexttile;
imagesc(Obath_vals, tau_vals, HI_plot_2);
axis xy;
caxis([cmin cmax]);
ylabel('\tau_{KCC2} (ms)');
title('k = 0.8', 'FontWeight', 'normal');
set(gca, 'FontSize', 12, 'LineWidth', 1.1);
set(gca, 'XTickLabel', []);

% ---------- Panel 3 ----------
nexttile;
imagesc(Obath_vals, tau_vals, HI_plot_3);
axis xy;
caxis([cmin cmax]);
ylabel('\tau_{KCC2} (ms)');
xlabel('[O_2]_{bath}');
title('k = 0.7', 'FontWeight', 'normal');
set(gca, 'FontSize', 12, 'LineWidth', 1.1);

% ---------- 共用 colorbar ----------
cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = 'log_{10}(HI + 1)';
cb.FontSize = 12;