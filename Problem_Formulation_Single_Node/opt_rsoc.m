
if rsoc_on
max_switch = 10;

Constraints = [Constraints 
    (var_rsoc.rsoc_fuel_cell/rsoc_v(8) + var_rsoc.rsoc_electrolyzer/rsoc_v(9) <= rsoc_v(7)*var_rsoc.rsoc_capacity): 'RSOC Current Density Balance'
    % (var_rsoc.rsoc_fuel_cell <= rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Fuel Cell Energy Balance'
    % (var_rsoc.rsoc_electrolyzer <= rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Electrolyzer Energy Balance'
    (var_rsoc.rsoc_fuel_cell <= max(elec)*var_rsoc.rsoc_onoff): 'Fuel Cell Contraint'
    (.5*var_rsoc.rsoc_capacity - max(elec)*(1-var_rsoc.rsoc_onoff) <= var_rsoc.rsoc_fuel_cell): 'Fuel Cell Cnnstraint'
    (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_fuel_cell(2:end) - var_rsoc.rsoc_fuel_cell(1:end-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Fuel Cell Ramp Rate'
    (-rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity <= var_rsoc.rsoc_electrolyzer(2:end) - var_rsoc.rsoc_electrolyzer(1:end-1) <= rsoc_v(6)*rsoc_v(1)*var_rsoc.rsoc_capacity):'RSOC Electrolyzer Ramp Rate'];
%     (sum(var_rsoc.rsoc_onoff(2:end) - var_rsoc.rsoc_onoff(1:end-1), 2) <= max_switch):  'Switching condition'];

end 