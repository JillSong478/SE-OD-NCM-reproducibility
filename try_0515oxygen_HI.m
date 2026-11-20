clear all; clc

%% ===== HI heat map scan settings =====
% Goal: HI as a function of tau_KCC2 and [O2]_bath
% Different k values are shown as different panels.
seed_id = 2;   % 分别改为 2、3、4，运行三次


tau_vals   = 1000:500:10000;     % GABA/KCC2 impairment
Obath_vals = 24:0.25:28;           % oxygen supply
k_vals_HI  = 0.95;      % NMDA availability slices  [0.95 0.8 0.7];

n_tau   = length(tau_vals);
n_Obath = length(Obath_vals);
n_k     = length(k_vals_HI);

HI_map = zeros(n_tau, n_Obath, n_k);

Thr = 24;       % injury threshold from previous work
t_start = 10;   % discard transient, seconds

%% ===== Start parameter scan =====
for kk_idx = 1:n_k
    for ii_tau = 1:n_tau
        for jj_o2 = 1:n_Obath

            tau_KCC2_now = tau_vals(ii_tau);
            Obath_now    = Obath_vals(jj_o2);
            k_now        = k_vals_HI(kk_idx);

            %rng(1);   % keep noise fixed for comparison
            rng(seed_id);   % same noise realization across parameter combinations

% Parameters from Table 1
Cm=1; % s-1
% taop=30;
% taoi=30;
taop=40;
% taoi=40;
taoi=30;
taot=20;
taor=20;

Obath = Obath_now;
% Qp_max=30e-3;
% Qi_max=60e-3;
Qt_max=400e-3;
Qr_max=400e-3;

Qp_max=20e-3;
Qi_max=50e-3;

% theta=-58.5;
% thetar=-58.5;

theta=-54;
thetar=-54;

% sigma_p=4.7;
% % sigma_p=4;
sigma_p=4;    %N2
% sigma_p=6;    %N3

sigma_i=6;
% sigma_t=6;
% sigma_r=6;
sigma_t=6;
sigma_r=4.421;
% gammae=70e-3;
% gammae=70e-3;
% % gammag=58.6e-3;
% gammag=58.5e-3;
% gammat=70e-3;
% gammar=100e-3;
gammae  = 58e-3;
gammag  = 54e-3;
gammat  = 58e-3;
gammar  = 82e-3;

gammane=15e-3;

v=120e-3;
% Npp=115;Nip=72;Npi=90;Nii=90;Ntp=2.6;Nrp=2.6;Nrt=3;Ntr=5;Nrr=25;Npt=2.5;Nit=2.5;
% Npp=115;Nip=72;Npi=90;Nii=90;Ntp=2.6;Nrp=2.6;Nrt=3;Ntr=5;Nrr=25;
% Npt=2.5;Nit=2.5;
% Npp=115;Nip=72;Npi=90;Nii=90;Ntp=0;Nrp=0;Nrt=3;Ntr=5;Nrr=25;
% Npt=0;Nit=0;
% Npp=130;Nip=95;Npi=80;Nii=90;Ntp=2.8;Nrp=4.8;Nrt=5;Ntr=3;Nrr=25;
% Npt=2.8;Nit=2.8;   %正常连接
Npp=130;Nip=80;Npi=95;Nii=90;Ntp=2.3;Nrp=2.3;Nrt=3;Ntr=5;Nrr=25;
Npt=2.5;Nit=2.5;   %正常连接
% Npp=130;Nip=80;Npi=95;Nii=90;Ntp=0;Nrp=0;Nrt=3;Ntr=5;Nrr=25;
% Npt=0;Nit=0;     %ct无连接

% Npp=130;Nip=80;Npi=95;Nii=90;Ntp=3.2;Nrp=3;Nrt=3.2;Ntr=5;Nrr=25;
% Npt=3.2;Nit=3.2;     %ct连接加强

WAMPA=1;WGABA=1;
WNMDA= 4;
% g_T_t=3;g_T_r=2.3;
E_L_p=-62;E_L_i=-62;E_L_t=-70;E_L_r=-70;

% taoz_V=75;
% E_K1=-90;
% % g_K_s=1.9;  % strengthen Npt.     kcomplexs-----spindles;
% g_syn=3;
% EGABA_cp=-70;
% EGABA_ci=-70;  %有变化

