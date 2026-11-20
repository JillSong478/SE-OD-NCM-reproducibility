function [state_id, metrics, debug] = classify_Vp_state(Vp, dt, t_discard)
% Classify Vp dynamics into four regimes:
% 1 = Background
% 2 = Intermittent epileptiform spikes
% 3 = Continuous SE-like activity
% 4 = Depolarization block-like state

    %% ===== classification thresholds =====
    spike_thr = -50;        % mV, spike detection threshold
    prom_thr  = 8;          % mV, minimum spike prominence
    min_dist  = 0.12;       % s, minimum inter-spike distance

    spike_rate_bg   = 0.2;  % Hz
    spike_rate_cont = 1.0;  % Hz
    max_isi_cont    = 3.0;  % s

    depol_mean_thr = -50;   % mV
    depol_std_thr  = 3;     % mV

    %% ===== remove transient =====
    fs = 1000/dt;  % Hz, because dt is in ms
    idx0 = round(t_discard * fs) + 1;
    idx0 = max(1, min(idx0, length(Vp)));

    V_raw = Vp(idx0:end);

    %% ===== downsample for faster classification =====
    fs_target = 500;  % Hz
    ds = max(1, round(fs/fs_target));

    V = downsample(V_raw, ds);
    fs_c = fs / ds;

    T = length(V) / fs_c;
    t = (0:length(V)-1)/fs_c + t_discard;   % absolute time axis after discard

    %% ===== basic voltage metrics =====
    V_mean = mean(V);
    V_std  = std(V);
    V_p2p  = max(V) - min(V);

    %% ===== depolarization block detection =====
    n_last = max(10, round(0.2 * length(V)));
    idx_last_start = length(V) - n_last + 1;

    V_last = V(idx_last_start:end);

    last_mean = mean(V_last);
    last_std  = std(V_last);

    is_depol_block = (last_mean > depol_mean_thr) && (last_std < depol_std_thr);

    %% ===== spike detection =====
    try
        [pks, locs_rel] = findpeaks(V, fs_c, ...
            'MinPeakHeight', spike_thr, ...
            'MinPeakProminence', prom_thr, ...
            'MinPeakDistance', min_dist);
    catch
        [pks, loc_idx] = findpeaks(V, ...
            'MinPeakHeight', spike_thr, ...
            'MinPeakProminence', prom_thr, ...
            'MinPeakDistance', round(min_dist*fs_c));
        locs_rel = (loc_idx - 1) / fs_c;
    end

    locs_abs = locs_rel + t_discard;   % absolute time

    n_spikes = length(pks);
    spike_rate = n_spikes / T;

    if n_spikes >= 2
        isi = diff(locs_abs);
        max_isi = max(isi);
        mean_isi = mean(isi);
        cv_isi = std(isi) / mean_isi;
    else
        isi = [];
        max_isi = Inf;
        mean_isi = Inf;
        cv_isi = Inf;
    end

    discharge_burden = mean(V > spike_thr);

    %% ===== four-state classification =====
    if is_depol_block
        state_id = 4;
        state_name = 'Depolarization block-like';

    elseif spike_rate < spike_rate_bg && V_p2p < 15
        state_id = 1;
        state_name = 'Background';

    elseif spike_rate >= spike_rate_cont && max_isi <= max_isi_cont
        state_id = 3;
        state_name = 'Continuous SE-like';

    elseif n_spikes > 0
        state_id = 2;
        state_name = 'Intermittent spikes';

    else
        state_id = 1;
        state_name = 'Background';
    end

    %% ===== output metrics =====
    metrics.V_mean = V_mean;
    metrics.V_std = V_std;
    metrics.V_p2p = V_p2p;
    metrics.last_mean = last_mean;
    metrics.last_std = last_std;
    metrics.n_spikes = n_spikes;
    metrics.spike_rate = spike_rate;
    metrics.max_isi = max_isi;
    metrics.mean_isi = mean_isi;
    metrics.cv_isi = cv_isi;
    metrics.discharge_burden = discharge_burden;
    metrics.state_name = state_name;

    %% ===== debug output for visualization =====
    debug.t = t;
    debug.V = V;
    debug.fs_c = fs_c;
    debug.pks = pks;
    debug.locs_abs = locs_abs;
    debug.spike_thr = spike_thr;
    debug.prom_thr = prom_thr;
    debug.min_dist = min_dist;
    debug.t_discard = t_discard;
    debug.last_window_start = t(idx_last_start);
    debug.last_window_end = t(end);
    debug.depol_mean_thr = depol_mean_thr;
    debug.depol_std_thr = depol_std_thr;
    debug.spike_rate_bg = spike_rate_bg;
    debug.spike_rate_cont = spike_rate_cont;
    debug.max_isi_cont = max_isi_cont;
end