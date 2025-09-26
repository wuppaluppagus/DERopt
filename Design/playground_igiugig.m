%% Playground file for OVMG Project
 clear all; close all; clc ; started_at = datetime('now'); startsim = tic;
 %% TDJ Running?
is_tdj_running_the_model = 0;

%% Parameters

parameter_sweep_onoff = 0;

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP
%% Dummy Variables
elec_dump = []; %%%Variable to "dump" electricity
%% Diesel Only Toggles
utility_exists=[]; %% Utility access
pv_on = 1;        %Turn on PV
ees_on = 0;       %Turn on EES/REES
rees_on = 0;  %Turn on REES
ror_on = 0; % Turn On Run of river generator
ror_integer_on = 1;
ror_integer_cost = 9000;
pemfc_on = 0;
%%%Hydrogen technologies
el_on = 0; %Turn on generic electrolyer
el_binary_on = 0;
rel_on = 0; %Turn on renewable tied electrolyzer
h2es_on = 1; %Hydrogen energy storage
strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?
%%% Legacy System Toggles
lpv_on = 0; %Turn on legacy PV 
lees_on = 0; %Legacy EES
ltes_on = 0; %Legacy TES

%%% Experimental
rsoc_on = 0;

lror_on = 0; %Turn on legacy run of river
ror_area = 200;
ldiesel_on = 0; %Turn on legacy diesel generators
ldiesel_binary_on = 0; %Binary legacy diesel generators

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = [30000];% ; %%%Maxpv 
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 1; %%%Allows curtailment is = 1
%% EES (opt_ees.m & opt_rees.m)
toolittle_storage = 0; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Adding paths

%%%DERopt paths
if is_tdj_running_the_model
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Design'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Input_Data'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Load_Processing'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Post_Processing'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Problem_Formulation_Single_Node'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Techno_Economic'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Utilities'))
    addpath(genpath('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Igiugig'))
else
    addpath(genpath('H:\_Tools_\Titus\DERopt\Design'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Input_Data'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Load_Processing'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Post_Processing'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Problem_Formulation_Single_Node'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Techno_Economic'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Utilities'))
    addpath(genpath('H:\_Tools_\Titus\DERopt\Data'))
end

%% Loading building demand
%%%Loading Data
if is_tdj_running_the_model
    dt = readtable('C:\Users\typde\Downloads\Lab\DERopt\DERopt\Igiugig\Igiugig\Igiugig_Load_Growth_added_time.csv');
else
    dt = readtable('H:\_Tools_\DERopt\Data\Igiugig\Igiugig_Load_Growth_added_time.csv');
end

time = datenum(dt.Date);
elec = dt.ElectricDemand_kW_;
heat = [];
cool = [];

%%% Formatting Building Data
%%%Values to filter data by
month_idx = [1, 2, 3, 4, 5];

% month_idx=[];

% month_idx = [2];
% month_idx = [9];
% month_idx = [1];
% month_idx = [];
bldg_loader_Igiugig


%% Conventional Generator Data
%%%Diesel Cost
diesel_cost = 10; % $/gallon
diesel_cost = diesel_cost./128488.*3412.14; % Conversion to $/kWh (1gallon:128,488 Btu, 1 kWh:3412.14 Btu)
%% Financing CRAP
interest=0.08; %%%Interest rates on any loans
interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
period=10;%%%Length of any loans (years)
equity=0.2; %%%Percent of investment made by investors
required_return=.12; %%%Required return on equity investment
required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
equity_return=10;% Length at which equity + required return will be paid off (Years)
discount_rate = 0.08;
%% Tech Parameters/Costs
clc
%%%Technology Parameters
tech_select_Igiugig

%%%Including Required Return with Capital Payment (1 = Yes)
if pv_on
    [pv_mthly_debt] = capital_cost_to_monthly_cost(pv_v(1,:),equity,interest,period,required_return);
end
if ror_integer_on
    [ror_mthly_debt] = capital_cost_to_monthly_cost(ror_integer_v(1,:),equity,interest,period,required_return);
