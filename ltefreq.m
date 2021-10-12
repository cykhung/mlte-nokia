function varargout = ltefreq(link, band, EARFCN)

%%
%       SYNTAX: centerFreqMHz = ltefreq(link, band, EARFCN);
%               T             = ltefreq;
% 
%  DESCRIPTION: Calculate LTE carrier center frequency for either downlink or
%               uplink transmission.
%
%               Refer to Table 5.7.3-1 in pp. 18 of 36.101 V8.24.0 (2014-06).
%
%               The following table shows examples of the DL center frequencies:
%
%                                                   DL              DL
%                  Service Provider       Band     UARFCN    Center Frequency
%               ----------------------    ----     ------    ----------------
%                 Verizon (Natick, MA)     13       5230        751    MHz
%                 Verizon (US)             2        1125        1.9825 GHz
%                 Verizon (US)             4        2125        2.1275 GHz
%                 Verizon (Torrance, CA)   13       5230        751    MHz
%                 Verizon (Torrance, CA)   2        1000        1.97   GHz
%                 Verizon (Torrance, CA)   4        2100        2.125  GHz
%                 AT&T    (Natick, MA)     12       5110        739    MHz
%                 AT&T    (Natick, MA)     17       5780        739    MHz
%
%        INPUT: - link (string)
%                   Link. Valid values are:
%                       'dl' - Downlink.
%                       'ul' - Uplink.
%
%               - band (real double)
%                   E-UTRA Operating Band. Valid values are: [1:14, 17, 33:40].
%
%               - EARFCN (real double)
%                   E-UTRA Absolute Radio Frequency Channel Number.
%
%       OUTPUT: - centerFreqMHz (real double)
%                   Carrier center frequency in MHz.
%
%               - T (table)
%                   Table listing all DL and UL carrier center frequencies in
%                   MHz.


%% Create the table in pp. 18.
T = createTable;


%% Create a table that lists all DL and UL carrier center frequencies.
if nargin == 0
    T2 = listAllFrequencies(T);
    varargout = {T2};
    return;             % Early exit.
end


%% Calculate carrier center frequency in MHz.
T1 = T(T.Band == band, :);
if isempty(T1)
    error('Band not supported.');
end
switch link
case 'dl'
    if (EARFCN < T1.Range_N_DL(1)) || (EARFCN > T1.Range_N_DL(2))
        error('EARFCN out of range.');
    end
    centerFreqMHz = T1.F_DL_low_MHz + (0.1 * (EARFCN - T1.N_Offs_DL));
case 'ul'
    if (EARFCN < T1.Range_N_UL(1)) || (EARFCN > T1.Range_N_UL(2))
        error('EARFCN out of range.');
    end
    centerFreqMHz = T1.F_UL_low_MHz + (0.1 * (EARFCN - T1.N_Offs_UL));
otherwise
    error('Invalid link.');
end


%% Assign output arguments.
varargout = {centerFreqMHz};


end


function T2 = listAllFrequencies(T1)


%% Calculate all carrier center frequencies (including DL and UL).
Link          = [];
Band          = [];
EARFCN        = [];
CenterFreqMHz = [];
for n = 1:length(T1.Band)
    
    % DL.
    range         = T1.Range_N_DL(n,:);
    earfcn        = (range(1) : range(2))';     % column vector.
    link          = categorical(repmat({'DL'}, length(earfcn), 1));
    band          = repmat(T1.Band(n), length(earfcn), 1);
    F_DL_low_MHz  = T1.F_DL_low_MHz(n);         % scalar.
    N_Offs_DL     = T1.N_Offs_DL(n);            % scalar.
    centerFreqMHz = F_DL_low_MHz + (0.1 * (earfcn - N_Offs_DL));
    Link          = [Link; link];                       %#ok<AGROW>
    Band          = [Band; band];                       %#ok<AGROW>
    EARFCN        = [EARFCN; earfcn];                   %#ok<AGROW>
    CenterFreqMHz = [CenterFreqMHz; centerFreqMHz];     %#ok<AGROW>
    
    % UL.
    range         = T1.Range_N_UL(n,:);
    earfcn        = (range(1) : range(2))';     % column vector.
    link          = categorical(repmat({'UL'}, length(earfcn), 1));
    band          = repmat(T1.Band(n), length(earfcn), 1);
    F_UL_low_MHz  = T1.F_UL_low_MHz(n);         % scalar.
    N_Offs_UL     = T1.N_Offs_UL(n);            % scalar.
    centerFreqMHz = F_UL_low_MHz + (0.1 * (earfcn - N_Offs_UL));
    Link          = [Link; link];                       %#ok<AGROW>
    Band          = [Band; band];                       %#ok<AGROW>
    EARFCN        = [EARFCN; earfcn];                   %#ok<AGROW>
    CenterFreqMHz = [CenterFreqMHz; centerFreqMHz];     %#ok<AGROW>