% EGABA_cp=-70;
% EGABA_ci=-70;  %有变化

P_cl   = 0.8;        % relative chloride contribution
P_HCO3 = 1 - P_cl;      % relative bicarbonate contribution
E_HCO3 = -18;           % mV, bicarbonate reversal potential

% Baseline chloride reversal potential
E_Cl0 = -88;            % mV

% Parameters for E_Cl dynamics
% beta should be consistent with the voltage unit used in the model.
% If voltage is in mV, beta can be approximated as F/(R*T)*1e-3.
F_const = 96485;        % C/mol
R_const = 8.314;        % J/(mol*K)
T_abs   = 310;          % K, approximately 37 degree Celsius
beta_E  = F_const/(R_const*T_abs)*1e-3;   % 1/mV

Cl_o    = 135;          % mM, extracellular chloride concentration; adjust if needed
Vol_cell = 1;           % effective volume/scaling factor; tune according to model scale

tau_KCC2 = tau_KCC2_now;       % ms, recovery time constant of chloride extrusion;30000ms

%EGABA=-70;
%E_K=-95;
E_Ca_t=120;E_Ca_r=120;EAMPA=0;ENMDA=0;
alphaNa=2;tao_Na=1.7;Na0=9.5;alphaCa=-51.8e-6;tao_Ca=10;
Ca0=2.4e-4;k2=4e-4;k3=1e-1;k4=1e-3;np=4;ginc=2;
% R_pump=0.09;
% phi_C_sd=120e-3;
% phi_T_sd=10e-3;
phi_C_sd=80e-3;
phi_T_sd=8e-3;
% gammaee=120e-3;
% gammaei=120e-3;
% gammaet=70e-3;
gammaee=60e-3;
gammaei=60e-3;
gammaet=60e-3;

% E_Na=55;
% E_Na=55;
% tao_z_t=75;
tao_z_t=75;

% g_M=1.6;  %N3正常0.6-
% g_M=0.02;    %N3痫样波
%  g_M=1.3;  %N2正常 4.2-
g_Mr=1; %N2痫样波  -4

mg=2;
% k=1;
k = k_now;


g_L_K_p=0.042;

g_Na=0.032;%0.032
%g_Na=0.06;

g_K_Na=1.8;    %N2

g_Mp=0.8;%1.2
%g_Mp=0.8;
% E_M=-90;

E_CAN=10;
g_CAN=1.2;

%g_T_t=3.1;g_T_r=2.4; (type3)
%g_T_t=2.7;g_T_r=2.5;(type 4)
g_T_t=1.9;g_T_r=1.7;   % 产生spindle，spindle的时长
% g_K_Na=1.33;

% g_K_Na=1.88;    %N3 

% % g_L_K=0.02;
% g_L_K=0.034;  %N2
g_L_K=0.0251;  %N2
%  g_L_K=0.02;   %N3

% g_h=0.06;
g_h=0.012;     %N2
% g_h  = 0.042;%0.012
% g_h=0.042;     %N2 调节spindle形状
% g_h=0.062;      %N3

E_h=-40;
k1=2.5e7;
% g_K_Ca=0.57;
% Nrr22=2;

mean_1=0.000005;

start = 0.0;
% stop = 200000 ;
% stop = 20000 ; 
stop = 45000 ; 
%stop = 90000;
dt = 1e-2;
% k0 = t0/2/dt; % the delay in timesteps
time_array = [start:dt:stop];
vec_len = length(time_array);

Vp = zeros(1,vec_len);
Vi = zeros(1,vec_len);
Vt = zeros(1,vec_len);
Vr = zeros(1,vec_len);
Sep = zeros(1,vec_len);
Sepdot = zeros(1,vec_len);
Sei = zeros(1,vec_len);
Seidot = zeros(1,vec_len);
Set = zeros(1,vec_len);
Setdot = zeros(1,vec_len);
Ser = zeros(1,vec_len);
Serdot = zeros(1,vec_len);
Sgp = zeros(1,vec_len);
Sgpdot = zeros(1,vec_len);
Sgi = zeros(1,vec_len);
Sgidot = zeros(1,vec_len);
Srt = zeros(1,vec_len);
Srtdot = zeros(1,vec_len);
Srr = zeros(1,vec_len);
Srrdot = zeros(1,vec_len);
phip = zeros(1,vec_len);
phipdot = zeros(1,vec_len);
phit = zeros(1,vec_len);
phitdot = zeros(1,vec_len);
h_T_t = zeros(1,vec_len);
h_T_r = zeros(1,vec_len);
m_h1 = zeros(1,vec_len);
m_h2 = zeros(1,vec_len);
concentration_Ca = zeros(1,vec_len);
concentration_Na = zeros(1,vec_len);
concentration_O = zeros(1,vec_len);
concentration_K = zeros(1,vec_len);

