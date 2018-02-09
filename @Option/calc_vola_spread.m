function obj = calc_vola_spread(option,valuation_date,underlying,discount_curve,tmp_vola_surf_obj,path_static)
    obj = option;
    if ( nargin < 4)
        error('Error: No discount curve, vola surface or underlying set. Aborting.');
    end
    if ( nargin < 5)
        valuation_date = today;
    end
    if (ischar(valuation_date))
        valuation_date = datenum(valuation_date);
    end
    if ( nargin < 6)
        path_static = pwd;
    end
    % Get discount curve nodes and rate
        tmp_nodes        = discount_curve.nodes;
        tmp_rates_base   = discount_curve.getValue('base');
        comp_type_curve = discount_curve.compounding_type;
        comp_freq_curve = discount_curve.compounding_freq;
        basis_curve     = discount_curve.basis;
        
    tmp_type = obj.sub_type;
    option_type = obj.option_type;
    call_flag = obj.call_flag;
    if ( call_flag == 1 )
        moneyness_exponent = 1;
    else
        moneyness_exponent = -1;
    end

	retcode = 0;
    % Get input variables
    tmp_dtm           = (datenum(obj.maturity_date,1) - valuation_date); 
    r  = interpolate_curve(tmp_nodes,tmp_rates_base,tmp_dtm ) + ...
                                                                    obj.spread;
        
    if ( tmp_dtm < 0 )          % option already expired
        tmp_impl_vola_spread    = 0;
        theo_value_base         = 0;
    else
        X              = obj.strike;
        tmp_value               = obj.value_base;
        theo_value_base         = tmp_value;
        multi          = obj.multiplier;
        % Get underlying absolute scenario value 
        tmp_underlying_value_base       = underlying.getValue('base');

        tmp_moneyness_base      = ( tmp_underlying_value_base ./ X).^ ...
                                                            moneyness_exponent;
                
        % get implied volatility spread (choose offset to vola, 
        % that tmp_value == option_bs with input of appropriate vol):
        sigma       = tmp_vola_surf_obj.getValue('base',tmp_dtm,tmp_moneyness_base);

        % Convert q and interest rates into act/365 continuous (used by pricing)       
        r = convert_curve_rates(valuation_date,tmp_dtm,r, ...
                        comp_type_curve,comp_freq_curve,basis_curve, ...
                        'cont','annual',3);
        q = obj.get('div_yield');
        
        % Convert timefactor from Instrument basis to pricing basis (act/365)
        T  = timefactor (valuation_date, ...
                                valuation_date + tmp_dtm, obj.basis) .* 365;
        
		% Start parameter for calibration functions
		x0 = -0.0001;
		lb = -sigma + 0.0001;
		ub = [];
			
        % Valuation for European plain vanilla options
        if ( strcmpi(option_type,'European'))
            tmp_optionvalue_base        = option_bs(call_flag, ...
                                            tmp_underlying_value_base, ...
                                            X,T,r, sigma, q) .* multi;
											
		    
			% set up objective function
			objfunc = @ (x) phi_bs(x,call_flag, tmp_underlying_value_base, ...
									X, T, r, sigma, q, multi, tmp_value);
			
        % Valuation for: (European) Asian options
        elseif ( strcmpi(option_type,'Asian')  ) % calling Kemna-Vorst or Levy option pricing model
            avg_rule = option.averaging_rule;
            avg_monitoring = option.averaging_monitoring;
            % distinguish Asian options:
            if ( strcmpi(avg_rule,'geometric') && strcmpi(avg_monitoring,'continuous') )
                % Call Kemna-Vorst90 pricing model
                tmp_optionvalue_base = option_asian_vorst90(call_flag,tmp_underlying_value_base, ...
												X,T,r,sigma,q) .* multi;
                % set up objective function
				objfunc = @ (x) phi_asian_vorst90(x,call_flag, tmp_underlying_value_base, ...
										X, T, r, sigma, q, multi, tmp_value);
	
            elseif ( strcmpi(avg_rule,'arithmetic') && strcmpi(avg_monitoring,'continuous') )
                % Call Levy pricing model
                tmp_optionvalue_base = option_asian_levy(call_flag,tmp_underlying_value_base, ...
													X,T,r, sigma,q) .* multi;
								
				% set up objective function
				objfunc = @ (x) phi_asian_levy(x,call_flag, tmp_underlying_value_base, ...
										X, T, r, sigma, q, multi, tmp_value);
					
            else
                error('Unknown Asian averaging rule >>%s<< or monitoring >>%s<<',avg_rule,avg_monitoring);
            end
            
        % Valuation for American plain vanilla options
        elseif ( strcmpi(option_type,'American'))
            if ( strcmpi(obj.pricing_function_american,'Willowtree') )
                tmp_optionvalue_base        = option_willowtree(call_flag,1, ...
                                                tmp_underlying_value_base, ...
                                                X,T,r, sigma,q, ...
                                                option.timesteps_size, ...
                                                option.willowtree_nodes, ...
                                                path_static) .* multi;
												
				% set up objective function		
				objfunc = @ (x) phi_willowtree (x,call_flag,1,tmp_underlying_value_base, ...
									X,T,r, sigma,q, ...
									option.timesteps_size,option.willowtree_nodes, ...
									multi,tmp_value,path_static);
			elseif ( strcmpi(obj.pricing_function_american,'CRR') )
				treenodes 	= round(T/option.timesteps_size);
                tmp_optionvalue_base	= pricing_option_cpp(2,logical(call_flag),tmp_underlying_value_base, ...
                                    X,T,r, sigma,q,treenodes);
				tmp_optionvalue_base = tmp_optionvalue_base .* multi;
				
				% set up objective function		
				objfunc = @ (x) phi_crr (x,2,logical(call_flag),tmp_underlying_value_base, ...
                                    X,T,r, sigma,q,treenodes,multi,tmp_value);
						
            else    % use Bjerksund and Stensland approximation
                tmp_optionvalue_base  = option_bjsten(call_flag, ...
                                        tmp_underlying_value_base, X, ...
                                        T, r, sigma, q) .* multi;
										
				% set up objective function		
				objfunc = @ (x) phi_bjsten (x,call_flag, ...
                                        tmp_underlying_value_base, X, ...
                                        T, r, sigma, q, multi,tmp_value);						
            end
 
        % Valuation for European Barrier Options:
        elseif ( strcmpi(option_type,'Barrier'))   % calling Barrier option pricing model
            tmp_optionvalue_base	= option_barrier(call_flag,obj.upordown,obj.outorin,...
                                        tmp_underlying_value_base, X, ...
                                        obj.barrierlevel, T, ...
                                        r, sigma, q, obj.rebate) .* multi;
			% set up objective function		
			objfunc = @ (x) phi_barrier (x,call_flag, ...
                                        obj.upordown,obj.outorin, ...
                                        tmp_underlying_value_base, X, ...
                                        obj.barrierlevel, T, ...
                                        r, sigma, q, obj.rebate, multi,tmp_value);							
		
		% Valuation for European Binary Options:
	    elseif ( strcmpi(option_type,'Binary'))   % calling Binary option pricing model
            tmp_optionvalue_base	= option_binary(call_flag, obj.binary_type, tmp_underlying_value_base, ...
                            X, obj.payoff_strike, T, r, sigma, q) .* multi;
							
			% set up objective function		
			objfunc = @ (x) phi_binary (x,call_flag, obj.binary_type,  ...
							tmp_underlying_value_base, X, obj.payoff_strike,  ...
                            T, r, sigma,  q, multi, tmp_value);	
							
		% Valuation for European Lookback Options:
	    elseif ( strcmpi(option_type,'lookback'))   % calling Lookback option pricing model
            tmp_optionvalue_base	= option_lookback(call_flag, obj.lookback_type, tmp_underlying_value_base, ...
                            X, obj.payoff_strike, T, r, sigma, q) .* multi;
							
			% set up objective function		
			objfunc = @ (x) phi_lookback (x,call_flag, obj.lookback_type,  ...
							tmp_underlying_value_base, X, obj.payoff_strike,  ...
                            T, r, sigma,  q, multi, tmp_value);	
							
        else
            tmp_impl_vola_spread = 0.0;
        end
		% call generic calibration function
		[tmp_impl_vola_spread retcode] = calibrate_generic(objfunc,x0,lb,ub);
				
        % error handling of calibration:
        if ( tmp_impl_vola_spread < -98 || retcode > 0)
            fprintf(' Calibration failed for >>%s<< with Retcode 255. Setting market value to THEO/Value\n',obj.id);
            theo_value_base = tmp_optionvalue_base;
            tmp_impl_vola_spread    = 0; 
        else
            %disp('Calibration seems to be successful.. checking');
            %tmp_value
            if (  strcmpi(option_type,'European'))
                tmp_new_val     = option_bs(call_flag,tmp_underlying_value_base, ...
                                X,T,r, sigma + tmp_impl_vola_spread,q) .* multi;
            elseif ( strcmpi(option_type,'Asian')  ) % calling Kemna-Vorst or Levy option pricing model
                avg_rule = option.averaging_rule;
                avg_monitoring = option.averaging_monitoring;
                % distinguish Asian options:
                if ( strcmpi(avg_rule,'geometric') && strcmpi(avg_monitoring,'continuous') )
                    % Call Kemna-Vorst90 pricing model
                    tmp_new_val	= option_asian_vorst90(call_flag,tmp_underlying_value_base, ...
                                    X,T,r, sigma + tmp_impl_vola_spread,q) .* multi;
									
                elseif ( strcmpi(avg_rule,'arithmetic') && strcmpi(avg_monitoring,'continuous') )
                    % Call Levy pricing model
                    tmp_new_val	= option_asian_levy(call_flag,tmp_underlying_value_base, ...
                                    X,T,r, sigma + tmp_impl_vola_spread,q) .* multi;
									
                else
                    error('Unknown Asian averaging rule >>%s<< or monitoring >>%s<<',avg_rule,avg_monitoring);
                end
            elseif (  strcmpi(option_type,'American'))   
                if ( strcmpi(obj.pricing_function_american,'Willowtree') )
                    tmp_new_val = option_willowtree(call_flag,1, ...
                                tmp_underlying_value_base,X,T, ...
                                r,sigma + tmp_impl_vola_spread, ...
                                obj.div_yield,obj.timesteps_size, ...
                                obj.willowtree_nodes,path_static) .* multi;
				elseif ( strcmpi(obj.pricing_function_american,'CRR') )
					treenodes 	= round(T/option.timesteps_size);
					tmp_new_val	= pricing_option_cpp(2,logical(call_flag),tmp_underlying_value_base, ...
										X,T,r, sigma + tmp_impl_vola_spread, ...
										option.div_yield,treenodes);
					tmp_new_val = tmp_new_val .* multi;
                else
                    tmp_new_val = option_bjsten(call_flag, ...
                                tmp_underlying_value_base, X, T, ...
                                r, sigma + tmp_impl_vola_spread, ...
                                obj.div_yield) .* multi;
                end
				
            elseif ( strcmpi(option_type,'Barrier'))   % calling Barrier option pricing model
                    tmp_new_val = option_barrier(call_flag,obj.upordown,obj.outorin,...
                                    tmp_underlying_value_base, X, ...
                                    obj.barrierlevel, T, ...
                                    r, sigma + tmp_impl_vola_spread, ...
                                    q, obj.rebate) .* multi;
									
			elseif ( strcmpi(option_type,'Binary'))   % calling Binary option pricing model
					tmp_new_val= option_binary(call_flag, obj.binary_type, tmp_underlying_value_base, ...
                            X, obj.payoff_strike, T, r, ...
                            sigma  + tmp_impl_vola_spread, q) .* multi;
							
			elseif ( strcmpi(option_type,'Lookback'))   % calling Lookback option pricing model
					tmp_new_val= option_lookback(call_flag, obj.lookback_type, tmp_underlying_value_base, ...
                            X, obj.payoff_strike, T, r, ...
                            sigma  + tmp_impl_vola_spread, q) .* multi;
							
            end
            if ( abs(tmp_value - tmp_new_val) < 0.05 )
                %disp('Calibration successful.');
                theo_value_base = tmp_value;
            else
                fprintf(' Calibration failed for >>%s<<, although it converged.. Setting market value to THEO/Value\n',obj.id);
                theo_value_base = tmp_optionvalue_base;
                tmp_impl_vola_spread = 0; 
            end
        end
     
    end   % close loop if tmp_dtm < 0
    
      
    % store theo_value vector in appropriate class property
    obj.vola_spread = tmp_impl_vola_spread;
    obj.value_base = theo_value_base;
	obj.calibration_flag = true;
