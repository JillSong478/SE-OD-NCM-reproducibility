clear; clc;

%% =========================================================
% 1. 数据文件夹
% ==========================================================
dataFolder = 'D:\Pilocarpine\Pilocarpine\Pilocarpine - GFP';   % 改成你的实际路径

% 保存截取数据的文件夹
outFolder = fullfile(dataFolder, 'Extracted_30s');

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end


%% =========================================================
% 2. 11只 GFP-Blue 动物及对应的 SE onset latency
% ==========================================================

animalID = { ...
    'M1L'
    'M1R'
    'M3L'
    'M4L'
    'M4R'
    'M5L'
    'M5R'
    'M9L'
    'M9R'
    'M10L'
    'M10R'
    };

% latency to SE，单位：s
tSE = [ ...
    500
    548
    337
    405
    1727
    466
    350
    293
    648
    308
    665
    ];


%% =========================================================
% 3. 截取参数
% ==========================================================

segmentDuration = 30;      % 每段30 s

% onset:
% tSE ~ tSE + 30 s

% continuous:
% tSE + 300 s ~ tSE + 330 s
continuousOffset = 200;    % SE onset 后5 min


%% =========================================================
% 4. 逐只动物处理
% ==========================================================

for n = 1:length(animalID)

    ID = animalID{n};

    fprintf('\n=====================================\n');
    fprintf('Processing %s\n', ID);
    fprintf('=====================================\n');

    %% -----------------------------------------------------
    % 找对应 EDF 文件
    % 使用通配符，避免 Blue/blue、大写小写等文件名差异
    % ------------------------------------------------------

    files = dir(fullfile(dataFolder, ...
        [ID, '*GFP*Blue*.edf']));

    % 如果上面没找到，再尝试小写
    if isempty(files)
        files = dir(fullfile(dataFolder, ...
            [ID, '*GFP*blue*.edf']));
    end

    if isempty(files)
        warning('找不到 %s 的 EDF 文件，跳过。', ID);
        continue;
    end

    if length(files) > 1
        warning('%s 找到多个 EDF 文件，默认使用第一个。', ID);
    end

    edfFile = fullfile(files(1).folder, files(1).name);

    fprintf('EDF file: %s\n', files(1).name);


    %% -----------------------------------------------------
    % 读取 EDF
    % ------------------------------------------------------

    info = edfinfo(edfFile);
    TT   = edfread(edfFile);

    % EDF中的信号名称
    labels = string(info.SignalLabels);

    % 每个 data record 的持续时间
    recordDuration = seconds(info.DataRecordDuration);

    % 每个通道的采样率
    fs = double(info.NumSamples) ./ recordDuration;

    nChannels = length(labels);

    fprintf('Number of channels: %d\n', nChannels);

    fprintf('Sampling rate(s): ');
    fprintf('%.1f ', unique(fs));
    fprintf('Hz\n');


    %% -----------------------------------------------------
    % 将 EDF 每个 record 中的数据拼接为连续信号
    % ------------------------------------------------------

    signals = cell(nChannels,1);

    for ch = 1:nChannels

        tmp = TT{:,ch};

        if iscell(tmp)
            % EDF通常每一行是一个data record
            signals{ch} = vertcat(tmp{:});
        else
            signals{ch} = tmp(:);
        end

        signals{ch} = double(signals{ch}(:));

    end


    %% =====================================================
    % 5. ONSET STAGE
    % =====================================================

    onsetStart = tSE(n);

    onset = extract_segment( ...
        signals, ...
        fs, ...
        labels, ...
        onsetStart, ...
        segmentDuration);


    % 添加基本信息
    onset.animalID       = ID;
    onset.stage          = 'onset';
    onset.tSE            = tSE(n);
    onset.startTime      = onsetStart;
    onset.duration       = segmentDuration;
    onset.sourceFile     = files(1).name;


    %% 保存 onset

    saveName = fullfile(outFolder, ...
        [ID, '_onset_30s.mat']);

    save(saveName, 'onset', '-v7.3');

    fprintf('Saved onset: %.1f - %.1f s\n', ...
        onsetStart, onsetStart + segmentDuration);


    %% =====================================================
    % 6. CONTINUOUS STAGE
    % =====================================================

    continuousStart = tSE(n) + continuousOffset;

    continuous = extract_segment( ...
        signals, ...
        fs, ...
        labels, ...
        continuousStart, ...
        segmentDuration);


    continuous.animalID   = ID;
    continuous.stage      = 'continuous';
    continuous.tSE        = tSE(n);
    continuous.startTime  = continuousStart;
    continuous.duration   = segmentDuration;
    continuous.sourceFile = files(1).name;


    %% 保存 continuous

    saveName = fullfile(outFolder, ...
        [ID, '_continuous_30s.mat']);

    save(saveName, 'continuous', '-v7.3');

    fprintf('Saved continuous: %.1f - %.1f s\n', ...
        continuousStart, continuousStart + segmentDuration);

end


fprintf('\n=====================================\n');
fprintf('All finished.\n');
fprintf('Saved in:\n%s\n', outFolder);
fprintf('=====================================\n');



%% =========================================================
% 局部函数：从所有通道中截取指定时间段
% ==========================================================
function segment = extract_segment(signals, fs, labels, ...
                                   startTime, duration)

nChannels = length(signals);

segment.labels  = labels;
segment.fs      = fs;
segment.signals = cell(nChannels,1);

for ch = 1:nChannels

    fs_ch = fs(ch);

    % 起始索引
    idx1 = floor(startTime * fs_ch) + 1;

    % 精确取 duration 秒
    nSamples = round(duration * fs_ch);

    idx2 = idx1 + nSamples - 1;

    % 检查是否超出数据长度
    if idx1 < 1 || idx2 > length(signals{ch})

        warning(['Channel %d (%s): requested %.1f-%.1f s ', ...
                 'exceeds recording duration.'], ...
                 ch, labels(ch), ...
                 startTime, startTime + duration);

        segment.signals{ch} = [];

    else

        segment.signals{ch} = ...
            signals{ch}(idx1:idx2);

    end

end

end