zp = zeros(1,vec_len);
 zr = zeros(1,vec_len);
s_syn = zeros(1,vec_len);
j= zeros(1,vec_len);

Nep = zeros(1,vec_len);
Nepdot=zeros(1,vec_len);
Nei = zeros(1,vec_len);
Neidot=zeros(1,vec_len);
I_LK_p1=zeros(1,vec_len);
I_Nap_p1=zeros(1,vec_len);
I_M_p1=zeros(1,vec_len);
J_L_p1=zeros(1,vec_len);
I_K_Na1=zeros(1,vec_len);

E_Na =zeros(1,vec_len);
E_K =zeros(1,vec_len);
E_Cl = zeros(1,vec_len);
EGABA_cp = zeros(1,vec_len);
EGABA_ci = zeros(1,vec_len);
EGABA = zeros(1,vec_len);
I_cl = zeros(1,vec_len);

%Ca = zeros(1,vec_len);
I_M_p1(1) = 0;
I_LK_p1(1) = 0;
I_Nap_p1(1) = 0;
J_L_p1(1)=0;
I_K_Na1(1) = 0;
Ca(1) = 0;
s_syn(1) = 0;
zp(1) = 0;
 zr(1) = 0;
Vp(1) = -64;
Vi(1) = -64;
Vt(1) = -70;
Vr(1) = -70;
Sep(1) = 0;
Sepdot(1) = 0;
Sei(1) = 0;
Seidot(1) = 0;
Set(1) = 0;
Setdot(1) = 0;
Ser(1) = 0;
Serdot(1) = 0;
Sgp(1) = 0;
Sgpdot(1) = 0;
Sgi(1) = 0;
Sgidot(1) = 0;
Srt(1) = 0;
Srtdot(1) = 0;
Srr(1) = 0;
Srrdot(1) = 0;
phip(1) = 0;
phipdot(1) = 0;
phit(1) = 0;
phitdot(1) = 0;

Nep(1) = 0;
Nepdot(1)=0;
Nei(1) = 0;
Neidot(1)=0;

h_T_t(1) = 0;
h_T_r(1) = 0;
m_h1(1) = 0;
m_h2(1) = 0;
j(1) = 0;
concentration_Ca(1) = 2.4E-4;
concentration_Na(1) =Na0;
concentration_O(1) =0.001;
concentration_K(1) =4;


E_Na(1) = 45;

E_K(1) = 4;

E_Cl(1) = E_Cl0;
EGABA_cp(1) = P_cl * E_Cl(1) + P_HCO3 * E_HCO3;
EGABA_ci(1) = P_cl * E_Cl(1) + P_HCO3 * E_HCO3;
EGABA(1) = P_cl * E_Cl(1) + P_HCO3 * E_HCO3;
I_cl(1) =  0;

% 
% noise1 = gammae^2*sqrt(phi_C_sd*dt)*randn(1,vec_len); 
% noise2 = gammae^2*sqrt(phi_C_sd*dt)*randn(1,vec_len); 
% noise3 = gammae^2*sqrt(phi_T_sd*dt)*randn(1,vec_len); 

noise1 = gammaee^2*sqrt(phi_C_sd*dt)*randn(1,vec_len); 
noise2 = gammaei^2*sqrt(phi_C_sd*dt)*randn(1,vec_len); 
noise3 = gammaet^2*sqrt(phi_T_sd*dt)*randn(1,vec_len); 

