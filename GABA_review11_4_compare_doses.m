% Reviewer 11.4: compare GABA intervention strengths against a
% time-matched untreated control at the SAME tau_KCC2 and random seed.
% Run GABA_intervention_review11_4.m four times, choosing
% WGABA_treat = 1, 1.25, 1.5, 2.0, BEFORE running this file.
clear; clc;

nSeedsUsed = 10;  % use 3 if you used seedList=1:3 for a preliminary pilot
controlFile = sprintf('GABA_W1p00_%dseeds_trials.csv',nSeedsUsed);
control = readtable(controlFile);

doses = [1.25, 1.50, 2.00];
tags  = {'1p25','1p50','2p00'};
tauValues = unique(control.tau_KCC2_ms);
nTau = numel(tauValues);
nDose = numel(doses);
MeanAdjusted = nan(nTau,nDose);
SDAdjusted   = nan(nTau,nDose);
NValid       = zeros(nTau,nDose);
MeanUnadjusted = nan(nTau,nDose);
SDUnadjusted   = nan(nTau,nDose);
PostContinuousFraction = nan(nTau,nDose);

for j = 1:nDose
    treated = readtable(sprintf('GABA_W%s_%dseeds_trials.csv',tags{j},nSeedsUsed));
    % Data are saved in the same tau-seed ordering for every run.
    assert(isequal(control.tau_KCC2_ms,treated.tau_KCC2_ms) && ...
        isequal(control.Seed,treated.Seed), ...
        'Different tau/seed ordering: align the records before comparison.');
    for i = 1:nTau
        ix = treated.tau_KCC2_ms==tauValues(i);
        % Exclude runs not initially classified as continuous SE-like.
        eligible = ix & control.PreState==3 & treated.PreState==3 & ...
            isfinite(control.PostRate) & control.PostRate>0 & ...
            isfinite(treated.PostRate);
        NValid(i,j) = sum(eligible);
        if any(eligible)
            % Matched noise and matched time window (30-40 s).
            adjusted = 100*(1-treated.PostRate(eligible)./control.PostRate(eligible));
            MeanAdjusted(i,j) = mean(adjusted);
            SDAdjusted(i,j)   = std(adjusted);
            raw = treated.Suppression_pct(eligible);
            MeanUnadjusted(i,j) = mean(raw,'omitnan');
            SDUnadjusted(i,j)   = std(raw,0,'omitnan');
            PostContinuousFraction(i,j) = mean(treated.PostState(eligible)==3);
        end
    end
end

TauGrid = repmat(tauValues,1,nDose);
DoseGrid = repmat(doses,nTau,1);
Summary = table(TauGrid(:),DoseGrid(:),NValid(:), ...
    MeanUnadjusted(:),SDUnadjusted(:), ...
    MeanAdjusted(:),SDAdjusted(:), PostContinuousFraction(:), ...
    'VariableNames',{'tau_KCC2_ms','WGABA_treat','N_PreContinuous', ...
    'PrePostSuppression_mean_pct','PrePostSuppression_SD_pct', ...
    'ControlAdjusted_mean_pct','ControlAdjusted_SD_pct', ...
    'PostContinuousFraction'});
disp(Summary);
writetable(Summary,'GABA_review11_4_dose_comparison.csv');

figure('Color','w','Name','Reviewer 11.4 control-adjusted effects'); hold on;
for j = 1:nDose
    errorbar(tauValues,MeanAdjusted(:,j),SDAdjusted(:,j),'-o', ...
        'LineWidth',1.5,'DisplayName',sprintf('W_{GABA}=%.2f',doses(j)));
end
yline(0,'--','HandleVisibility','off');
xlabel('\tau_{KCC2} (ms)');
ylabel('Control-adjusted discharge-rate reduction (%)');
legend('Location','best'); box off;
exportgraphics(gcf,'GABA_review11_4_dose_comparison.png','Resolution',300);
