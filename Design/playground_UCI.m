%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP

%%%Optimize chiller plant operation
chiller_plant_opt = 0;

%%%Electric rates for UCI
%%% 1: current rates
%%% 2: Simplified TOU Rates
uci_rate = 2;

%% Dummy Variables
elec_dump = []; %%%Variable to "dump" electricity

%% Island operation (opt_nem.m) 
island = 0;

%%%Toggles NEM/Wholesale export (1 = on, 0 = off)
export_on = 1; %%%Tied to PV and REES export under current utility rates (opt_PV, opt_ees)

%%%General export
gen_export_on = 1; %%%Placed a "general export" capability in the general electrical energy equality system (opt_gen_equalities)

%% Carbon Related Constraints

%%%Available biogas/renewable gas per year (biogas limit is prorated in the model to the
%%%simulation period)
%%%Used in opt_gen_inequalities
biogas_limit = [];%144E6; %kWh biofuel available per year

%%%Required fuel input
%%%Used in opt_gen_inequalities
h2_fuel_forced_fraction = []; %%%Energy fuel requirements

%%%H2 fuel limit in legacy generator
%%%Used in opt_gen_inequalities
h2_fuel_limit = [];%0.1; %%%Fuel limit on an energy basis - should be 0.1

%%%CO2 Limit
co2_lim = [];%1.2220e+07*0.5;
%% Turning technologies on/off (opt_var_cf.m and tech_select.m)
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 1;  %Turn on REES

lpv_on = 1; %Turn on legacy PV
%% Turning incentives and other financial tools on/off
sgip_on = 0;

%% Throughput requirement - DOE H2 Integration
h2_charging_rec = []; %Required throughput per day

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = [40000];% 250000; %%%Maxpv 
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 0; %%%Allows curtailment is = 1
%% EES (opt_ees.m & opt_rees.m)
ees_onoff = 0;  %%% Avoid simultaneous Charge and Discharge (xd & xc binaries)
toolittle_storage = 1; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Grid limits 
%%% On/Off Grid Import Limit 
grid_import_on = 0;
%%%Limit on grid import power  
import_limit = .8;


%% Adding paths
%%%YALMIP Master Path
addpath(genpath('H:\Matlab_Paths\YALMIP-master')) %rjf path
addpath(genpath('C:\Program Files\MATLAB\YALMIP-master')) %cyc path

%%%CPLEX Path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path

%%%DERopt paths
addpath(genpath('H:\_Tools_\DERopt\Design'))
addpath(genpath('H:\_Tools_\DERopt\Input_Data'))
addpath(genpath('H:\_Tools_\DERopt\Load_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Post_Processing'))
addpath(genpath('H:\_Tools_\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('H:\_Tools_\DERopt\Techno_Economic'))
addpath(genpath('H:\_Tools_\DERopt\Utilities'))
addpath(genpath('H:\_Tools_\DERopt\Data'))

addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Design'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Input_Data'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Load_Processing'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Post_Processing'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Problem_Formulation_Single_Node'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Techno_Economic'))
addpath(genpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Utilities'))

%%%Specific project path
% addpath('H:\_Research_\CEC_OVMG\DERopt')

%%%SGIP CO2 Signal
addpath('H:\Data\CPUC_SGIP_Signal')
addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data')

%%%CO2 Signal Path
addpath('H:\Data\Emission_Factors')
addpath('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Emission_Factors')

%% Loading building demand

%%%Loading Data
dt = load('H:\Data\UCI\Campus_Loads_2014_2019.mat');
% dt = load('C:\Users\kenne\OneDrive - University of California - Irvine\DERopt\Data\Campus_Loads_2014_2019.mat');

heat = dt.loads.heating;
time = dt.loads.time;
if chiller_plant_opt
    elec = dt.loads.elec;
    cool = dt.loads.cooling;
else
    elec = dt.loads.elec_total;
    cool = [];
end

%% Placeholders
dc_exist = 1;
rate = {'TOU8'};
low_income = 0;
sgip_pbi = 1;
res_units = 0;

%% Formatting Building Data
%%%Values to filter data by
year_idx = 2018;
month_idx = [7 12];

bldg_loader_UCI

%% Utility Data
%%%Loading Utility Data and Generating Energy Charge Vectors
utility_UCI
% export_price = export_price*0;
%%%Placeholder natural gas cost
ng_cost = 0.5/29.3; %$/kWh --> Converted from $/therm to $/kWh, 29.3 kWh / 1 Therm
rng_cost = ng_cost*2;
%% Tech Parameters/Costs
%%%Technology Parameters
tech_select_UCI

%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;

%%%Capital cost mofificaitons
cap_cost_mod

%% Legacy Technologies
tech_legacy_UCI

%% DERopt
%% Setting up variables and cost function
fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
tic
opt_var_cf %%%Added NEM and wholesale export to the PV Section
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% General Equality Constraints
fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
tic

if onoff_model
    opt_gen_equalities %%%Does not include NEM and wholesale in elec equality constraint
else
    opt_gen_equalities_vc_mod
end
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% General Inequality Constraints
fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
tic
opt_gen_inequalities
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Heat Recovery Inequality Constraints
fprintf('%s: Heat Recovery Inequalities. ', datestr(now,'HH:MM:SS'))
tic
opt_heat_recovery
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Legacy DG Constraints
fprintf('%s: Legacy DG Constraints. ', datestr(now,'HH:MM:SS'))
tic
opt_dg_legacy
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Legacy ST Constraints
fprintf('%s: Legacy ST Constraints. ', datestr(now,'HH:MM:SS'))
tic
opt_bot_legacy
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Solar PV Constraints
fprintf('%s: PV Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_pv 
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% EES Constraints
fprintf('%s: EES Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_ees
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Legacy EES Constraints
fprintf('%s: Legacy EES Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_ees_legacy
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Legacy VC Constraints
fprintf('%s: Legacy VC Constraints.', datestr(now,'HH:MM:SS'))
tic
if onoff_model
opt_vc_legacy
end
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% Legacy TES Constraints
fprintf('%s: Legacy TES Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_tes_legacy
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)
%% DER Incentives
fprintf('%s: DER Incentives Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_incentives
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% H2 production Constraints
fprintf('%s: Electrolyzer and H2 Storage Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_h2_production
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Optimize
fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
opt

%% Timer
finish = datetime('now') ; totalelapsed = toc(startsim)

%% Variable Conversion
variable_values

%% System Evaluaiton
uci_evaluation