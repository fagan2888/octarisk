% setting attribute values
function obj = set(obj, varargin)
  % A) Specify fieldnames <-> types key/value pairs
  typestruct = struct(...
                'id', 'char', ...
                'name', 'char', ...
                'description', 'char', ...
                'type', 'char', ...
                'currency', 'char', ...
                'quantity', 'numeric', ...
                'positions', 'struct' , ... 
                'port_id', 'char', ...
                'value_mc', 'special' , ...
                'value_stress', 'special' , ...
                'value_base', 'numeric' , ...
                'cf_values_mc', 'special' , ...
                'cf_values_stress', 'numeric' , ...
                'cf_values', 'numeric' , ...
                'cf_dates', 'numeric' , ...
                'exposure_base', 'numeric' , ...
                'exposure_stress', 'special' , ...
                'exposure_mc', 'special' , ...
                'timestep_mc', 'special' , ...
                'timestep_mc_cf', 'special' , ...
                'var_confidence', 'numeric' , ...
                'varhd_abs', 'numeric' , ...
                'expshortfall_abs', 'numeric' , ...
                'expshortfall_rel', 'numeric' , ...
                'varhd_rel', 'numeric' , ...
                'var_abs', 'numeric' , ...
                'var_positionsum', 'numeric' , ...
                'decomp_varhd', 'numeric' , ...
                'diversification_ratio', 'numeric' , ...
                'valuation_date', 'numeric' , ...
                'reporting_date', 'numeric' , ...
                'scenario_numbers', 'numeric' , ...
                'mean_shock', 'numeric' , ...
                'std_shock', 'numeric' , ...
                'skewness_shock', 'numeric' , ...
                'kurtosis_shock', 'numeric' , ...
                'var50_abs', 'numeric' , ...
                'var70_abs', 'numeric' , ...
                'var84_abs', 'numeric' , ...
                'var90_abs', 'numeric' , ...
                'var95_abs', 'numeric' , ...
                'var975_abs', 'numeric' , ...
                'var99_abs', 'numeric' , ...
                'var999_abs', 'numeric' , ...
                'var9999_abs', 'numeric' , ...
                'marg_var', 'numeric' , ...
                'incr_var', 'numeric' , ...
                'tpt_1', 'char', ...
                'tpt_2', 'char', ...
                'tpt_3', 'char', ...
                'tpt_4', 'char', ...
                'tpt_5', 'numeric', ...
                'tpt_6', 'date', ...
                'tpt_7', 'date', ...
                'tpt_8', 'numeric', ...
                'tpt_8b', 'numeric', ...
                'tpt_9', 'numeric', ...
                'tpt_10', 'numeric', ...
                'tpt_11', 'char', ...
                'tpt_12', 'char', ...
                'tpt_13', 'numeric', ...
                'tpt_14', 'char', ...
                'tpt_15', 'numeric', ...
                'tpt_16', 'char', ...
                'tpt_17', 'char', ...
                'tpt_17b', 'char', ...
                'tpt_18', 'numeric', ...
                'tpt_19', 'numeric', ...
                'tpt_20', 'numeric', ...
                'tpt_21', 'char', ...
                'tpt_22', 'numeric', ...
                'tpt_23', 'numeric', ...
                'tpt_24', 'numeric', ...
                'tpt_25', 'numeric', ...
                'tpt_26', 'numeric', ...
                'tpt_27', 'numeric', ...
                'tpt_28', 'numeric', ...
                'tpt_29', 'numeric', ...
                'tpt_30', 'numeric', ...
                'tpt_31', 'numeric', ...
                'tpt_32', 'char', ...
                'tpt_33', 'numeric', ...
                'tpt_34', 'char', ...
                'tpt_35', 'char', ...
                'tpt_36', 'char', ...
                'tpt_37', 'char', ...
                'tpt_38', 'numeric', ...
                'tpt_39', 'date', ...
                'tpt_40', 'char', ...
                'tpt_41', 'numeric', ...
                'tpt_42', 'char', ...
                'tpt_43', 'date', ...
                'tpt_44', 'char', ...
                'tpt_45', 'numeric', ...
                'tpt_46', 'char', ...
                'tpt_47', 'char', ...
                'tpt_48', 'numeric', ...
                'tpt_49', 'char', ...
                'tpt_50', 'char', ...
                'tpt_51', 'numeric', ...
                'tpt_52', 'char', ...
                'tpt_53', 'numeric', ...
                'tpt_54', 'char', ...
                'tpt_55', 'char', ...
                'tpt_56', 'char', ...
                'tpt_57', 'char', ...
                'tpt_58', 'char', ...
                'tpt_58b', 'char', ...
                'tpt_59', 'numeric', ...
                'tpt_60', 'char', ...
                'tpt_61', 'numeric', ...
                'tpt_62', 'numeric', ...
                'tpt_63', 'date', ...
                'tpt_64', 'char', ...
                'tpt_65', 'char', ...
                'tpt_67', 'char', ...
                'tpt_68', 'char', ...
                'tpt_69', 'numeric', ...
                'tpt_70', 'char', ...
                'tpt_71', 'char', ...
                'tpt_72', 'numeric', ...
                'tpt_73', 'char', ...
                'tpt_74', 'numeric', ...
                'tpt_75', 'numeric', ...
                'tpt_76', 'numeric', ...
                'tpt_77', 'date', ...
                'tpt_78', 'char', ...
                'tpt_79', 'numeric', ...
                'tpt_80', 'char', ...
                'tpt_81', 'char', ...
                'tpt_82', 'numeric', ...
                'tpt_83', 'char', ...
                'tpt_84', 'char', ...
                'tpt_85', 'numeric', ...
                'tpt_86', 'char', ...
                'tpt_87', 'numeric', ...
                'tpt_88', 'char', ...
                'tpt_89', 'numeric', ...
                'tpt_90', 'numeric', ...
                'tpt_91', 'numeric', ...
                'tpt_92', 'numeric', ...
                'tpt_93', 'numeric', ...
                'tpt_94', 'numeric', ...
                'tpt_94b', 'numeric', ...
                'tpt_95', 'char', ...
                'tpt_97', 'numeric', ...
                'tpt_98', 'numeric', ...
                'tpt_99', 'numeric', ...
                'tpt_100', 'numeric', ...
                'tpt_101', 'numeric', ...
                'tpt_102', 'numeric', ...
                'tpt_103', 'numeric', ...
                'tpt_104', 'numeric', ...
                'tpt_105', 'numeric', ...
                'tpt_105a', 'numeric', ...
                'tpt_105b', 'numeric', ...
                'tpt_106', 'numeric', ...
                'tpt_107', 'char', ...
                'tpt_108', 'numeric', ...
                'tpt_110', 'numeric', ...
                'tpt_111', 'numeric', ...
                'tpt_112', 'char', ...
                'tpt_113', 'char', ...
                'tpt_114', 'numeric', ...
                'tpt_115', 'char', ...
                'tpt_116', 'char', ...
                'tpt_117', 'char', ...
                'tpt_118', 'char', ...
                'tpt_119', 'char', ...
                'tpt_120', 'char', ...
                'tpt_121', 'char', ...
                'tpt_122', 'char', ...
                'tpt_123', 'char', ...
                'tpt_123a', 'char', ...
                'tpt_124', 'numeric', ...
                'tpt_125', 'numeric', ...
                'tpt_126', 'numeric', ...
                'tpt_127', 'numeric', ...
                'tpt_128', 'numeric', ...
                'tpt_129', 'numeric', ...
                'tpt_130', 'numeric', ...
                'tpt_131', 'char', ...
                'tpt_132', 'numeric', ...
                'tpt_133', 'char', ...
                'tpt_1000', 'char', ...
                'position_failed_cell', 'cell', ...
                'aa_target_id', 'cell', ...
				'aa_target_values', 'numeric', ...
				'equity_target_region_id', 'cell', ...
				'equity_target_region_values', 'numeric', ...
				'min_req_cash', 'numeric', ...
				'hist_report_dates', 'cell', ...
				'hist_base_values', 'numeric', ...
				'hist_var_abs', 'numeric', ...
				'srri_target', 'numeric', ...
                'report_struct', 'struct', ...
                'region_id', 'cell', ...
				'rating_id', 'cell', ...
				'style_id', 'cell', ...
				'country_id', 'cell', ...
				'country_values', 'numeric', ... 
				'duration_id', 'cell', ...
				'region_values', 'numeric', ... 
				'style_values', 'numeric', ... 
				'rating_values', 'numeric', ...
				'duration_values', 'numeric', ...
				'esg_score', 'numeric', ...
                'aggr_key_struct', 'struct'
               );
  % B) store values in object
  if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
    error ('Parameter.set: expecting property/value pairs');
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
