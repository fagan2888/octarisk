% setting attribute values
function obj = set(obj, varargin)
  % A) Specify fieldnames <-> types key/value pairs
  typestruct = struct(...
                'type', 'char' , ...
                'basis', 'numeric' , ...
                'value_mc', 'numeric' , ...
                'timestep_mc', 'special' , ...
                'value_stress', 'special' , ...
                'value_base', 'numeric' , ...
                'exposure_base', 'numeric' , ...
                'exposure_stress', 'special' , ...
                'exposure_mc', 'special' , ...
                'name', 'char' , ...
                'id', 'char' , ...
                'sub_type', 'char' , ...
                'model', 'char' , ...
                'asset_class', 'char' , ...
                'currency', 'char' , ...
                'sii_equity_type', 'numeric', ...
                'description', 'char' , ...
                'idio_vola', 'numeric' , ...
                'sensitivities', 'numeric' , ...
                'riskfactors', 'cell' , ...
                'cf_values', 'numeric' , ...
                'YYYREPLACEINSTRUMENTATTRIBUTEYYY', 'char' , ...
                'liquidity_class', 'char' , ...
				'issuer', 'char' , ...
				'counterparty', 'char' , ...
				'XXXREPLACEINSTRUMENTATTRIBUTEXXX', 'char' , ...
				'designated_sponsor', 'char' , ...
				'market_maker', 'char' , ...
				'custodian_bank_underlyings', 'char' , ...
				'country_of_origin', 'char' , ...
				'fund_replication', 'char' , ...
                'cf_dates', 'numeric' , ...
                'underlyings', 'cell' , ... 
                'x_coord', 'numeric' , ...
                'y_coord', 'numeric' , ...
                'z_coord', 'numeric' , ...
                'shock_type', 'cell' , ... 
                'payout_yield', 'numeric' , ...
				'div_month', 'numeric' , ...
                'sensi_prefactor', 'numeric' , ...
                'sensi_exponent', 'numeric' , ...
                'use_value_base', 'boolean', ...
                'use_taylor_exp', 'boolean', ...
                'sensi_cross', 'numeric', ...
                'region_id', 'cell', ...
				'rating_id', 'cell', ...
				'style_id', 'cell', ...
				'duration_id', 'cell', ...
				'country_id', 'cell', ...
				'country_values', 'numeric', ...
				'esg_score', 'numeric', ...
				'region_values', 'numeric', ... 
				'style_values', 'numeric', ... 
				'rating_values', 'numeric', ...
				'duration_values', 'numeric' ...
               );
  % B) store values in object
  if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
    error ('set: expecting property/value pairs');
  end
  
  while (length (varargin) > 1)
    prop = varargin{1};
    prop = lower(prop);
    val = varargin{2};
    varargin(1:2) = [];
    % check, if property is an existing field
    if (sum(strcmpi(prop,fieldnames(typestruct)))==0)
        fprintf('set: not an allowed fieldname >>%s<< with value >>%s<< :\n',prop,any2str(val));
        fieldnames(typestruct)
        error ('set: invalid property of %s class: >>%s<<\n',class(obj),prop);
    end
    % get property type:
    type = typestruct.(prop);
    % input checks and validation
    retval = return_checked_input(obj,val,prop,type);
    % store property in object
    obj.(prop) = retval;
  end
end   