%% g变化参考
t0=0; t1 = 35000; t2 = 100000; t3 = 110000; t4 = 175000; % 横坐标
kk1 = 1; kk2 =3;  % 纵坐标
upslope = [kk1:(kk2-kk1)/(t2/dt-t1/dt):kk2];
downslope = [kk2:(kk1-kk2)/(t4/dt-t3/dt):kk1];
horizontal1 = kk1*ones(1,(t0/dt+t1/dt));
horizontal2 = kk2*ones(1,(t3/dt-t2/dt));
horizontal3 = kk1*ones(1,((stop-t0/2)/dt-t4/dt));
g_K_s= [horizontal1 upslope(1:end-1) horizontal2 downslope(1:end-1) horizontal3]; % 

for t = 2:(stop/dt)

C=(pi./sqrt(3));
Qp=Qp_max./(1+exp(-C*(Vp(t-1)-theta)/(sigma_p)));
Qi=Qi_max./(1+exp(-C*(Vi(t-1)-theta)/(sigma_i)));
Qt=Qt_max./(1+exp(-C*(Vt(t-1)-theta)/(sigma_t)));
Qr=Qr_max./(1+exp(-C*(Vr(t-1)-thetar)/(sigma_r)));

Mp=1./(1+k.*(mg./3.57.*exp(-(0.062.*Vp(t-1)))));
Mi=1./(1+k.*(mg./3.57.*exp(-(0.062.*Vi(t-1)))));
% Mi=1./(1+0.2.*exp(-alphan*(Vi(t-1))));



% 
% Napump=(Rpump*((concentration_Na(t-1)^3./(concentration_Na(t-1)^3+3375))-(Na0^3./(Na0^3+3375))));
J_L_p=(Vp(t-1)-E_L_p);
J_L_p1(t-1)=(Vp(t-1)-E_L_p);
J_L_i=(Vi(t-1)-E_L_i);
J_L_t=(Vt(t-1)-E_L_t);
J_L_r=(Vr(t-1)-E_L_r);
JAMPA_Sep=WAMPA*Sep(t-1)*(Vp(t-1)-EAMPA);
JAMPA_Sei=WAMPA*Sei(t-1)*(Vi(t-1)-EAMPA);
JAMPA_Set=WAMPA*Set(t-1)*(Vt(t-1)-EAMPA);
JAMPA_Ser=WAMPA*Ser(t-1)*(Vr(t-1)-EAMPA);

EGABA_cp(t-1) = P_cl * E_Cl(t-1) + P_HCO3 * E_HCO3;
EGABA_ci(t-1) = P_cl * E_Cl(t-1) + P_HCO3 * E_HCO3;
EGABA(t-1) = P_cl * E_Cl(t-1) + P_HCO3 * E_HCO3;

 JGABA_Sgp=WGABA*Sgp(t-1)*(Vp(t-1)-EGABA_cp(t-1));
JGABA_Sgi=WGABA*Sgi(t-1)*(Vi(t-1)-EGABA_ci(t-1));
JGABA_Srt=WGABA*Srt(t-1)*(Vt(t-1)-EGABA(t-1));
JGABA_Srr=WGABA*Srr(t-1)*(Vr(t-1)-EGABA(t-1));

JNMDA_Nep=WNMDA*Nep(t-1)*Mp*(Vp(t-1)-ENMDA);
JNMDA_Nei=WNMDA*Nei(t-1)*Mi*(Vi(t-1)-ENMDA);





m_limit_t=1./(1+exp(-(Vt(t-1)+59)/6.2));
m_limit_r=1./(1+exp(-(Vr(t-1)+52)/7.4));
h_limit_t=1./(1+exp((Vt(t-1)+81)/4));
h_limit_r=1./(1+exp((Vr(t-1)+80)/5));

zp_limit_t=1./(1+exp(-(Vp(t-1)+39)/5));
zr_limit_t=1./(1+exp(-(Vr(t-1)+39)/5));
j_limit=1./(1+exp(-(Vr(t-1)+43)/5.2));
mNa_limit_p=1./(1+exp(-(Vp(t-1)+47)/3));  %41-47


E_Na = 26.64*log((144-7.*(concentration_Na(t-1)-18))./concentration_Na(t-1));

E_K = 26.64*log(((concentration_K(t-1)))./(140+18-concentration_Na(t-1)));


