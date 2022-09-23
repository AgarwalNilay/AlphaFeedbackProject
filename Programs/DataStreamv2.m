function [TimeSeries, TimeStamps, SignalLims] = DataStreamv2(inlet, dt)
    disp('Now receiving data...');
    TimeSeries = zeros(8,1);
    TimeStamps = zeros(1,1);
    count = 1;
    while true
        [dataVal,timestamp] = inlet.pull_sample();
        %%fprintf('%f\t',dataVal);
        %%fprintf('%f\n',timestamp);
        %fprintf('%.2f\t',dataVal);
        %fprintf('%.5f\n',timestamp);
        TimeSeries(:, count) = dataVal;
        TimeStamps(count) = timestamp;
        if count == dt*250
            %disp('Okay this works')
            break
        end
        count = count + 1;
    end
    
    %Processing the input signal
    %Pipeline1
    %{
    for i = (1:8)
        signal = TimeSeries(i,:);
        %signal = bandpass(signal, [1 60], 250, 'Steepness', 1);
        signal = highpass(signal, 1, 250);
        %signal = bandstop(signal, [49 51], 250);
        TimeSeries(i,:) = signal;
    end
    %}

    %Pipeline 2: Only Filtering Line Noise it seems
    %{
    Fs = 250;
    for i = 1:8
        signal = TimeSeries(i,:);
        fftX = fft(signal);
        absfftX = abs(fftX);
        freqVals = 0:1:Fs-1; 
        freqPos = find(freqVals>47 & freqVals<53);
        maxPos = find(absfftX==max(absfftX(freqPos)));
        fftNX = zeros(1,length(fftX));
        fftNX(maxPos) = fftX(maxPos);
        fftNX(48:52) = fftX(48:52);
        %fftNX(1) = fftX(1);
        noiseSignal = ifft(fftNX);
        noiseCorrectedSegment = signal - noiseSignal;
        TimeSeries(i,:) = noiseCorrectedSegment;
    end
    %}
    
    %%{
    for i = (1:8)
        signal = TimeSeries(i, :);
        avgsig = mean(signal);
        signal = signal - avgsig;
        TimeSeries(i, :) = signal;
    end
    %}
    % Is there some end modification of the timestamps needed?
    SignalLims = [-50 50];%[min(TimeSeries) max(TimeSeries)];
end