end
T2               = table;
T2.Link          = Link;
T2.Band          = Band;
T2.EARFCN        = EARFCN;
T2.CenterFreqMHz = CenterFreqMHz;


% %% Pre-allocate memory for T2.
% A = T1.Range_N_DL;
% N = sum(A(:,2) - A(:,1) + 1);
% A = T1.Range_N_UL;
% N = N + sum(A(:,2) - A(:,1) + 1);
% T2               = table;
% T2.Link          = categorical(repmat({''}, N, 1));
% T2.Band          = NaN(N, 1);
% T2.EARFCN        = NaN(N, 1);
% T2.CenterFreqMHz = NaN(N, 1);
% 
% 
% %% Calculate all carrier center frequencies (including DL and UL).
% m1 = 1;
% for n = 1:length(T1.Band)
%     
%     % DL.
%     range            = T1.Range_N_DL(n,:);
%     EARFCN           = (range(1) : range(2))';
%     N                = length(EARFCN);
%     m2               = m1 + N - 1;
%     T2.Link(m1:m2)   = 'DL';
%     T2.Band(m1:m2)   = T1.Band(n);
%     T2.EARFCN(m1:m2)  = EARFCN;
%     F_DL_low_MHz     = T1.F_DL_low_MHz(n);      % scalar.
%     N_Offs_DL        = T1.N_Offs_DL(n);         % scalar.
%     T2.CenterFreqMHz(m1:m2) = F_DL_low_MHz + (0.1 * (EARFCN - N_Offs_DL));
%     
%     % Advance m1.
%     m1 = m1 + N;
%     
%     % UL.
%     range            = T1.Range_N_UL(n,:);
%     EARFCN           = (range(1) : range(2))';
%     N                = length(EARFCN);
%     m2               = m1 + N - 1;
%     T2.Link(m1:m2)   = 'UL';
%     T2.Band(m1:m2)   = T1.Band(n);
%     T2.EARFCN(m1:m2)  = EARFCN;
%     F_UL_low_MHz     = T1.F_UL_low_MHz(n);      % scalar.
%     N_Offs_UL        = T1.N_Offs_UL(n);         % scalar.
%     T2.CenterFreqMHz(m1:m2) = F_UL_low_MHz + (0.1 * (EARFCN - N_Offs_UL));
%     
%     % Advance m1.
%     m1 = m1 + N;
% 
% end


% %% Calculate all carrier center frequencies (including DL and UL).
% T2 = table;
% for n = 1:length(T1.Band)
%     
%     % DL.
%     range            = T1.Range_N_DL(n,:);
%     EARFCN           = (range(1) : range(2))';     % column vector.
%     T3               = table;
%     T3.Link          = categorical(repmat({'DL'}, length(EARFCN), 1));
%     T3.Band          = repmat(T1.Band(n), length(EARFCN), 1);
%     T3.EARFCN        = EARFCN;
%     F_DL_low_MHz     = T1.F_DL_low_MHz(n);      % scalar.
%     N_Offs_DL        = T1.N_Offs_DL(n);         % scalar.
%     T3.CenterFreqMHz = F_DL_low_MHz + (0.1 * (EARFCN - N_Offs_DL));
%     T2 = [T2; T3];          %#ok<AGROW>
%     
%     % UL.
%     range            = T1.Range_N_UL(n,:);
%     EARFCN           = (range(1) : range(2))';     % column vector.
%     T3               = table;
%     T3.Link          = categorical(repmat({'UL'}, length(EARFCN), 1));
%     T3.Band          = repmat(T1.Band(n), length(EARFCN), 1);
%     T3.EARFCN        = EARFCN;
%     F_UL_low_MHz     = T1.F_UL_low_MHz(n);      % scalar.
%     N_Offs_UL        = T1.N_Offs_UL(n);         % scalar.
%     T3.CenterFreqMHz = F_UL_low_MHz + (0.1 * (EARFCN - N_Offs_UL));
%     T2 = [T2; T3];          %#ok<AGROW>
% 
% end