I_LK_t=g_L_K*(Vt(t-1)-E_K);
I_LK_r=g_L_K*(Vr(t-1)-E_K);
I_LK_p=g_L_K_p*(Vp(t-1)-E_K);


I_LK_p1(t-1)=g_L_K_p.*(Vp(t-1)-E_K);

I_T_t=g_T_t*m_limit_t*m_limit_t*h_T_t(t-1).*(Vt(t-1)-E_Ca_t);

I_T_r=g_T_r*m_limit_r*m_limit_r*h_T_r(t-1)*(Vr(t-1)-E_Ca_r);
I_h=g_h*(m_h1(t-1)+ginc*m_h2(t-1))*(Vt(t-1)-E_h);
I_K_Na=g_K_Na*(0.37./(1+(38.7./concentration_Na(t-1))^3.5))*(Vp(t-1)-E_K);
I_K_Na1(t-1)=g_K_Na*(0.37./(1+(38.7./concentration_Na(t-1))^3.5))*(Vp(t-1)-E_K);
I_M_p=g_Mp*zp(t-1)*(Vp(t-1)-E_K);
I_M_p1(t-1)=g_Mp*zp(t-1)*(Vp(t-1)-E_K);

I_M_r=g_Mr*zr(t-1)*(Vr(t-1)-E_K);
I_CAN=g_CAN*(concentration_Ca(t-1)./(0.2+concentration_Ca(t-1)))*j(t-1)*(Vr(t-1)-E_CAN);

I_Nap_p=g_Na*mNa_limit_p*(Vp(t-1)-E_Na);


I_Nap_p1(t-1)=g_Na*mNa_limit_p*(Vp(t-1)-E_Na);

% M(concentration_Ca(t-1))=concentration_Ca(t-1)./(0.2+concentration_Ca(t-1));
tao_j=1.6+2.7./(exp(-(Vr(t-1)+55)./15)+(exp(Vr(t-1)+55)./15));

tao_h_t=(30.8+(211.4+exp((Vt(t-1)+115.2)/5))./(1+exp((Vt(t-1)+86)/3.2)))/3.7371928;
tao_h_r=(85+1./(exp((Vr(t-1)+48)/4)+exp(-(Vr(t-1)+407)/50)))/3.7371928;
m_limit_h=1./(1+exp((Vt(t-1)+75)/5.5));
tao_m_h=(20+1000./(exp((Vt(t-1)+71.5)/14.2)+exp(-(Vt(t-1)+89)/11.6)));
Ph=k1*(concentration_Ca(t-1))^np./(k1*(concentration_Ca(t-1))^np+k2);
R_pump = 1.25./(1+exp((20- concentration_O(t-1))/3)).*1./(1+exp((25-concentration_Na(t-1))./3)).*1./(1+exp(5.5-concentration_K(t-1)));

Na_pump=R_pump*((concentration_Na(t-1)^3./(concentration_Na(t-1)^3+3375))-(Na0^3./(Na0^3+3375)));

% % 
% % % Vp(t)=Vp(t-1)+dt*((-J_L_p-JAMPA_Sep-JGABA_Sgp-Cm*taop*(I_K_Na+I_K_s))./taop);
% z_limit_V=1./(1+exp((-Vp(t-1)-39)./5));
% z(t)=z(t-1)+dt*((z_limit_V-z(t-1))./taoz_V);
% I_K_s=g_K_s(t-1).*z(t-1).*(Vp(t-1)-E_K);

% +I_Nap_p+I_M_p  +I_M_r+I_CAN

% Vp(t)=Vp(t-1)+dt*((-J_L_p-JAMPA_Sep-JGABA_Sgp-Cm*taop*(I_K_Na))./taop);
% Vp(t)=Vp(t-1)+dt*((-J_L_p-JAMPA_Sep-JGABA_Sgp-Cm*taop*(I_LK_p+I_K_Na+I_M_p))./taop);
Vp(t)=Vp(t-1)+dt*((-J_L_p-JAMPA_Sep-JNMDA_Nep-JGABA_Sgp-Cm*taop*(I_M_p+I_Nap_p))./taop);
% Vp(t)=Vp(t-1)+dt*((-J_L_p-JAMPA_Sep-JGABA_Sgp-Cm*taop*(I_K_s))./taop);
Vi(t)=Vi(t-1)+dt*((-J_L_i-JAMPA_Sei-JNMDA_Nei-JGABA_Sgi)./taoi);
Vt(t)=Vt(t-1)+dt*((-J_L_t-JAMPA_Set-JGABA_Srt-Cm*taot*(I_LK_t+I_T_t+I_h))./taot);
% Vr(t)=Vr(t-1)+dt*((-J_L_r-JAMPA_Ser-JGABA_Srr-Cm*taor*(I_LK_r+I_T_r+I_M_r))./taor);
Vr(t)=Vr(t-1)+dt*((-J_L_r-JAMPA_Ser-JGABA_Srr-Cm*taor*(I_LK_r+I_T_r))./taor);


