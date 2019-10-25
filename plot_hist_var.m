function retcode = plot_hist_var(obj,para_object,path_reports)

retcode = 1;
% fill variables
hist_bv = [obj.hist_base_values];
hist_var = [obj.hist_var_abs];
hist_dates = [obj.hist_report_dates];
if isempty(obj.hist_cashflow)
	cashinoutflow = [zeros(1,numel(hist_dates))];
else
	cashinoutflow = [obj.hist_cashflow];	  
end	
% make sure hist_date before valuation date
% remove all values equal or after valuation date
hist_var(datenum(hist_dates)>=datenum(datestr(para_object.valuation_date)))=[];
hist_bv(datenum(hist_dates)>=datenum(datestr(para_object.valuation_date)))=[];
cashinoutflow(datenum(hist_dates)>=datenum(datestr(para_object.valuation_date)))=[];
% lastly remove from hist_dates
hist_dates(datenum(hist_dates)>=datenum(datestr(para_object.valuation_date)))=[];

% append current values	
if isempty(obj.current_cashflow)
	cashinoutflow = [cashinoutflow, 0];
else
	cashinoutflow = [cashinoutflow, obj.current_cashflow];	
end	
hist_bv = [hist_bv,obj.getValue('base')];
hist_var = [hist_var,obj.varhd_abs];
hist_dates = [hist_dates,datestr(para_object.valuation_date)];
  
% set colors
or_green = [0.56863   0.81961   0.13333]; 
or_blue  = [0.085938   0.449219   0.761719]; 
or_orange =  [0.945312   0.398438   0.035156];
light_blue = [0.50000   0.69922   0.99609];


if (numel(hist_bv)>0 && numel(hist_bv) == numel(hist_var) ...
						&& numel(hist_dates) == numel(hist_var) ...
						&& numel(hist_bv) == numel(hist_dates) ...
						&& numel(hist_bv) == numel(cashinoutflow) )  	
		
		% take only into account 6 last reporting dates
		len = numel(hist_bv);
		maxdates = 5;
		idxstart = 1+len-min(maxdates,len);
		hist_bv = hist_bv(idxstart:end);
		cashinoutflow = cashinoutflow(idxstart:end);
		hist_var = hist_var(idxstart:end);
		hist_dates = hist_dates(idxstart:end);
		nextmonthend = datestr(addtodatefinancial(datenum(datestr(para_object.valuation_date)),1,'months'));

		% start plotting
		hvar = figure(1);
		clf;
		xx=1:1:length(hist_bv)+1;
		hist_var_rel = 100 .* hist_var ./ hist_bv;

		annotation("textbox",[0.7,0.15,0.1,0.1],"string", ...
				"Base value threshold \nimposed by pre-date VaR","edgecolor",'white', ...
				"backgroundcolor","white","color",or_blue);
		[ax h1 h2] = plotyy (xx(1:end-1),hist_bv, xx(1:end-1),hist_var_rel, @plot, @plot);
		hold on;
        xlabel(ax(1),'Reporting Date','fontsize',12);
        set(ax(1),'visible','on');
 		set(ax(2),'visible','on');
        set(ax(1),'layer','top');
        set(ax(1),'xtick',xx);
        set(ax(1),'xlim',[0.8, length(xx)+0.2]);
        set(ax(1),'ylim',[0.98*min(hist_bv - sqrt(2).*hist_var + cashinoutflow), 1.02*max(hist_bv + sqrt(2).*hist_var)]);
		set(ax(1),'xticklabel',[hist_dates,nextmonthend]);
		set(ax(2),'layer','top');
		set(ax(2),'xtick',xx);
		set(ax(2),'xlim',[0.8, length(xx)+0.2]);
		set(ax(2),'ylim',[floor(0.97*min(hist_var_rel)), ceil(1.03*max(hist_var_rel))]);
		set(ax(2),'xticklabel',{});
		set (h1,'linewidth',1);
		set (h1,'color',or_blue);
		set (h1,'marker','o');
		set (h1,'markerfacecolor',or_blue);
		set (h1,'markeredgecolor',or_blue);
		set (h2,'linewidth',1);
		set (h2,'color',or_orange);
		set (h2,'marker','o');
		set (h2,'markerfacecolor',or_orange);
		set (h2,'markeredgecolor',or_orange);
		ylabel (ax(1), strcat('Base Value (',obj.currency,')'),'fontsize',12);
		ylabel (ax(2), strcat('VaR relative (in Pct)'),'fontsize',12);
		legend(ax(1),'Base Value','VaR (rel.)');
		
		% doing a replot
		var_bv_min = zeros(1,numel(hist_bv));
		for kk=1:1:numel(hist_bv)-1
			dip = numel(busdays(datenum(hist_dates(kk)),datenum(hist_dates(kk+1))));
			dd = [kk:1/dip:kk+1];
			zz = [0:1/dip:1];
			var_limit= [hist_bv(kk) - hist_var(kk) .* sqrt(dip) ./ ...
					sqrt(para_object.mc_timestep_days).* sqrt(zz)] + ...
					zz.* cashinoutflow(kk+1);
			var_bv_min(kk) = var_limit(end);
			if (kk==1)
				plot(dd,var_limit,'color',light_blue,'linestyle','--');
				hold on;
			end
		end
		
		dip = 10;
		kk = numel(hist_bv);
		dd = [kk:1/dip:kk+1];
		zz = [0:1/dip:1];
		var_limit_lower = [hist_bv(kk) - hist_var(kk) .* sqrt(dip) ./ sqrt(10).* sqrt(zz)];	
		var_limit_upper = [hist_bv(kk) + hist_var(kk) .* sqrt(dip) ./ sqrt(10).* sqrt(zz)];	
		plot(dd,var_limit_lower,'color',light_blue,'linestyle','--','linewidth',1);
		hold on;
		plot(dd,var_limit_upper,'color',light_blue,'linestyle','--','linewidth',1);
		hold on;
		var_bv_min(kk) = var_limit_lower(end);
		plot(xx(2:end),var_bv_min,'color',light_blue,'linestyle','-','linewidth',1);
		hold off;
		
		% save plotting
		filename_plot_varhist = strcat(path_reports,'/',obj.id,'_var_history.png');
		print (hvar,filename_plot_varhist, "-dpng", "-S600,300");	
		filename_plot_varhist = strcat(path_reports,'/',obj.id,'_var_history.pdf');
		print (hvar,filename_plot_varhist, "-dpdf", "-S600,300");	
		
else
	retcode = 0;
	fprintf('plot: Plotting VaR history not possible for portfolio >>%s<<, attributes are either not filled or not identical in length\n',obj.id);	
end

end