end


function T = createTable

%% Initialize variables.
Band         = [];
F_DL_low_MHz = [];
N_Offs_DL    = [];
Range_N_DL   = [];
F_UL_low_MHz = [];
N_Offs_UL    = [];
Range_N_UL   = [];

%% Add band 1.
Band(end+1)         = 1;
F_DL_low_MHz(end+1) = 2110;
N_Offs_DL(end+1)    = 0;
Range_N_DL(end+1,:) = [0, 599];
F_UL_low_MHz(end+1) = 1920;
N_Offs_UL(end+1)    = 18000;
Range_N_UL(end+1,:) = [18000, 18599];

%% Add band 2.
Band(end+1)         = 2;
F_DL_low_MHz(end+1) = 1930;
N_Offs_DL(end+1)    = 600;
Range_N_DL(end+1,:) = [600, 1199];
F_UL_low_MHz(end+1) = 1850;
N_Offs_UL(end+1)    = 18600;
Range_N_UL(end+1,:) = [18600, 19199];

%% Add band 3.
Band(end+1)         = 3;
F_DL_low_MHz(end+1) = 1805;
N_Offs_DL(end+1)    = 1200;
Range_N_DL(end+1,:) = [1200, 1949];
F_UL_low_MHz(end+1) = 1710;
N_Offs_UL(end+1)    = 19200;
Range_N_UL(end+1,:) = [19200, 19949];

%% Add band 4.
Band(end+1)         = 4;
F_DL_low_MHz(end+1) = 2110;
N_Offs_DL(end+1)    = 1950;
Range_N_DL(end+1,:) = [1950, 2399];
F_UL_low_MHz(end+1) = 1710;
N_Offs_UL(end+1)    = 19950;
Range_N_UL(end+1,:) = [19950, 20399];

%% Add band 5.
Band(end+1)         = 5;
F_DL_low_MHz(end+1) = 869;
N_Offs_DL(end+1)    = 2400;
Range_N_DL(end+1,:) = [2400, 2649];
F_UL_low_MHz(end+1) = 824;
N_Offs_UL(end+1)    = 20400;
Range_N_UL(end+1,:) = [20400, 20649];

%% Add band 6.
Band(end+1)         = 6;
F_DL_low_MHz(end+1) = 875;
N_Offs_DL(end+1)    = 2650;
Range_N_DL(end+1,:) = [2650, 2749];
F_UL_low_MHz(end+1) = 830;
N_Offs_UL(end+1)    = 20650;
Range_N_UL(end+1,:) = [20650, 20749];

%% Add band 7.
Band(end+1)         = 7;
F_DL_low_MHz(end+1) = 2620;
N_Offs_DL(end+1)    = 2750;
Range_N_DL(end+1,:) = [2750, 3449];
F_UL_low_MHz(end+1) = 2500;
N_Offs_UL(end+1)    = 20750;
Range_N_UL(end+1,:) = [20750, 21449];

%% Add band 8.
Band(end+1)         = 8;
F_DL_low_MHz(end+1) = 925;
N_Offs_DL(end+1)    = 3450;
Range_N_DL(end+1,:) = [3450, 3799];
F_UL_low_MHz(end+1) = 880;
N_Offs_UL(end+1)    = 21450;
Range_N_UL(end+1,:) = [21450, 21799];

%% Add band 9.
Band(end+1)         = 9;
F_DL_low_MHz(end+1) = 1844.9;
N_Offs_DL(end+1)    = 3800;
Range_N_DL(end+1,:) = [3800, 4149];
F_UL_low_MHz(end+1) = 1749.9;
N_Offs_UL(end+1)    = 21800;
Range_N_UL(end+1,:) = [21800, 22149];

%% Add band 10.
Band(end+1)         = 10;
F_DL_low_MHz(end+1) = 2110;
N_Offs_DL(end+1)    = 4150;
Range_N_DL(end+1,:) = [4150, 4749];
F_UL_low_MHz(end+1) = 1710;
N_Offs_UL(end+1)    = 22150;
Range_N_UL(end+1,:) = [22150, 22749];