% fV=1/(1+exp(-0.5*Vr(t-1)));
% s_syn(t)=s_syn(t-1)+dt*(12*fV*(1-s_syn(t-1))-0.1*s_syn(t-1));
% I_syn=(g_syn*(Vr(t-1)+70)*s_syn(t-1));
% % % % Vr(t)=Vr(t-1)+dt*((-J_L_r-JAMPA_Ser-I_syn-Cm*taor*(I_LK_r+I_T_r))./taor);
% % % % % % % I_K_Ca=g_K_Ca*(Ca(t-1)./(Ca(t-1)+30))*(Vr(t-1)-120);
% % % % % % % Ca(t)=Ca(t-1)+dt*(-0.005*0.005*I_T_r-Ca(t-1)./150);



Sep(t) = Sep(t-1) + Sepdot(t-1)*dt;
Sepdot(t) = Sepdot(t-1) + dt*(gammae^2*(Npp*Qp+Npt*phit(t-1)-Sep(t-1))-2*gammae*Sepdot(t-1) )+noise1(t-1);

Sei(t) = Sei(t-1) + Seidot(t-1)*dt;
Seidot(t) = Seidot(t-1) + dt*(gammae^2*(Nip*Qp+Nit*phit(t-1)-Sei(t-1))-2*gammae*Seidot(t-1) )+noise2(t-1);

Set(t) = Set(t-1) + Setdot(t-1)*dt;
Setdot(t) = Setdot(t-1) + dt*(gammat^2*(Ntp*phip(t-1)-Set(t-1))-2*gammat*Setdot(t-1) )+noise3(t-1);

Ser(t) = Ser(t-1) + Serdot(t-1)*dt;
Serdot(t) = Serdot(t-1) + dt*(gammat^2*(Nrt*Qt+Nrp*phip(t-1)-Ser(t-1))-2*gammat*Serdot(t-1) );

Nep(t) = Nep(t-1) + Nepdot(t-1)*dt;
Nepdot(t) = Nepdot(t-1) + dt*(gammane^2*(Npp*Qp-Nep(t-1))-2*gammane*Nepdot(t-1) );

Nei(t) = Nei(t-1) + Neidot(t-1)*dt;
Neidot(t) = Neidot(t-1) + dt*(gammane^2*(Nip*Qp-Nei(t-1))-2*gammane*Neidot(t-1) );

Sgp(t) = Sgp(t-1) + Sgpdot(t-1)*dt;
Sgpdot(t) = Sgpdot(t-1) + dt*(gammag^2*(Npi*Qi-Sgp(t-1))-2*gammag*Sgpdot(t-1) );

Sgi(t) = Sgi(t-1) + Sgidot(t-1)*dt;
Sgidot(t) = Sgidot(t-1) + dt*(gammag^2*(Nii*Qi-Sgi(t-1))-2*gammag*Sgidot(t-1) );

Srt(t) = Srt(t-1) +Srtdot(t-1)*dt;
Srtdot(t) = Srtdot(t-1) + dt*(gammar^2*(Ntr*Qr-Srt(t-1))-2*gammar*Srtdot(t-1) );

Srr(t) = Srr(t-1) +Srrdot(t-1)*dt;
Srrdot(t) = Srrdot(t-1) + dt*(gammar^2*(Nrr*Qr-Srr(t-1))-2*gammar*Srrdot(t-1) );

phip(t) = phip(t-1) +phipdot(t-1)*dt;
phipdot(t) = phipdot(t-1) + dt*(v^2*(Qp-phip(t-1))-2*v*phipdot(t-1));

