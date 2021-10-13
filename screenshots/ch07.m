%% Subframe Processing for UE Receiver
%
% * UE wakes up at beginning of a subframe
%
% * Grab red resource elements (i.e. CSRS) for channel estimation.
%
% * Grab PCFICH (white resource elements). Tell you number of OFDM symbols
%   for control region.
%
% * Grab PDCCH (yellow resource elements). Tell you if you have anything to 
%   decode in PDSCH (green resource elements).
%
% * If nothing to decode in PDSCH, then go to sleep.


