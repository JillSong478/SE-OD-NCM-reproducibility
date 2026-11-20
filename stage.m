%% ===== Three-stage summary figure =====
% Onset: 20 s
% Continuous: 80 s
% Convalescence: 30 s

clearvars -except Vp_plot_1 Vp_plot_2 Vp_plot_3 O2_plot_1 O2_plot_2 O2_plot_3 HI_t_1 HI_t_2 HI_t_3

Thr = 24;   % brain injury threshold

T1 = 20;    % onset duration
T2 = 80;    % continuous duration
T3 = 30;    % convalescence duration

%% ===== Load data =====
Vp_plot_1 = importdata('Vp_plot_1.mat');
Vp_plot_2 = importdata('Vp_plot_2.mat');
Vp_plot_3 = importdata('Vp_plot_3.mat');

O2_plot_1 = importdata('O2_plot_1.mat');
O2_plot_2 = importdata('O2_plot_2.mat');
O2_plot_3 = importdata('O2_plot_3.mat');

HI_t_1 = importdata('HI_t.mat');
HI_t_2 = importdata('HI_t_2.mat');
HI_t_3 = importdata('HI_t_3.mat');

%% ===== Make row vectors =====
Vp_plot_1 = Vp_plot_1(:)';
Vp_plot_2 = Vp_plot_2(:)';
Vp_plot_3 = Vp_plot_3(:)';

O2_plot_1 = O2_plot_1(:)';
O2_plot_2 = O2_plot_2(:)';
O2_plot_3 = O2_plot_3(:)';

HI_t_1 = HI_t_1(:)';
HI_t_2 = HI_t_2(:)';
HI_t_3 = HI_t_3(:)';

%% ===== Concatenate signals =====
Vp_all = [Vp_plot_1, Vp_plot_2, Vp_plot_3];
O2_all = [O2_plot_1, O2_plot_2, O2_plot_3];

% If HI_t_1, HI_t_2, HI_t_3 each start from zero, add offsets
HI_all = [ ...
    HI_t_1, ...
    HI_t_2 + HI_t_1(end), ...
    HI_t_3 + HI_t_1(end) + HI_t_2(end) ...
];

%% ===== Construct time axes for unequal durations =====
N1 = length(Vp_plot_1);
N2 = length(Vp_plot_2);
N3 = length(Vp_plot_3);

t1 = linspace(0, T1, N1);
t2 = linspace(T1, T1+T2, N2);
t3 = linspace(T1+T2, T1+T2+T3, N3);

time_all = [t1, t2, t3];

% Safety: make all same length
N_total = min([length(time_all), length(Vp_all), length(O2_all), length(HI_all)]);
time_all = time_all(1:N_total);
Vp_all   = Vp_all(1:N_total);
O2_all   = O2_all(1:N_total);
HI_all   = HI_all(1:N_total);

Ttotal = T1 + T2 + T3;

%% ===== Plot =====
figure;
set(gcf, 'Units', 'normalized', 'Position', [0.10 0.15 0.78 0.62]);

%% ---------- Row 1: Vp ----------
subplot(3,1,1)
plot(time_all, Vp_all, 'k', 'LineWidth', 1);
hold on;

xline(T1, '--', 'LineWidth', 1);
xline(T1+T2, '--', 'LineWidth', 1);

xlim([0 Ttotal]);
ylim([-80 -30]);
ylabel('V_p (mV)');
box off
set(gca, 'LineWidth', 1, 'FontSize', 11);

% Stage labels
yl = ylim;
text(T1/2, yl(2)-0.08*(yl(2)-yl(1)), 'Onset', ...
    'HorizontalAlignment', 'center', 'FontSize', 11);

text(T1+T2/2, yl(2)-0.08*(yl(2)-yl(1)), 'Continuous', ...
    'HorizontalAlignment', 'center', 'FontSize', 11);

text(T1+T2+T3/2, yl(2)-0.08*(yl(2)-yl(1)), 'Convalescence', ...
    'HorizontalAlignment', 'center', 'FontSize', 11);

%% ---------- Row 2: O2 ----------
subplot(3,1,2)
plot(time_all, O2_all, 'k', 'LineWidth', 1);
hold on;

% Shade area where O2 < Thr
idx_hypoxia = O2_all < Thr;

if any(idx_hypoxia)
    idx_hypoxia = idx_hypoxia(:)';
    d = diff([0 idx_hypoxia 0]);

    start_idx = find(d == 1);
    end_idx   = find(d == -1) - 1;

    for ii = 1:length(start_idx)
        seg = start_idx(ii):end_idx(ii);

        x_fill = time_all(seg);
        y_fill = O2_all(seg);

        x_fill = x_fill(:)';
        y_fill = y_fill(:)';

        fill([x_fill fliplr(x_fill)], ...
             [y_fill Thr*ones(size(y_fill))], ...
             [0.75 0.75 0.75], ...
             'EdgeColor', 'none', ...
             'FaceAlpha', 0.5);
    end
end

% Replot O2 and threshold
plot(time_all, O2_all, 'k', 'LineWidth', 1);
yline(Thr, 'r--', 'Thr = 24', 'LineWidth', 1);

xline(T1, '--', 'LineWidth', 1);
xline(T1+T2, '--', 'LineWidth', 1);

xlim([0 Ttotal]);
ylim([20 32])
ylabel('[O_2]_o');
box off
set(gca, 'LineWidth', 1, 'FontSize', 11);

%% ---------- Row 3: HI ----------
%% ---------- Row 3: HI ----------
subplot(3,1,3)
hold on;

% ===== Light-blue area under HI curve =====
% Downsample only for filling to avoid very slow rendering
nFill = 3000;
idxFill = round(linspace(1, length(time_all), ...
                min(nFill, length(time_all))));

x_fill_hi = time_all(idxFill);
y_fill_hi = HI_all(idxFill);

fill([x_fill_hi(:); flipud(x_fill_hi(:))], ...
     [y_fill_hi(:); zeros(size(y_fill_hi(:)))], ...
     [0.75 0.88 1.00], ...
     'EdgeColor', 'none', ...
     'FaceAlpha', 0.25);

% HI curve
plot(time_all, HI_all, 'k', 'LineWidth', 1.2);

xline(T1, '--', 'LineWidth', 1);
xline(T1+T2, '--', 'LineWidth', 1);

xlim([0 Ttotal]);
xlabel('Time (s)');
ylabel('HI(t)');
box off
set(gca, 'LineWidth', 1, 'FontSize', 11);

% Add final HI value
yl = ylim;
text(0.78*Ttotal, yl(1)+0.80*(yl(2)-yl(1)), ...
    ['HI = ', num2str(HI_all(end), '%.3f')], ...
    'FontSize', 11);