%% Add band 11.
Band(end+1)         = 11;
F_DL_low_MHz(end+1) = 1475.9;
N_Offs_DL(end+1)    = 4750;
Range_N_DL(end+1,:) = [4750, 4949];
F_UL_low_MHz(end+1) = 1427.9;
N_Offs_UL(end+1)    = 22750;
Range_N_UL(end+1,:) = [22750, 22949];

%% Add band 12.
Band(end+1)         = 12;
F_DL_low_MHz(end+1) = 729;
N_Offs_DL(end+1)    = 5010;
Range_N_DL(end+1,:) = [5010, 5179];
F_UL_low_MHz(end+1) = 699;
N_Offs_UL(end+1)    = 23010;
Range_N_UL(end+1,:) = [23010, 23179];

%% Add band 13.
Band(end+1)         = 13;
F_DL_low_MHz(end+1) = 746;
N_Offs_DL(end+1)    = 5180;
Range_N_DL(end+1,:) = [5180, 5279];
F_UL_low_MHz(end+1) = 777;
N_Offs_UL(end+1)    = 23180;
Range_N_UL(end+1,:) = [23180, 23279];

%% Add band 14.
Band(end+1)         = 14;
F_DL_low_MHz(end+1) = 758;
N_Offs_DL(end+1)    = 5280;
Range_N_DL(end+1,:) = [5280, 5379];
F_UL_low_MHz(end+1) = 788;
N_Offs_UL(end+1)    = 23280;
Range_N_UL(end+1,:) = [23280, 23379];

%% Add band 17.
Band(end+1)         = 17;
F_DL_low_MHz(end+1) = 734;
N_Offs_DL(end+1)    = 5730;
Range_N_DL(end+1,:) = [5730, 5849];
F_UL_low_MHz(end+1) = 704;
N_Offs_UL(end+1)    = 23730;
Range_N_UL(end+1,:) = [23730, 23849];

%% Add band 33.
Band(end+1)         = 33;
F_DL_low_MHz(end+1) = 1900;
N_Offs_DL(end+1)    = 36000;
Range_N_DL(end+1,:) = [36000, 36199];
F_UL_low_MHz(end+1) = 1900;
N_Offs_UL(end+1)    = 36000;
Range_N_UL(end+1,:) = [36000, 36199];

%% Add band 34.
Band(end+1)         = 34;
F_DL_low_MHz(end+1) = 2010;
N_Offs_DL(end+1)    = 36200;
Range_N_DL(end+1,:) = [36200, 36349];
F_UL_low_MHz(end+1) = 2010;
N_Offs_UL(end+1)    = 36200;
Range_N_UL(end+1,:) = [36200, 36349];

%% Add band 35.
Band(end+1)         = 35;
F_DL_low_MHz(end+1) = 1850;
N_Offs_DL(end+1)    = 36350;
Range_N_DL(end+1,:) = [36350, 36949];
F_UL_low_MHz(end+1) = 1850;
N_Offs_UL(end+1)    = 36350;
Range_N_UL(end+1,:) = [36350, 36949];

%% Add band 36.
Band(end+1)         = 36;
F_DL_low_MHz(end+1) = 1930;
N_Offs_DL(end+1)    = 36950;
Range_N_DL(end+1,:) = [36950, 37549];
F_UL_low_MHz(end+1) = 1930;
N_Offs_UL(end+1)    = 36950;
Range_N_UL(end+1,:) = [36950, 37549];

%% Add band 37.
Band(end+1)         = 37;
F_DL_low_MHz(end+1) = 1910;
N_Offs_DL(end+1)    = 37550;
Range_N_DL(end+1,:) = [37550, 37749];
F_UL_low_MHz(end+1) = 1910;
N_Offs_UL(end+1)    = 37550;
Range_N_UL(end+1,:) = [37550, 37749];

%% Add band 38.
Band(end+1)         = 38;
F_DL_low_MHz(end+1) = 2570;
N_Offs_DL(end+1)    = 37750;
Range_N_DL(end+1,:) = [37750, 38249];
F_UL_low_MHz(end+1) = 2570;
N_Offs_UL(end+1)    = 37750;
Range_N_UL(end+1,:) = [37750, 38249];

