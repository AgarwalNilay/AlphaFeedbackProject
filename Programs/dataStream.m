function [timeSeries,timeStamps] = dataStream(inlet,hdr,dt)
    disp('Now receiving data...');
    numTimePoints = dt*hdr.Fs;
    numChannels = hdr.nChans;
    
    timeSeries = zeros(numChannels,numTimePoints);
    timeStamps = zeros(1,numTimePoints);
    count = 1;
    while true
        [dataVal,timeStamp] = inlet.pull_sample();
        timeSeries(:,count) = dataVal;
        timeStamps(count) = timeStamp;
        if count == numTimePoints
            break
        end
        count = count + 1;
    end

    % DC Correction
    for i = 1:numChannels
        signal = timeSeries(i,:);
        avgsig = mean(signal);
        signal = signal - avgsig;
        timeSeries(i,:) = signal;
    end
end