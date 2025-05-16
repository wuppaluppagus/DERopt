
e_ramprate = rsoc_v(end);
a = 5;
if rsoc_on
max_switch = 10;

Constraints = [Constraints 
    (var_rsoc.rsoc_fuel_cell/rsoc_v(8) + var_rsoc.rsoc_electrolyzer/rsoc_v(9) <= rsoc_v(7)*var_rsoc.rsoc_capacity): 'RSOC Current Density Balance'
    
    (var_rsoc.rsoc_fuel_cell <= max(elec)*var_rsoc.rsoc_fc_onoff): 'Fuel Cell Contraint'
    (.9*rsoc_v(8)*rsoc_v(7)*var_rsoc.rsoc_capacity - max(elec)*(1-var_rsoc.rsoc_fc_onoff) <= var_rsoc.rsoc_fuel_cell): 'Fuel Cell Constraint'
    
    (var_rsoc.rsoc_electrolyzer<= max(elec)*(var_rsoc.rsoc_e_onoff)): 'Electrolyzer Contraint'
    (.2*rsoc_v(9)*rsoc_v(7)*var_rsoc.rsoc_capacity - max(elec)*(1-var_rsoc.rsoc_e_onoff) <= var_rsoc.rsoc_electrolyzer): 'Electrolyzer Constraint'
    
    (var_rsoc.rsoc_fc_onoff + var_rsoc.rsoc_e_onoff <=1): 'Onoff constraint'

    (var_rsoc.rsoc_e_onoff(2:end) - var_rsoc.rsoc_e_onoff(1:end-1) <= var_rsoc.e_start(2:end)): 'start constraint'
    (var_rsoc.rsoc_fc_onoff(2:end) - var_rsoc.rsoc_fc_onoff(1:end-1) <= var_rsoc.e_start(2:end)): 'start constraint'
        
    % (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_fuel_cell(2:end) - var_rsoc.rsoc_fuel_cell(1:end-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity+.1*rsoc_v(1)*var_rsoc.e_start(2, end)):'RSOC Fuel Cell Ramp Rate'
    % (-e_ramprate*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_electrolyzer(2:end) - var_rsoc.rsoc_electrolyzer(1:end-1) <= e_ramprate*rsoc_v(1)*var_rsoc.rsoc_capacity+.1*rsoc_v(1)*var_rsoc.e_start(2, end)):'RSOC Electrolyzer Ramp Rate'

    % ((-rsoc_v(6)*rsoc_v(7)*rsoc_v(8)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_fuel_cell(2:end) - var_rsoc.rsoc_fuel_cell(1:end-1)) & (var_rsoc.rsoc_fuel_cell(2:end) - var_rsoc.rsoc_fuel_cell(1:end-1) <= (rsoc_v(6)+.1*var_rsoc.e_start(2:end))*rsoc_v(7)*rsoc_v(8)*var_rsoc.rsoc_capacity)):'RSOC Fuel Cell Ramp Rate'
    % ((-rsoc_v(10)*rsoc_v(7)*rsoc_v(9)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_electrolyzer(2:end) - var_rsoc.rsoc_electrolyzer(1:end-1)) & (var_rsoc.rsoc_electrolyzer(2:end) - var_rsoc.rsoc_electrolyzer(1:end-1) <= (rsoc_v(10)+.1*var_rsoc.e_start(2:end))*rsoc_v(7)*rsoc_v(9)*var_rsoc.rsoc_capacity)):'RSOC Electrolyzer Ramp Rate'
    % 

    ];

   
    % for i = 2:(T-a)
    % 
    %     Constraints = [Constraints
    %         (a*(var_rsoc.e_start(i)) <= sum(var_rsoc.rsoc_fc_onoff(i+1:i+a)+var_rsoc.rsoc_e_onoff(i+1:i+a))): 'Min-time constraints'
    %     ];
    % end
end 

%rsoc_v(6) = .8
%e_ramprate = .5