%% Add band 39.
Band(end+1)         = 39;
F_DL_low_MHz(end+1) = 1880;
N_Offs_DL(end+1)    = 38250;
Range_N_DL(end+1,:) = [38250, 38649];
F_UL_low_MHz(end+1) = 1880;
N_Offs_UL(end+1)    = 38250;
Range_N_UL(end+1,:) = [38250, 38649];

%% Add band 40.
Band(end+1)         = 40;
F_DL_low_MHz(end+1) = 2300;
N_Offs_DL(end+1)    = 38650;
Range_N_DL(end+1,:) = [38650, 39649];
F_UL_low_MHz(end+1) = 2300;
N_Offs_UL(end+1)    = 38650;
Range_N_UL(end+1,:) = [38650, 39649];

%% Create table.
T              = table;
T.Band         = Band(:);
T.F_DL_low_MHz = F_DL_low_MHz(:);
T.N_Offs_DL    = N_Offs_DL(:);
T.Range_N_DL   = Range_N_DL;
T.F_UL_low_MHz = F_UL_low_MHz(:);
T.N_Offs_UL    = N_Offs_UL(:);
T.Range_N_UL   = Range_N_UL;


%% Make sure that T.N_Offs_DL = T.Range_N_DL(1).
if any((T.N_Offs_DL - T.Range_N_DL(:,1)) ~= 0)
    error('T.N_Offs_DL ~= T.Range_N_DL(1)');
end

%% Make sure that T.N_Offs_UL = T.Range_N_UL(1).
if any((T.N_Offs_UL - T.Range_N_UL(:,1)) ~= 0)
    error('T.N_Offs_UL ~= T.Range_N_UL(1)');
end

%% Check T.Range_N_DL and T.Range_N_UL from band 1 to band 11.
T1 = T(ismember(T.Band, 1:11), :);
checkTableRangeNDL(T1);

%% Check T.Range_N_DL and T.Range_N_UL from band 12 to band 14.
T1 = T(ismember(T.Band, 12:14), :);
checkTableRangeNDL(T1);

%% Check T.Range_N_DL and T.Range_N_UL from band 33 to band 40.
T1 = T(ismember(T.Band, 33:40), :);
checkTableRangeNDL(T1);


end



function checkTableRangeNDL(T)


for row = 2:length(T.Band)
    if (T.Range_N_DL(row, 1) - T.Range_N_DL(row-1, 2)) ~= 1
        error('T.Range_N_DL is not continuous.');
    end
    if (T.Range_N_UL(row, 1) - T.Range_N_UL(row-1, 2)) ~= 1
        error('T.Range_N_UL is not continuous.');
    end
end


end



