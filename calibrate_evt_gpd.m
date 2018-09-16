%# Copyright (C) 2016 Stefan Schloegl <schinzilord@octarisk.com>
%# Copyright (C) 2016 IRRer-Zins <IRRer-Zins@t-online.de>
%#
%# This program is free software; you can redistribute it and/or modify it under
%# the terms of the GNU General Public License as published by the Free Software
%# Foundation; either version 3 of the License, or (at your option) any later
%# version.
%#
%# This program is distributed in the hope that it will be useful, but WITHOUT
%# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%# details.

%# -*- texinfo -*-
%# @deftypefn {Function File} { [@var{chi} @var{sigma} @var{u}] =} calibrate_evt_gpd(@var{v})
%#
%# Calibrate sorted losses of historic or MC portfolio values 
%# to a generalized pareto distribution and returns chi, sigma and u as 
%# parameters for further VAR and ES calculation.
%# @*
%# Implementation according to @i{Risk Management and Financial Institutions} 
%# by John C. Hull, 4th edition, Wiley 2015, section 13.6, page 292ff.
%# @*
%# Variables:
%# @itemize @bullet
%# @item @var{v}:       INPUT:  sorted profit and loss distribution of all 
%#                              required tail events (1xN vector)
%# @item @var{chi}:     OUTPUT: Generalized Pareto distribution: shape 
%#                              parameter (scalar)
%# @item @var{sigma}:   OUTPUT: scale parameter (scalar)
%# @item @var{u}:       OUTPUT: location parameter(scalar)
%# @end itemize
%# @end deftypefn

function [chi sigma u] = calibrate_evt_gpd(v)

% get start parameters
u = min(v);     % location parameter
chi = 0.3;      % shape parameter
beta = u/10;    % scale parameter
y = v - u;      % substitution of loss distribution which is shifted 
                % by location parameter

% Start parameter
x0 = [chi;beta];

% Options for optimization
options(1) = 0;
options(2) = 1e-5;

% Calibrate chi and sigma
[x, obj, info, iter] = fmincon ( @ (x) min_GPD(x,y), x0,[], ...
                            [], [],[],[0.00001;0.00001], []);   

if (info == 1)
    %fprintf ('+++ calibrate_evt_gpd: SUCCESS: First-order optimality measure and maximum constraint violation was less than default values. +++\n');
elseif (info == 0)
    fprintf ('--- calibrate_evt_gpd: WARNING: BS Number of iterations or function evaluations exceeded default values. ---\n');
    x = [0.0000001,1];
elseif (info == -1)
    fprintf ('--- calibrate_evt_gpd: WARNING: BS Stopped by an output function or plot function. ---\n');
    x = [0.0000001,1];
elseif (info == -2)
    fprintf ('--- calibrate_evt_gpd: WARNING: BS No feasible point was found. ---\n');
    x = [0.0000001,1];
elseif (info == 2)
    %fprintf ('+++ calibrate_evt_gpd: SUCCESS: Change in x and maximum constraint violation was less than default values. +++\n');
else
    fprintf ('--- calibrate_evt_gpd: WARNING: BS Optimization did not converge! ---\n');
    x = [0.0000001,1];
end
% 
% return scale and shape parameter
chi = x(1);
sigma = x(2);

end 

%------------------------------------------------------------------
%------------------- Begin Subfunctions ---------------------------

%  Objective Function for calibration of generalized pareto distribution:          
function obj = min_GPD (x,y)
            chi = x(1);
            beta = x(2);
            L = log( ( 1 + ( chi .* (y) )./beta ).^(-1./chi -1) ./ beta );
            obj = -(sum(L));
end
%------------------------------------------------------------------

%!test
%! [aa,bb,cc] = calibrate_evt_gpd([-5500;-4880;-4600;-4500;-4450;-4400;-4390]);
%! assert ([aa,bb,cc] - [10,9.99999997475243e-006,-5500.00000],[0.000000,0.0000000,0.0000000],0.003);

