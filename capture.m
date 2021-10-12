%% Start from scratch.
clear all  %#ok<CLALL>
rng(123, 'twister')


%% Create receiver object
%
% * The following table shows examples of the DL center frequencies:
%
%		Service Provider       Band     DL UARFCN    DL Center Frequency
%    ----------------------    ----     ---------    -------------------
%      Verizon (Natick, MA)     13         5230           751    MHz
%      Verizon (US)             2          1125        	  1.9825 GHz
%      Verizon (US)             4          2125        	  2.1275 GHz
%      Verizon (Torrance, CA)   13         5230           751    MHz
%      Verizon (Torrance, CA)   2          1000           1.97   GHz
%      Verizon (Torrance, CA)   4          2100           2.125  GHz
%      AT&T    (Natick, MA)     12         5110           739    MHz
%      AT&T    (Natick, MA)     17         5780           739    MHz
%
rx                    = sdrrx('Pluto');
rx.CenterFrequency    = 739e6;
rx.BasebandSampleRate = 61.44e6;
rx.GainSource         = 'Manual';
rx.Gain               = 50;
rx.OutputDataType     = 'int16';


%% Capture.
N          = 16777216;
[x, mdata] = capture(rx, N);


%% Save IQ samples to mat file.
fs = mdata.BasebandSampleRate;
save capture.mat x fs


%% Convert x from int16 to double for plotting purpose.
x = double(x) / 32768;


%% Plot time domain.
figure(1)
clf
n  = 0 : (length(x) - 1);
t  = n / fs;
subplot(311)
plot(t, abs(x), 'r');
xlabel('Time (seconds)');
ylabel('abs(x)');
title('Time Domain: ABS(X)')
subplot(312)
plot(t, real(x), 'r');
xlabel('Time (seconds)');
ylabel('real(x)');
title('Time Domain: REAL(X)')
subplot(313)
plot(t, imag(x), 'r');
xlabel('Time (seconds)');
ylabel('imag(x)');
title('Time Domain: IMAG(X)')


%% Plot frequency domain.
[P, f] = pwelch(x, kaiser(8192, 19), 0, 8192, fs, 'centered');
figure(2)
clf
plot(f/1e6, 10*log10(P), 'r');
title('Power Spectral Density of Captured Baseband Samples')
xlabel('Frequency (MHz)');
ylabel('PSD (dB)');

