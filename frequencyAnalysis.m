function [figHandle] = frequencyAnalysis(timeSeries, eventTimes, frequency, troubleshooting)
%frequencyAnalysis produces thefrequency content of epileptiform events.
%   This function uses spectrogram to analyze the frequency content of the
%   epileptiform forms that are entered into the function. The window size
%   being analyzed is 10s, so the smallest event can only be 10 s (a SLE,
%   by definition). This allows the Rayleigh frequency to be 0.1 Hz.
%   Authors: Michael Chang, Liam Long, and Kramay Patel.

%Set default values, if not specified
if nargin <3
    frequency = 10000;  %Hz\
    troubleshooting = [];
end

if troubleshooting 
  
    %Set variables    
    startLocation = int64(eventTimes(1)*frequency);
    endLocation = int64(eventTimes(2)*frequency);

    %Epileptiform events to analyze
    eventVector = timeSeries(startLocation:endLocation);  %event vector
    timeVector = (0:(length(eventVector)-1))/frequency;  %make time vector
    timeVector = timeVector';

    %Energy content of epileptiform event
    [s,f,t] = spectrogram (eventVector, 10*frequency, 8*frequency, [], frequency, 'yaxis');

    %Dominant Frequency at each time point
    [maxS, idx] = max(abs(s));
    maxFreq = f(idx);

    %Plot Figures
    figHandle = figure;
    set(gcf,'NumberTitle','off', 'color', 'w'); %don't show the figure number
    set(gcf,'Name', sprintf ('Epileptiform Event #%d', i)); %select the name you want
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot (3,1,1)
    plot (timeVector, eventVector)
    title (sprintf('LFP Bandpass Filtered (0-100 Hz), Event #%d', i))
    xlabel('Time (sec)')
    ylabel('Voltage (mV)')
    axis tight

    subplot (3,1,2)
    contour(t,f,abs(s).^2)
    c = colorbar;
    c.Label.String = 'Power (mV/Hz)^2';    %what is the unit really called? 
    ylim([0 20])
    title (sprintf('Frequency Content of Event #%d', i))
    ylabel('Frequency (Hz)')
    xlabel('Time (sec)')

    subplot (3,1,3)
    plot(t,maxFreq) 
    title (sprintf('Dominant Frequency over duration of Event #%d', i))
    ylabel('Frequency (Hz)')
    xlabel('Time (sec)')
    axis tight
    
end





