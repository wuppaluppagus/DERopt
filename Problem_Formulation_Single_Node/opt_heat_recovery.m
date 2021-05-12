%%% Considering heat recovery

if (~isempty(dg_legacy) ) && (~isempty(hr_legacy)) %%%If a generator and heat recovery system exist or can be adopted
    
    %%%Topping Cycle Coefficients
    if ~isempty(dg_legacy)
        for ii = 1:size(dg_legacy,2)
            ldg_coef_1 = dg_legacy(9,i)*ones(T,1);
            ldg_coef_2 = dg_legacy(10,i)*ones(T,2);
        end
    end
    
    %%%Bottoming cycle coefficients
    if ~isempty(bot_legacy)
        for ii = 1:size(bot_legacy,2)
            bot_coef(:,ii) = (1/(bot_legacy(4,ii)*bot_legacy(5,ii)))*ones(T,1);
        end
    end
    
    
    %%%Heat recovery
    Constraints = [Constraints
        sum(bot_coef.*var_lbot.lbot_elec,2) ... %%%Bottoming cycle / Steam turbine
        <= (sum(ldg_coef_1.*var_ldg.ldg_elec,2) + sum(ldg_coef_2,2))]; %%%Heat generated by any legacy systems
    
    
end