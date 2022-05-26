%% General equalities
%% Building Electrical Energy Balances
%%For each building k, all timesteps t
%Vectorized
if ~isempty(elec)
    Constraints = [Constraints
        (var_util.import + var_pv.pv_elec + var_ees.ees_dchrg + var_lees.ees_dchrg + var_rees.rees_dchrg + var_lrees.rees_dchrg + var_sofc.sofc_elec == elec + var_ees.ees_chrg + var_lees.ees_chrg + var_erwh.erwh_elec + var_ersph.ersph_elec):'BLDG Electricity Balance'];
end

%% Building Hot water Balances
%For each building k, all timesteps t
if ~isempty(dhw)
    Constraints = [Constraints
        (var_erwh.erwh_elec.*erwh_eff + var_gwh.gwh_gas.*gwh_eff + var_sofc.sofc_wh + var_tes.tes_dchrg== dhw):'BLDG HotWater Balance'];
end  

%% Building Heat Balances
%For each building k, all timesteps t
if ~isempty(heat)
    Constraints = [Constraints
        (var_gsph.gsph_gas.*gsph_eff + var_ersph.ersph_elec.*ersph_eff == heat):'BLDG Heat Balance'];
end  