phit(t) = phit(t-1) +phitdot(t-1)*dt;
phitdot(t) = phitdot(t-1) + dt*(v^2*(Qt-phit(t-1))-2*v*phitdot(t-1));

h_T_t(t)=h_T_t(t-1)+dt*((h_limit_t-h_T_t(t-1))./tao_h_t);
h_T_r(t)=h_T_r(t-1)+dt*((h_limit_r-h_T_r(t-1))./tao_h_r);

m_h1(t)=m_h1(t-1)+dt*((m_limit_h*(1-m_h2(t-1))-m_h1(t-1))./tao_m_h-k3*Ph*m_h1(t-1)+k4*m_h2(t-1));
m_h2(t)=m_h2(t-1)+dt*(k3*Ph*m_h1(t-1)-k4*m_h2(t-1));

zp(t)=zp(t-1)+dt*((zp_limit_t-zp(t-1))./tao_z_t);
zr(t)=zr(t-1)+dt*((zr_limit_t-zr(t-1))./tao_z_t);

j(t)=j(t-1)+dt*(j_limit-j(t-1)./tao_j);

concentration_Ca(t)=concentration_Ca(t-1)+dt*(alphaCa*I_T_t-(concentration_Ca(t-1)-Ca0)./tao_Ca);
concentration_Na(t)=concentration_Na(t-1)+dt*((alphaNa*Qp-Na_pump)./tao_Na);%


concentration_K(t)=concentration_K(t-1)+dt*((0.3115*(I_M_p)-14.*R_pump));%+I_LK_t+I_LK_r%-2*1/3.*R_pump0.001*


concentration_O(t)=concentration_O(t-1)+dt*(-5.3*R_pump + 0.17*(Obath-concentration_O(t-1)));%0.001*


I_cl(t-1) = WGABA * Sgp(t-1) * P_cl * (Vp(t-1) - E_Cl(t-1));

E_Cl(t) = E_Cl(t-1) + dt * (I_cl(t-1) ./ (beta_E * exp(beta_E * E_Cl(t-1)) * F_const * Vol_cell * Cl_o) - (E_Cl(t-1) - E_Cl0) ./ tau_KCC2 );
end

%% ===== Calculate final HI for current parameter set =====
idx_start = round(t_start*1000/dt);

O2_plot = concentration_O(idx_start:end);

dt_sec = dt / 1000;

O2_deficit = max(Thr - O2_plot, 0);

HI_t = cumsum(O2_deficit) * dt_sec;
time_plot = (0:length(HI_t)-1) * dt_sec;
idx30 = time_plot <= 30;
HI_30 = HI_t(idx30);

% Final HI at 30 s
HI_final = HI_30(end);

HI_map(ii_tau, jj_o2, kk_idx) = HI_final;

fprintf('k = %.2f, tau = %g, Obath = %.1f, HI = %.3f\n', ...
    k_now, tau_KCC2_now, Obath_now, HI_final);

        end 
    end
end

%% ===== Plot log-scaled HI heat maps =====

HI_plot = log10(HI_map + 1);

figure;
set(gcf, 'Units', 'normalized', 'Position', [0.10 0.18 0.80 0.42]);

HI_max = max(HI_plot(:));

for kk_idx = 1:n_k

    subplot(1, n_k, kk_idx)

    imagesc(Obath_vals, tau_vals, HI_plot(:,:,kk_idx));
    axis xy;

    xlabel('[O_2]_{bath}');
    ylabel('\tau_{KCC2} (ms)');

    title(['k = ', num2str(k_vals_HI(kk_idx))]);

    colormap(parula);
    caxis([0 HI_max]);

    set(gca, 'FontSize', 11, 'LineWidth', 1);
    box on;

%     hold on;

%     % contour based on original HI values, not log values
%     [C,h] = contour(Obath_vals, tau_vals, HI_map(:,:,kk_idx), ...
%         [0.1 1 5 10 20], ...
%         'LineColor', 'k', ...
%         'LineWidth', 0.7);
% 
%     clabel(C,h,'FontSize',8,'Color','k');

end

cb = colorbar;
cb.Position = [0.93 0.18 0.015 0.70];
cb.Label.String = 'log_{10}(HI+1)';
cb.FontSize = 11;