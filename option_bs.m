%# Copyright (C) 2015 Stefan Schloegl <schinzilord@octarisk.com>
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
%# @deftypefn {Function File} {[@var{value} @var{delta} @var{gamma} @var{vega} @var{theta} @var{rho} @var{omega}] =} option_bs (@var{CallPutFlag}, @var{S}, @var{X}, @var{T}, @var{r}, @var{sigma}, @var{divrate})
%#
%# Compute the prices of european call or put options according to Black-Scholes 
%# valuation formula:@*
%# @example
%# @group
%# C(S,T) = N(d_1)*S - N(d_2)*X*exp(-rT)
%# P(S,T) = N(-d_2)*X*exp(-rT) - N(-d_1)*S
%# d1 = (log(S/X) + (r + 0.5*sigma^2)*T)/(sigma*sqrt(T))
%# d2 = d1 - sigma*sqrt(T)
%# @end group
%# @end example
%# The Greeks are also computed (delta, gamma, vega, theta, rho, omega) by 
%# their closed form solution. @*
%# Parallel computation for column vectors of S,X,r and sigma is possible. @*
%# @*
%# Variables:
%# @itemize @bullet
%# @item @var{CallPutFlag}: Call: '1', Put: '0'
%# @item @var{S}: stock price at time 0
%# @item @var{X}: strike price 
%# @item @var{T}: time to maturity in days 
%# @item @var{r}: annual risk-free interest rate (continuously compounded, act/365)
%# @item @var{sigma}: implied volatility of the stock price measured as annual 
%# standard deviation
%# @item @var{divrate}: dividend rate p.a., continously compounded
%# @end itemize
%# @seealso{option_willowtree, swaption_black76}
%# @end deftypefn

function [value delta gamma vega theta rho omega] = option_bs(CallPutFlag,S,X, ...
                                                              T,r,sigma,divrate)
 
 if nargin < 6 || nargin > 7
    print_usage ();
  end
  if nargin == 6
    divrate = 0.00;
  end 
   
  if ~isnumeric (CallPutFlag)
    error ('CallPutFlag must be either 1 or 0 ')
  elseif ~isnumeric (S)
    error ('Underlying price S must be numeric ')
  elseif ~isnumeric (X)
    error ('Strike X must be numeric ')
  elseif X < 0
    error ('Strike X must be positive ')
  elseif S < 0
    error ('Price S must be positive ')    
  elseif ~isnumeric (T)
    error ('Time T in days must be numeric ')
  elseif ( T < 0)
    error ('Time T must be positive ')    
  elseif ~isnumeric (r)
    error ('Riskfree rate r must be numeric ')    
  elseif ~isnumeric (sigma)
    error ('Implicit volatility sigma must be numeric ')
  elseif ~isnumeric (divrate)
    error ('Dividend rate must be numeric ')     
  elseif ~( isempty(sigma(sigma< 0)))
    error ('Volatility sigma must be positive ')        
  end
 
% Calculation of BS value
if ( CallPutFlag == 1 ) % Call
    eta = 1;
else   % Put   
    eta = -1;
end
T = T ./ 365;   % assuming act/365 day count convention (converted by Option class)
q = divrate;    % assuming act/365 continuous compounding
% get special case T == 0 --> skip this part
if ( T > 0 )
    d1 = (log(S./X) + (r - q + 0.5.*sigma.^2).*T)./(sigma.*sqrt(T));
    d2 = d1 - sigma.*sqrt(T);
    normcdf_eta_d1  = 0.5.*(1+erf(eta .* d1./sqrt(2)));
    normcdf_eta_d2  = 0.5.*(1+erf(eta .* d2./sqrt(2)));
    normcdf_d1      = 0.5.*(1+erf(d1./sqrt(2)));
    normcdf_d2      = 0.5.*(1+erf(d2./sqrt(2)));           
    % Calculating value: 
    value   = eta .* (exp(-q.*T) .* S.*normcdf_eta_d1- X.*exp(-r.*T) ...
            .*normcdf_eta_d2); 
else % payoff without uncertainty
    if ( CallPutFlag == 1 ) % Call
        value = max(S - X, 0.0);
    else   % Put   
        value = max(X - S, 0.0);
    end
end
    
% Calculate greeks only if demanded:
    if (nargout > 1 && T > 0)
        % normal density corresponding to N1 (needed for greeks)
        N1s = exp(-d1 .* d1 ./ 2) ./ sqrt(2 .* pi); 
        delta   = eta .* exp(-q.*T) .* normcdf_eta_d1;
        gamma   =  exp(-q .* T) .* N1s ./ S ./ sigma ./ sqrt(T);
        theta   = -exp(-q .* T) .* S .* N1s .* sigma ./ 2 ./ sqrt(T) ...
                    + q .* exp(-q .* T) .* S .* normcdf_d1 - r .* exp(-r .* T) ...
                    .* X .* normcdf_d2;
        if ( CallPutFlag == 1 ) % Call
            theta   = -exp(-q .* T) .* S .* N1s .* sigma ./ 2 ./ sqrt(T) ...
                    + q .* exp(-q .* T) .* S .* normcdf_d1 - r .* exp(-r .* T) ...
                    .* X .* normcdf_d2;
        else   % Put   
            theta   = -exp(-q .* T) .* S .* N1s .* sigma ./ 2 ./ sqrt(T) ...
                    - q .* exp(-q .* T) .* S .* (1 - normcdf_d1) + r .* exp(-r .* T) ...
                    .* X .* (1 - normcdf_d2);
        end   
        theta = theta ./ 365;
        vega    = S .* exp(-q.*T) .* N1s .* sqrt(T) ./ 100;
        rho     = eta .* T.* X .*exp(-r.*T).* normcdf_eta_d2 ./ 100;
        if ~(value == 0)
            omega   = delta .* S ./ value;
        else
            omega = 0;
        end
    else
        delta = gamma = vega = theta = rho = omega = 0;
    end
end

%!assert(option_bs(0,[10000;9000;11000],11000,365,0.01,[0.2;0.025;0.03]),[1351.5596289;1890.5481719;83.4751769],0.000002)
%!assert(option_bs(1,[10000;9000;11000],11000,365,0.01,[0.2;0.025;0.03]),[461.0114579;3.0875e-013;192.9270059],0.000002)
