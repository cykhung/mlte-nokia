function tx = jam(band, x)

% >> tx = jam(band, x)
% >> release(tx)

%% Construct pluto tx object.
tx = sdrtx('Pluto');
switch band
case 4
    tx.CenterFrequency = ltefreq('dl', 4, 2050) * 1e6;
case 2
    tx.CenterFrequency = ltefreq('dl', 2, 1025) * 1e6;
case 13
    tx.CenterFrequency = ltefreq('dl', 13, 5230) * 1e6;
otherwise
    error('Invalid band.');
end
tx.Gain               = 0;
tx.BasebandSampleRate = x.Fs;


%% Transmit repeat
transmitRepeat(tx, x.waveform)


end