end
if ees_on
    [ees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
    [rees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
end
if el_on
    [el_mthly_debt] = capital_cost_to_monthly_cost(el_v(1,:),equity,interest,period,required_return);
end
if el_binary_on
    [el_binary_mthly_debt] = capital_cost_to_monthly_cost(el_binary_v(1,:),equity,interest,period,required_return);
end
if h2es_on
    [h2es_mthly_debt] = capital_cost_to_monthly_cost(h2es_v(1,:),equity,interest,period,required_return);
end
if pemfc_on
    [pem_mthly_debt] = capital_cost_to_monthly_cost(pem_v(1,:),equity,interest,period,required_return);
end
%%%
if rsoc_on
    [rsoc_monthly_debt] = capital_cost_to_monthly_cost(rsoc_v(5),equity,interest,period,required_return);
end
%%% Capital modifiers
pv_cap_mod = ones(1,size(pv_v,2));
% ees_mthly_debt = ones(size(pv_v,2));

%% Legacy Technologies
tech_legacy_Igiugig
 
%% DERopt
if opt_now
    %% Setting up variables and cost function
    fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf %%%Added NEM and wholesale export to the PV Section
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% General Equality Constraints
    fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
    tic
    opt_gen_equalities %%%Does not include NEM and wholesale in elec equality constraint
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% General Inequality Constraints
%     fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
%     tic
%     opt_gen_inequalities
%     elapsed = toc;
%     fprintf('Took %.2f seconds \n', elapsed)
   
    %% Legacy Diesel Constraints
    fprintf('%s: Legacy Diesel Constraints. ', datestr(now,'HH:MM:SS'))
    tic
    opt_diesel_legacy
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
   
    %% Legacy Diesel Binary Constraints
    fprintf('%s: Legacy Diesel Binary Constraints. ', datestr(now,'HH:MM:SS'))
    tic
    opt_diesel_binary_legacy
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
    
    %% H2 production Constraints
    fprintf('%s: Electrolyzer and H2 Storage Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_h2_production
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% PEMFC Constraints
    fprintf('%s: PEMFC Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_pemfc
    elapsed = toc
    fprintf('Took %.2f seconds \n', elapsed)
    %% Legacy Run of River Constraints
    fprintf('%s: Legacy Run of River Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_run_of_river
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% BRAND NEW RUN OF RIVER CONSTRAINTS
    fprintf('%s: Integer Run of River Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_integer_run_of_river
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% rsoc Constraints
    fprintf('%s: rsoc Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_rsoc
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)


    %% Optimize
    fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
    opt
    
    %% Timer
    finish = datetime('now') ; totalelapsed = toc(startsim)
    
    %% Variable Conversion
    variable_values_igiugig


    %% Metrics
    % lcoe = solution.objval/sum(elec);
    % co2_emisisons = sum(var_legacy_diesel_binary.electricity).*(1./ldiesel_binary_v(2,:)) ...
    %     .*(3.6) ... %%% Convert from kWh to MJ
    %     .*(1/135.6) ... %%% Convert from MJ to Gallons diesel fuel
    %     .*(10.19); %%%Convert from gallons to kg CO2

% co2_emisisons/sum(elec);

        % .*(0.85) ... %%% Convert from liters to kg

    %% Finding Lambda Values

end

%% Post Processing Data

% variation_fc = sum(abs(var_rsoc.rsoc_fuel_cell(2:end) - var_rsoc.rsoc_fuel_cell(1:end-1)));
% variation_e = sum(abs(var_rsoc.rsoc_electrolyzer(2:end) - var_rsoc.rsoc_electrolyzer(1:end-1)));
% 
% variation = [variation_fc, variation_e]

energy_prod_rsoc = value(var_rsoc.rsoc_fuel_cell)-value(var_rsoc.rsoc_electrolyzer);

energy_prod_refine = interp1(1:length(energy_prod_rsoc), energy_prod_rsoc, linspace(1, length(energy_prod_rsoc), length(energy_prod_rsoc)*100));

%% Temp Plots

Figure1 = figure;

area(1:length(energy_prod_refine), energy_prod_refine.*(energy_prod_refine >= 0))

hold on

area(1:length(energy_prod_refine), energy_prod_refine.*(energy_prod_refine <= 0))

title('Energy Production vs. Time')
legend('Fuel Cell', 'Electrolyzer')
ylabel('Energy Produced [kWh]')
xlabel('Time')

hold off

fig1 = gca;
exportgraphics(fig1, "ADJ_Values_RSOC.png", Resolution=600)

figure
area(1:length(var_rsoc.rsoc_e_onoff), value(var_rsoc.rsoc_fuel_cell), EdgeColor = "#0072BD")

hold on

area(1:length(var_rsoc.rsoc_electrolyzer), -value(var_rsoc.rsoc_electrolyzer), EdgeColor="#D95319")

title('Energy Production vs. Time')
legend('Fuel Cell', 'Electrolyzer')
ylabel('Energy Produced [kWh]')
xlabel('Time')

hold off



figure 

area(1:length(var_rsoc.rsoc_e_onoff), value(var_rsoc.rsoc_fc_onoff)-value(var_rsoc.rsoc_e_onoff), EdgeColor = "#0072BD")
hold on

title("On-Off State of System- Combined")
ylabel('State- Bin')
xlabel('Time')

hold off



figure

area(value(var_pem.elec), EdgeColor = "#0072BD")

hold on

title("PEMFC- Operation")
ylabel('Energy Produced [kWh]')
xlabel('Time')

hold off


%% Extra Plots and Data formatting

if isempty(var_el_binary.el_prod) | isempty(el_binary_eff)

    var_el_binary.el_prod = zeros(length(var_rsoc.rsoc_electrolyzer), 1);
    el_binary_eff = 0;
end

prods = [value(var_util.import), value(var_legacy_diesel.electricity), ...
value(var_pv.pv_elec(:, 2)), value(var_ees.ees_dchrg), ...
value(var_lees.ees_dchrg), value(var_rees.rees_dchrg), ...
value(var_ldg.ldg_elec), value(var_legacy_diesel_binary.electricity), ...
value(var_lbot.lbot_elec), value(var_run_of_river.electricity), ...
value(var_pem.elec), value(var_ror_integer.elec(:, 1)), ...
value(var_wave.electricity), value(var_rsoc.rsoc_fuel_cell)];

consums = [value(var_util.gen_export+ var_hrs.hrs_supply.*hrs_chrg_eff + var_dump.elec_dump+elec), value(var_ees.ees_chrg), value(var_lees.ees_chrg), value(var_vc.generic_cool./4), ...
value(var_lvc.lvc_cool.*vc_cop), value(el_binary_eff.*var_el_binary.el_prod), value(el_eff.*var_el.el_prod), value(h2_chrg_eff.*var_h2es.h2es_chrg), ...
value(var_rsoc.rsoc_electrolyzer)];

prods_nonempty = sum(prods, 1) ~= 0;
consums_nonempty = sum(consums, 1) ~= 0;

prods_legends = ["Imported", "Legacy Diesel", "PV", "EES", "LEES", "REES", "LDG", "Legacy Diesel Binary", "LBOT", "ROR", "PEM", "ROR-INT", "Wave", "RSOC-FC"];

consums_legends = ["Background", "EES", "LEES", "VC", "LVC", "EL_Binary", "EL", "H2_CHRG", "RSOC-E"];

% STANDARD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Figure2 = figure;
t2 = tiledlayout(2, 1);


nexttile

area(prods(:, prods_nonempty))
hold on

plot(sum(consums, 2), LineWidth= 1, Color="Black")

title("Energy Generation")
p_actual_l = prods_legends(prods_nonempty);
legend(p_actual_l)
ylabel('Energy Generated [kWh]')
xlabel('Time [h]')

hold off



nexttile

area(consums(:, consums_nonempty))

hold on

title("Energy Loads");
c_actual_l = consums_legends(consums_nonempty);
legend(c_actual_l)
ylabel('Energy Used [kWh]')
xlabel('Time [h]')
hold off

fig2 = gca;


% NORMALIZED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Figure3 = figure;
t3 = tiledlayout(2, 1);

nexttile

Norm_prod = zeros(size(prods));
Norm_consum = zeros(size(consums));

for i = 1:length(prods)
    tot_prod = sum(prods, 2);
    Norm_prod(i, :) = prods(i, :)./tot_prod(i);

    tot_consum = sum(consums, 2);
    Norm_consum(i, :) = consums(i, :)./tot_consum(i);
end

area(Norm_prod)

hold on

title("Energy Production -- Percentage")
p_actual_l = prods_legends(prods_nonempty);
legend(p_actual_l)
ylabel('Proportion')
xlabel('Time [h]')


hold off

nexttile

area(Norm_consum)

hold on

title("Energy Consumption - Percentage");
c_actual_l = consums_legends(consums_nonempty);
legend(c_actual_l)
ylabel('Proportion')
xlabel('Time [h]')
hold off

fig3 = gca;



% exportgraphics(t2, "ADJ_Total_Prod.png", Resolution=600)
% 
% exportgraphics(t3, "ADJ_Prop_Prod.png", Resolution=600)

%% H2 SOC

figure

area(value(var_h2es.h2es_soc))

hold on

title("H2-State of Charge")

ylabel('State of Charge [kWh]')
xlabel('Time [h]')

hold off

fig4 = gca;
% 
% exportgraphics(fig4, "ADJ_SOC.png", Resolution = 600)
