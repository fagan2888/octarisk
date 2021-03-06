function obj = calc_sensitivities (retail, valuation_date, discount_curve)
obj = retail;

if ischar(valuation_date)
    valuation_date = datenum(valuation_date,1);
end

% A) get bond related attributes
% Get base cf values and dates
cashflow_dates  = obj.cf_dates;
cashflow_values = obj.getCF('base');

if ( isempty(cashflow_values) )
    error('No cash flow values set. CF rollout done?');    
end


% B) get discount curve attributes
    nodes_discount    = discount_curve.nodes;
    rates_discount    = discount_curve.getValue('base');

     
% C.1) Effective Dur/Convex: CF rollout required special case FRN or SWAP_FLOAT
% all bonds with fixed cashflows (FRB, SWAP_FIXED, CF Instruments)
  % C.2) calculate effective sensitivities for all fixed CF bonds
    % adjust rates_discount for shocks
    %   1. row: base value
    %   2. row: -obj.ir_shock
    %   3. row: +obj.ir_shock
    %   4. row: -0.0001 (DV01)
    %   5. row: +0.0001 (DV01)
    rates_eff_sensis = [rates_discount; ...
                    rates_discount - obj.ir_shock; ...
                    rates_discount + obj.ir_shock; ...
                    rates_discount - 0.0001; ...
                    rates_discount + 0.0001];
                    
    % calculate values under shock
    c = discount_curve.set('rates_stress',rates_eff_sensis);   
    obj_tmp = obj;
    obj_tmp = obj_tmp.rollout('stress',valuation_date,c);                              
    obj_tmp = obj_tmp.calc_value(valuation_date,'stress',c);              
    value_vec = obj_tmp.getValue('stress');               
    theo_value              = value_vec(1);
    theo_value_100bpdown    = value_vec(2);
    theo_value_100bpup      = value_vec(3);
    theo_value_1bpdown      = value_vec(4);
    theo_value_1bpup        = value_vec(5);
    
    obj.eff_duration = ( theo_value_100bpdown - theo_value_100bpup ) ...
                    / ( 2 * theo_value * obj.ir_shock );
    % spread duration for FRB equals effective duration:
    obj.spread_duration = obj.eff_duration;     
    
    % calculate and set effective convexity based on 100bp down / upshift:
    obj.eff_convexity = ( theo_value_100bpdown + theo_value_100bpup - 2 * theo_value ) ...
                    / ( theo_value * obj.ir_shock^2  ); 
    
    % calculate and set DV01 duration based on 1bp down / upshift:
    obj.dv01 = 0.5 * abs(theo_value_1bpdown - theo_value_1bpup);
    % calculating pv01 using upshock only
    obj.pv01 = theo_value_1bpup - theo_value;                           
   
end