end


%-------------------------------------------------------------------------------
%------------------- Begin Definition of Objective Functions--------------------
 
 
% ----------   Definition BlackScholes Objective Function:	    
function obj = phi_bs (x,putcallflag,S,X,T,rf,sigma,q,multiplicator,market_value)
        % This is where we computer the sum of the square of the errors.
        % The parameters are in the vector p, which for us is a two by one.	
        tmp_option_value = option_bs(putcallflag,S,X,T,rf,sigma+x,q) ...
                           .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition AsianLevy Objective Function:	    
function obj = phi_asian_levy (x,putcallflag,S,X,T,rf,sigma,q,multiplicator,market_value)
        % This is where we computer the sum of the square of the errors.
        % The parameters are in the vector p, which for us is a two by one.	
        tmp_option_value = option_asian_levy(putcallflag,S,X,T,rf,sigma+x,q) ...
                           .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition AsianVorst Objective Function:	    
function obj = phi_asian_vorst90 (x,putcallflag,S,X,T,rf,sigma,q,multiplicator,market_value)
        % This is where we computer the sum of the square of the errors.
        % The parameters are in the vector p, which for us is a two by one.	
        tmp_option_value = option_asian_vorst90(putcallflag,S,X,T,rf,sigma+x,q) ...
                           .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition BJSten Objective Function:	    
