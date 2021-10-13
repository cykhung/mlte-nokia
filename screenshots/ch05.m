%% Cell Search
%
% * Turn off cell phone.
%
% * I am in US. Hop on to a plane and you land in Europe.
%
% * Turn on cell phone.
%
% * Cell phone only knows DL carrier frequency (e.g. BS tx DL at 750 MHz).
%
% * Lock onto PSS:
%
%       + Frequency Synchronization with BS
%
%       + Timing Synchronization with BS:
%
%           + OFDM Symbol timing syn
%           + Slot timing syn
%           + Half frame timing syn
%
%       + N_2_ID = [0, 1, 2].
%
%       + N_cell_ID = 3*N_1_ID + N_2_ID = [0, 1, 2, ..., 503].
%
% * Lock onto SSS:
%
%       + Frame timing syn.
%
%       + N_1_ID = [0, 1, ..., 167].
%
%       + N_cell_ID = 3*N_1_ID + N_2_ID.
%
% * Decode BCH (Broadcast Channel)
%
%       + Information goes through transport channel processing and physical
%         channel processing, 16-bit CRC, convolutional code, QPSK modulation.
%
%       + Grab Cell Specific Reference Signal (Pilot)
%         (Red resouce elements)
%         Use pilot for channel estimation
%
%       + Grab PBCH resource elements.
%
%       + Decode PBCH to get MIB (Master Information Block).
%         MIB = vector of 24 bits.
%
% * Decode System Information Block (SIB)
%
%       + SIB is transmitted using PDSCH.

