imported_gas_kWh= sum((var_sofc.sofc_elec./sofc_v(3)))+...
                  sum(var_gwh.gwh_gas) + sum(var_gsph.gsph_gas)+...
                  sum(misc_gas);
              
imported_gas_dollar=sum(ng_cost * var_gwh.gwh_gas)+...
                    sum(ng_cost * var_gsph.gsph_gas)+...
                    sum(ng_cost * var_sofc.sofc_elec./sofc_v(3))+...
                    sum(ng_cost * misc_gas);
                
imported_elec_kWh = sum(var_util.import);

import_TDV = sum(var_util.import.*tdv_elec) + ...
             sum((var_sofc.sofc_elec./sofc_v(3)).*tdv_gas.*tdv_gas_mod) +...
             sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
             sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod) + ...
             sum(misc_gas.*tdv_gas.*tdv_gas_mod);

export_TDV = sum(var_pv.pv_nem.*tdv_elec) +...
             sum(var_rees.rees_dchrg_nem.*tdv_elec);