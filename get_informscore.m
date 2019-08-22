%# Copyright (C) 2019 Stefan Schlögl <schinzilord@octarisk.com>
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
%# @deftypefn {Function File} {[@var{score} ] =} get_informscore(@var{isocode})
%#
%# Map the ISO-2 currency code to INFORM risk score.
%# See http://www.inform-index.org/ for further information.
%# Basic idea: if absolute needs (food, shelter, political stability, natural
%# desaster recovery) is not given, financial investments have to be closely
%# monitored. INFORM risk score delivers this classification in a condensed
%# way. 
%# @end deftypefn

function score = get_informscore(isocode)

if nargin < 1
    error('get_informscore: no country iso code provided.\n');
end

if nargin > 1
    fprintf('get_informscore: ignoring further argument(s).\n');
end
if ~(ischar(isocode))
    error('get_informscore: isocode not a string >>%s<<..\n',any2str(isocode));
end

% dictionary with all iso codes and their mapping to the INFORM risk score:

% manual update: map Hong Kong (HK) and Taiwan (TW) to China (CN)
inform = struct(   ...
                'AF',7.6, ...
				'AL',2.6, ...
				'DZ',4.3, ...
				'AO',5.2, ...
				'AG',2.1, ...
				'AR',2.3, ...
				'AM',3.5, ...
				'AU',2.3, ...
				'AT',1.7, ...
				'AZ',4.7, ...
				'BS',2.2, ...
				'BH',0.9, ...
				'BD',6, ...
				'BB',1.5, ...
				'BY',2.1, ...
				'BE',2.2, ...
				'BZ',3.1, ...
				'BJ',3.9, ...
				'BT',2.7, ...
				'BO',3.9, ...
				'BA',3.5, ...
				'BW',2.9, ...
				'BR',3.5, ...
				'BN',1.9, ...
				'BG',2.5, ...
				'BF',5.1, ...
				'BI',6, ...
				'CV',2.4, ...
				'KH',4.6, ...
				'CM',5.5, ...
				'CA',2.4, ...
				'CF',8.4, ...
				'TD',7.3, ...
				'CL',2.9, ...
				'CN',4.1, ...
				'HK',4.1, ...
				'TW',4.1, ...
				'CO',5.4, ...
				'KM',3.8, ...
				'CG',5.1, ...
				'CD',7.5, ...
				'CR',2.9, ...
				'CI',5.6, ...
				'HR',2.2, ...
				'CU',3.3, ...
				'CY',2.7, ...
				'CZ',1.4, ...
				'DK',1.1, ...
				'DJ',5, ...
				'DM',3, ...
				'DO',4, ...
				'EC',4, ...
				'EG',4.5, ...
				'SV',4.1, ...
				'GQ',3.8, ...
				'ER',5.2, ...
				'EE',1, ...
				'ET',6.9, ...
				'FJ',2.9, ...
				'FI',0.6, ...
				'FR',2.5, ...
				'GA',4.1, ...
				'GM',3.9, ...
				'GE',3.7, ...
				'DE',2.1, ...
				'GH',3.5, ...
				'GR',2.9, ...
				'GD',1.2, ...
				'GT',5.3, ...
				'GN',5, ...
				'GW',5.6, ...
				'GY',2.9, ...
				'HT',6.3, ...
				'HN',4.8, ...
				'HU',1.9, ...
				'IS',1, ...
				'IN',5.3, ...
				'ID',4.3, ...
				'IR',4.9, ...
				'IQ',7, ...
				'IE',1.3, ...
				'IL',2.6, ...
				'IT',2.6, ...
				'JM',2.4, ...
				'JP',1.9, ...
				'JO',4, ...
				'KZ',2, ...
				'KE',5.9, ...
				'KI',3.6, ...
				'KP',5, ...
				'KR',1.6, ...
				'KW',2, ...
				'KG',3.4, ...
				'LA',3.8, ...
				'LV',1.6, ...
				'LB',5.3, ...
				'LS',4.4, ...
				'LR',5, ...
				'LY',5.9, ...
				'LI',0.9, ...
				'LT',1.4, ...
				'LU',0.7, ...
				'MG',5, ...
				'MW',4.4, ...
				'MY',3.1, ...
				'MV',2.2, ...
				'ML',6.3, ...
				'MT',1.8, ...
				'MH',4.4, ...
				'MR',5.9, ...
				'MU',2, ...
				'MX',4.8, ...
				'FM',4, ...
				'MD',2.6, ...
				'MN',3.2, ...
				'ME',2.2, ...
				'MA',4, ...
				'MZ',6, ...
				'MM',6.7, ...
				'NA',3.5, ...
				'NR',2.8, ...
				'NP',5.3, ...
				'NL',1.4, ...
				'NZ',1.8, ...
				'NI',3.9, ...
				'NE',6.9, ...
				'NG',6.6, ...
				'NO',0.7, ...
				'OM',2.9, ...
				'PK',6, ...
				'PW',2.8, ...
				'PS',4, ...
				'PA',3.2, ...
				'PG',5.5, ...
				'PY',2.8, ...
				'PE',4.1, ...
				'PH',5.4, ...
				'PL',1.8, ...
				'PT',1.6, ...
				'QA',1.3, ...
				'RO',2.7, ...
				'RU',4.4, ...
				'RW',4.9, ...
				'KN',1.5, ...
				'LC',1.8, ...
				'VC',1.7, ...
				'WS',2.7, ...
				'ST',1.8, ...
				'SA',2.9, ...
				'SN',4.4, ...
				'RS',3.4, ...
				'SC',2, ...
				'SL',5.2, ...
				'SG',0.4, ...
				'SK',1.7, ...
				'SI',1.4, ...
				'SB',4.7, ...
				'SO',9.1, ...
				'ZA',4.3, ...
				'SS',9, ...
				'ES',2.3, ...
				'LK',3.6, ...
				'SD',7, ...
				'SR',2.5, ...
				'SZ',3.1, ...
				'SE',1.5, ...
				'CH',1.3, ...
				'SY',7, ...
				'TJ',4.2, ...
				'TZ',5.5, ...
				'TH',4.1, ...
				'MK',2.9, ...
				'TL',4.1, ...
				'TG',4.6, ...
				'TO',2.7, ...
				'TT',1.8, ...
				'TN',3, ...
				'TR',4.9, ...
				'TM',2.9, ...
				'TV',3.5, ...
				'UG',6.2, ...
				'UA',5.4, ...
				'AE',2, ...
				'GB',2, ...
				'US',3.7, ...
				'UY',1.5, ...
				'UZ',3, ...
				'VU',3.9, ...
				'VE',4.5, ...
				'VN',3.7, ...
				'YE',7.7, ...
				'ZM',4, ...
				'ZW',5.1 ...
            );
                       
if ~(isfield(inform,upper(isocode)))
    error('get_informscore: no valid country iso code >>%s<< provided.\n',isocode);
end                       
% map the string to the number 1:length(dcc_cell):
score = getfield(inform,upper(isocode));
end 


%!assert(get_informscore('DE'),2.1)