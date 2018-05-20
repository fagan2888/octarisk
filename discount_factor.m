%# Copyright (C) 2016 Stefan Schloegl <schinzilord@octarisk.com>
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
%#
%# You should have received a copy of the GNU General Public License along with
%# this program; if not, see <http://www.gnu.org/licenses/>.

%# -*- texinfo -*-
%# @deftypefn {Function File} {@var{df} =} discount_factor (@var{d1}, @var{d2}, @var{rate}, @var{comp_type}, @var{basis}, @var{comp_freq})
%#
%# Compute the discount factor for a specific time period, compounding type, 
%# day count basis and compounding frequency.@*
%#
%# Input and output variables:
%# @itemize @bullet
%# @item @var{d1}:          number of days until first date (scalar)
%# @item @var{d2}:          number of days until second date (scalar)
%# @item @var{rate}:        interest rate between first and second date (scalar)
%# @item @var{comp_type}:   compounding type: [simple, simp, disc, discrete, 
%# cont, continuous] (string)
%# @item @var{basis}:       day-count basis (scalar or string)
%# @item @var{comp_freq}:   1,2,4,12,52,365 or [daily,weekly,monthly,
%# quarter,semi-annual,annual] (scalar or string)
%# @item @var{df}:          OUTPUT: discount factor (scalar)
%# @end itemize
%# @seealso{timefactor}
%# @end deftypefn

function df = discount_factor (d1, d2, rate, comp_type, basis, comp_freq)
% Error check
if nargin < 3
   error('Needed at least date1 and date2 and rate')
end
if ~isnumeric(rate)
    error('Rate is not a valid number')
end
if ischar(d1) 
   d1 = datenum(d1,1);
end
if ischar(d2)
   d2 = datenum(d2,1);
end
if ischar(basis)
    basis = get_basis(basis);
end
if nargin < 4
   compounding_type = 1;
   comp_type = 1;
   basis = 3;
end
if nargin < 5
   basis = 3;
end
if nargin < 6
    comp_freq = 1;
end

% Prevent division by zero:
if ( rate == -1)
    rate = -0.99999;
    fprintf('discount_factor: WARNING: rate is -1. setting to -0.9\n');
end
% experimental: call oct file. performance gain only if dimensions > 100000
% df = discount_factor_cpp (d1, d2, rate, comp_type, basis, comp_freq);

% oldschool Octave implementation:
if ischar(comp_type)
    if ( regexpi(comp_type,'simp'))
        compounding_type = 1;
    elseif ( regexpi(comp_type,'disc') )
        compounding_type = 2;
    elseif ( regexpi(comp_type,'cont') )
        compounding_type = 3;
    else
        error('discount_factor: Need valid compounding_type. Unknown >>%s<<',comp_type)
    end
end

% error check compounding frequency
if ischar(comp_freq)
    if ( regexpi(comp_freq,'^da') )
        compounding = 365;
    elseif ( regexpi(comp_freq,'^week') )
        compounding = 52;
    elseif ( regexpi(comp_freq,'^month') )
        compounding = 12;
    elseif ( regexpi(comp_freq,'^quarter') )
        compounding = 4;
    elseif ( regexpi(comp_freq,'^semi-annual') )
        compounding = 2;
    elseif ( regexpi(comp_freq,'^annual') )
        compounding = 1;       
    else
        error('discount_factor: Need valid compounding frequency. Unknown >>%s<<',comp_freq)
    end
else
    compounding = comp_freq;
end

% get timefactor
tf = timefactor(d1,d2,basis);

% calculate discount factor
% 3 cases
if ( compounding_type == 1)      % simple
    df = 1 ./ ( 1 + rate .* tf );
elseif ( compounding_type == 2)      % discrete
    df = 1 ./ (( 1 + ( rate ./ compounding) ).^( compounding .* tf));
elseif ( compounding_type == 3)      % continuous
    df = exp(-rate .* tf );
end

 
end
 
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'discrete', 'act/365', 'annual'),0.999499644219733,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'annual'),0.999499644219733,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'simple', 'act/365', 'annual'),0.999499744332038,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'simp', 'act/365', 'annual'),0.999499744332038,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'cont', 'act/365', 'annual'),0.999499619183308,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'continuous', 'act/365', 'annual'),0.999499619183308,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'weekly'),0.999499619664798,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'monthly'),0.999499621269802,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'quarter'),0.999499625442730,0.000001)
%!assert(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'semi-annual'),0.999499631701938,0.000001)
%!error(discount_factor ('31-Mar-2016', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'montly'))
%!error(discount_factor ('31-Mar-2025', '30-Mar-2021', 0.00010010120979, 'disc', 'act/365', 'montly'))