function obj = phi_bjsten (x,putcallflag,S,X,T,rf,sigma,div,multiplicator,market_value)
        % This is where we computer the sum of the square of the errors.
        % The parameters are in the vector p, which for us is a two by one.	
        tmp_option_value = option_bjsten(putcallflag,S,X,T,rf,sigma+x,div) ...
                           .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition American Willowtree Objective Function:	    
function obj = phi_willowtree (x,putcallflag,americanflag,S,X,T,rf,sigma,q, ...
						stepsize,nodes,multiplicator,market_value,path_static)
		% This is where we computer the sum of the square of the errors.
		% The parameters are in the vector p, which for us is a two by one.	
		tmp_option_value = option_willowtree(putcallflag,americanflag, ...
						S,X,T,rf,sigma+x,q, ...
						stepsize,nodes,path_static) .* multiplicator;
		obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition American CRR Objective Function:	    
function obj = phi_crr (x,type,call_flag,S,X,T,r,sigma,q,treenodes,multi,market_value)
		% This is where we computer the sum of the square of the errors.
		% The parameters are in the vector p, which for us is a two by one.	
		tmp_option_value = pricing_option_cpp(type,call_flag,S,X,T,r, ...
											sigma+x,q,treenodes);
		tmp_option_value = tmp_option_value	.* multi;
		obj = abs( tmp_option_value  - market_value)^2;
end

									
% ----------   Definition Barrier Objective Function:	    
function obj = phi_barrier (x,putcallflag,upordown,outorin,S,X,H,T,rf,sigma,q,rebate, ...
                                            multiplicator,market_value)
        % set up objective function
        tmp_option_value = option_barrier(putcallflag,upordown,outorin,S,X,H, ...
                            T,rf,sigma + x,q,rebate) .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition Binary Objective Function:	    
function obj = phi_binary (x,call_flag, binary_type,S, X1, X2, T, rf, sigma,  ...
                            q, multiplicator,market_value)
        % set up objective function
        tmp_option_value = option_binary(call_flag, binary_type, S, X1, X2, ...
							T, rf, sigma + x, q) .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end

% ----------   Definition Lookback Objective Function:	    
function obj = phi_lookback (x,call_flag, lookback_type,S, X1, X2, T, rf, sigma,  ...
                            q, multiplicator,market_value)
        % set up objective function
        tmp_option_value = option_lookback(call_flag, lookback_type, S, X1, X2, ...
							T, rf, sigma + x, q) .* multiplicator;
        obj = abs( tmp_option_value  - market_value)^2;
end