% function T = createTable_old
% 
% %% Initialize T.
% T              = table;
% T.Band         = NaN;
% T.F_DL_low_MHz = NaN;
% T.N_Offs_DL    = NaN;
% T.Range_N_DL   = [NaN, NaN];
% T.F_UL_low_MHz = NaN;
% T.N_Offs_UL    = NaN;
% T.Range_N_UL   = [NaN, NaN];
% 
% %% Add band 1.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 1;
% T.F_DL_low_MHz(end) = 2110;
% T.N_Offs_DL(end)    = 0;
% T.Range_N_DL(end,:) = [0, 599];
% T.F_UL_low_MHz(end) = 1920;
% T.N_Offs_UL(end)    = 18000;
% T.Range_N_UL(end,:) = [18000, 18599];
% 
% %% Add band 2.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 2;
% T.F_DL_low_MHz(end) = 1930;
% T.N_Offs_DL(end)    = 600;
% T.Range_N_DL(end,:) = [600, 1199];
% T.F_UL_low_MHz(end) = 1850;
% T.N_Offs_UL(end)    = 18600;
% T.Range_N_UL(end,:) = [18600, 19199];
% 
% %% Add band 3.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 3;
% T.F_DL_low_MHz(end) = 1805;
% T.N_Offs_DL(end)    = 1200;
% T.Range_N_DL(end,:) = [1200, 1949];
% T.F_UL_low_MHz(end) = 1710;
% T.N_Offs_UL(end)    = 19200;
% T.Range_N_UL(end,:) = [19200, 19949];
% 
% %% Add band 4.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 4;
% T.F_DL_low_MHz(end) = 2110;
% T.N_Offs_DL(end)    = 1950;
% T.Range_N_DL(end,:) = [1950, 2399];
% T.F_UL_low_MHz(end) = 1710;
% T.N_Offs_UL(end)    = 19950;
% T.Range_N_UL(end,:) = [19950, 20399];
% 
% %% Add band 5.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 5;
% T.F_DL_low_MHz(end) = 869;
% T.N_Offs_DL(end)    = 2400;
% T.Range_N_DL(end,:) = [2400, 2649];
% T.F_UL_low_MHz(end) = 824;
% T.N_Offs_UL(end)    = 20400;
% T.Range_N_UL(end,:) = [20400, 20649];
% 
% %% Add band 6.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 6;
% T.F_DL_low_MHz(end) = 875;
% T.N_Offs_DL(end)    = 2650;
% T.Range_N_DL(end,:) = [2650, 2749];
% T.F_UL_low_MHz(end) = 830;
% T.N_Offs_UL(end)    = 20650;
% T.Range_N_UL(end,:) = [20650, 20749];
% 
% %% Add band 7.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 7;
% T.F_DL_low_MHz(end) = 2620;
% T.N_Offs_DL(end)    = 2750;
% T.Range_N_DL(end,:) = [2750, 3449];
% T.F_UL_low_MHz(end) = 2500;
% T.N_Offs_UL(end)    = 20750;
% T.Range_N_UL(end,:) = [20750, 21449];
% 
% %% Add band 8.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 8;
% T.F_DL_low_MHz(end) = 925;
% T.N_Offs_DL(end)    = 3450;
% T.Range_N_DL(end,:) = [3450, 3799];
% T.F_UL_low_MHz(end) = 880;
% T.N_Offs_UL(end)    = 21450;
% T.Range_N_UL(end,:) = [21450, 21799];
% 
% %% Add band 9.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 9;
% T.F_DL_low_MHz(end) = 1844.9;
% T.N_Offs_DL(end)    = 3800;
% T.Range_N_DL(end,:) = [3800, 4149];
% T.F_UL_low_MHz(end) = 1749.9;
% T.N_Offs_UL(end)    = 21800;
% T.Range_N_UL(end,:) = [21800, 22149];
% 
% %% Add band 10.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 10;
% T.F_DL_low_MHz(end) = 2110;
% T.N_Offs_DL(end)    = 4150;
% T.Range_N_DL(end,:) = [4150, 4749];
% T.F_UL_low_MHz(end) = 1710;
% T.N_Offs_UL(end)    = 22150;
% T.Range_N_UL(end,:) = [22150, 22749];
% 
% %% Add band 11.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 11;
% T.F_DL_low_MHz(end) = 1475.9;
% T.N_Offs_DL(end)    = 4750;
% T.Range_N_DL(end,:) = [4750, 4949];
% T.F_UL_low_MHz(end) = 1427.9;
% T.N_Offs_UL(end)    = 22750;
% T.Range_N_UL(end,:) = [22750, 22949];
% 
% %% Add band 12.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 12;
% T.F_DL_low_MHz(end) = 729;
% T.N_Offs_DL(end)    = 5010;
% T.Range_N_DL(end,:) = [5010, 5179];
% T.F_UL_low_MHz(end) = 699;
% T.N_Offs_UL(end)    = 23010;
% T.Range_N_UL(end,:) = [23010, 23179];
% 
% %% Add band 13.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 13;
% T.F_DL_low_MHz(end) = 746;
% T.N_Offs_DL(end)    = 5180;
% T.Range_N_DL(end,:) = [5180, 5279];
% T.F_UL_low_MHz(end) = 777;
% T.N_Offs_UL(end)    = 23180;
% T.Range_N_UL(end,:) = [23180, 23279];
% 
% %% Add band 14.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 14;
% T.F_DL_low_MHz(end) = 758;
% T.N_Offs_DL(end)    = 5280;
% T.Range_N_DL(end,:) = [5280, 5379];
% T.F_UL_low_MHz(end) = 788;
% T.N_Offs_UL(end)    = 23280;
% T.Range_N_UL(end,:) = [23280, 23379];
% 
% %% Add band 17.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 17;
% T.F_DL_low_MHz(end) = 734;
% T.N_Offs_DL(end)    = 5730;
% T.Range_N_DL(end,:) = [5730, 5849];
% T.F_UL_low_MHz(end) = 704;
% T.N_Offs_UL(end)    = 23730;
% T.Range_N_UL(end,:) = [23730, 23849];
% 
% %% Add band 33.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 33;
% T.F_DL_low_MHz(end) = 1900;
% T.N_Offs_DL(end)    = 36000;
% T.Range_N_DL(end,:) = [36000, 36199];
% T.F_UL_low_MHz(end) = 1900;
% T.N_Offs_UL(end)    = 36000;
% T.Range_N_UL(end,:) = [36000, 36199];
% 
% %% Add band 34.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 34;
% T.F_DL_low_MHz(end) = 2010;
% T.N_Offs_DL(end)    = 36200;
% T.Range_N_DL(end,:) = [36200, 36349];
% T.F_UL_low_MHz(end) = 2010;
% T.N_Offs_UL(end)    = 36200;
% T.Range_N_UL(end,:) = [36200, 36349];
% 
% %% Add band 35.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 35;
% T.F_DL_low_MHz(end) = 1850;
% T.N_Offs_DL(end)    = 36350;
% T.Range_N_DL(end,:) = [36350, 36949];
% T.F_UL_low_MHz(end) = 1850;
% T.N_Offs_UL(end)    = 36350;
% T.Range_N_UL(end,:) = [36350, 36949];
% 
% %% Add band 36.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 36;
% T.F_DL_low_MHz(end) = 1930;
% T.N_Offs_DL(end)    = 36950;
% T.Range_N_DL(end,:) = [36950, 37549];
% T.F_UL_low_MHz(end) = 1930;
% T.N_Offs_UL(end)    = 36950;
% T.Range_N_UL(end,:) = [36950, 37549];
% 
% %% Add band 37.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 37;
% T.F_DL_low_MHz(end) = 1910;
% T.N_Offs_DL(end)    = 37550;
% T.Range_N_DL(end,:) = [37550, 37749];
% T.F_UL_low_MHz(end) = 1910;
% T.N_Offs_UL(end)    = 37550;
% T.Range_N_UL(end,:) = [37550, 37749];
% 
% %% Add band 38.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 38;
% T.F_DL_low_MHz(end) = 2570;
% T.N_Offs_DL(end)    = 37750;
% T.Range_N_DL(end,:) = [37750, 38249];
% T.F_UL_low_MHz(end) = 2570;
% T.N_Offs_UL(end)    = 37750;
% T.Range_N_UL(end,:) = [37750, 38249];
% 
% %% Add band 39.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 39;
% T.F_DL_low_MHz(end) = 1880;
% T.N_Offs_DL(end)    = 38250;
% T.Range_N_DL(end,:) = [38250, 38649];
% T.F_UL_low_MHz(end) = 1880;
% T.N_Offs_UL(end)    = 38250;
% T.Range_N_UL(end,:) = [38250, 38649];
% 
% %% Add band 40.
% T(end+1,:)          = T(1,:);
% T.Band(end)         = 40;
% T.F_DL_low_MHz(end) = 2300;
% T.N_Offs_DL(end)    = 38650;
% T.Range_N_DL(end,:) = [38650, 39649];
% T.F_UL_low_MHz(end) = 2300;
% T.N_Offs_UL(end)    = 38650;
% T.Range_N_UL(end,:) = [38650, 39649];
% 
% %% Delete the first dummy row.
% T(1,:) = [];
% 
% %% Make sure that T.N_Offs_DL = T.Range_N_DL(1).
% if any((T.N_Offs_DL - T.Range_N_DL(:,1)) ~= 0)
%     error('T.N_Offs_DL ~= T.Range_N_DL(1)');
% end
% 
% %% Make sure that T.N_Offs_UL = T.Range_N_UL(1).
% if any((T.N_Offs_UL - T.Range_N_UL(:,1)) ~= 0)
%     error('T.N_Offs_UL ~= T.Range_N_UL(1)');
% end
% 
% %% Check T.Range_N_DL and T.Range_N_UL from band 1 to band 11.
% T1 = T(ismember(T.Band, 1:11), :);
% checkTableRangeNDL(T1);
% 
% %% Check T.Range_N_DL and T.Range_N_UL from band 12 to band 14.
% T1 = T(ismember(T.Band, 12:14), :);
% checkTableRangeNDL(T1);
% 
% %% Check T.Range_N_DL and T.Range_N_UL from band 33 to band 40.
% T1 = T(ismember(T.Band, 33:40), :);
% checkTableRangeNDL(T1);
% 
% 
% end



