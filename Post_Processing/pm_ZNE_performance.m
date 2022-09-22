imported_gas_kWh= sum((var_sofc.sofc_elec./sofc_v(3)))+...
                  sum(var_gwh.gwh_gas) + sum(var_gsph.gsph_gas);
              
imported_gas_dollar =sum(ng_cost * var_gwh.gwh_gas)+...
                    sum(ng_cost * var_gsph.gsph_gas)+...
                    sum(ng_cost * var_sofc.sofc_elec./sofc_v(3));
                
imported_elec_kWh = sum(var_util.import);
imported_elec_dollar = sum(var_util.import.*day_multi.*import_price(:,index));

import_TDV = sum(var_util.import.*tdv_elec) + ...
             sum((var_sofc.sofc_elec./sofc_v(3)).*tdv_gas.*tdv_gas_mod) +...
             sum(var_gwh.gwh_gas.*tdv_gas.*tdv_gas_mod) + ...
             sum(var_gsph.gsph_gas.*tdv_gas.*tdv_gas_mod);

export_TDV = sum(var_pv.pv_nem.*tdv_elec) +...
             sum(var_rees.rees_dchrg_nem.*tdv_elec);
         
%% Avoided costs
pv_acc_dollar =sum(-day_multi.*export_price(:,index).*var_pv.pv_nem);

rees_acc_dollar = sum(day_multi.*(ees_v(3) - export_price(:,index)).*var_rees.rees_dchrg_nem);

%% plotting codes
days_to_look_at = 2;
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure  
hold on
plot_dt = [var_util.import ...
    var_pv.pv_elec ...
    var_ees.ees_dchrg...
    var_rees.rees_dchrg ...
    var_sofc.sofc_elec ];
area(time,plot_dt)
plot(time,elec,'LineWidth',2,'Color','k')
legend({'Grid','PV','EES','REES','SOFC'},'Location','northwest','Orientation','horizontal')
xlim(xlim_range)
datetick('x','ddd','KeepTicks')
box on
grid on
set(gca,'FontSize',14,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
hold off
%%
figure
hold on
plot_dt = [ elec  ...
    var_ees.ees_chrg   ...
    var_rees.rees_chrg ...
    var_erwh.erwh_elec ...
    var_ersph.ersph_elec]

area(time,plot_dt)
xlim(xlim_range)
hold off

%% RJF plotting codes
figure 
days_to_look_at = 2;
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure 
hold on
plot_dt = [var_util.import ...
    var_pv.pv_elec ...
    var_ees.ees_dchrg...
    var_rees.rees_dchrg ...
    var_rees.rees_dchrg_nem ...
    var_pv.pv_nem ...
    var_sofc.sofc_elec ];
area(time,plot_dt)
plot(time,elec,'LineWidth',2,'Color','k')
legend({'Grid','PV','EES','REES','REES EXP','PV EXP','SOFC'},'Location','northwest','Orientation','horizontal')
xlim(xlim_range)
datetick('x','ddd','KeepTicks')
box on
grid on
set(gca,'FontSize',12,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
hold off

%% plotting codes - Load
days_to_look_at = 20;
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure  
hold on
plot_dt = [var_ees.ees_dchrg...
           var_ees.ees_chrg...
                 ];
area(time,plot_dt)
plot(time,elec,'LineWidth',2,'Color','k')
plot(time,var_util.import,'LineWidth',2,'Color','b')
plot(time,var_ees.ees_soc,'LineWidth',2,'Color','m')
legend({'EES-DC','EES-C'},'Location','northwest','Orientation','horizontal')
xlim(xlim_range)
datetick('x','ddd','KeepTicks')
box on
grid on
set(gca,'FontSize',14,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
hold off

%%
days_to_look_at = 20;
xlim_range = [time(24*(days_to_look_at-1)+1)    time(24*days_to_look_at+ 24*6) ];
figure 
hold on
plot_dt = [var_ees.ees_dchrg...
       var_rees.rees_dchrg...
       var_util.import...   
       var_rees.rees_dchrg_nem ...
    ]
area(time,plot_dt)
plot(time,var_pv.pv_elec+var_pv.pv_nem+var_rees.rees_chrg,'LineWidth',4,'Color','g')
% plot(time,var_util.import,'LineWidth',2,'Color','c')
plot(time,var_rees.rees_chrg,'LineWidth',2,'Color','m')
plot(time,elec,'LineWidth',2,'Color','k')
plot(time,var_rees.rees_dchrg,'LineWidth',4,'Color','c')
legend({'EES-DC','REES-DC','Grid','REES-NEM','PV','REES-C','load'},'Location','northwest','Orientation','horizontal')
xlim(xlim_range)
datetick('x','ddd','KeepTicks')
box on
grid on
set(gca,'FontSize',12,...
    'XTick',[round(min(time)) + 0.5 :1: round(max(time)) + 0.5])
hold off