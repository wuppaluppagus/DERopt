%%%% Parameter Sweeps %%%%%%%%

clear all; close all; clc ; started_at = datetime('now'); startsim = tic;
%% Variables for RSOC

max_output = 1;
fuel_cell_eff = .43;

elec_cell_eff = .74;

OaM = .01;

Capital = 5300;

Ramp_rate_fc = .9;

j = .4;

V_fc = 0.75;

V_e = 1.3;

Ramp_rate_e = .8;

Param_cost = 1000;

params_swept = [max_output, fuel_cell_eff, elec_cell_eff, OaM, Capital, Ramp_rate_fc, j, V_fc, V_e, Ramp_rate_e]';

%% Sweep Parameters

param_1 = linspace(10, 100,2);
% 
% Param_2= linspace(1.5, 3,10);
% 
% [X, Y] = meshgrid(Param_1, Param_2);


capacity_storage = zeros(1, numel(param_1));
%% Data Table Creation

for i = 1:numel(param_1)
    disp(i)
    params_swept = [max_output, fuel_cell_eff, elec_cell_eff, OaM, Param_cost, Ramp_rate_fc, j, V_fc, V_e, Ramp_rate_e]';
    cost = param_1(i);

    playground_igiugig

    % Data_Storage(i, :) = (value(var_rsoc.rsoc_fuel_cell)-value(var_rsoc.rsoc_electrolyzer))';
    capacity_storage(i) = value(var_rsoc.rsoc_capacity);
end

plot(1:length(capacity_storage(i, :)), capacity_storage)