function [ epileptiform, artifacts ] = detectEvents(LFP, minPeakHeight, minPeakDistance)
%UNTITLED4 Summary of this function goes here
%   Input the filtered LFP you want to detect events from


%Find the quantiles using function quartilesStat
[mx, Q] = quartilesStat(LFP);

%Default values, if minPeakHeight and minPeakDistance is not specified 
if nargin<2
    minPeakHeight = Q(1)*20;   %spike amplitude >40x 3rd quartile 
    minPeakDistance = 10000;    %spikes seperated by 1.0 seconds
end

%% Find prominient, distinct spikes in Derivative of filtered LFP (1st search)
[pks_spike, locs_spike] = findpeaks (LFP, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance);

%% Finding artifacts (Calls function findArtifact.m)
artifacts = findArtifact(LFP, Q(3)*40, 10000);

%% remove artifact spiking (from array of prominient spikes)
for i=1:size(artifacts,1)
    for j=1:numel(locs_spike)
        if locs_spike(j)>=artifacts(i,1) && locs_spike(j)<=artifacts(i,2) 
            locs_spike(j)=-1;
        end
    end
    
end
    %remove spikes that are artifacts
    locs_spike(locs_spike==-1)=[];
       
%% Finding onset 

%Find distance between spikes in data
interSpikeInterval = diff(locs_spike);

%insert "0" into the start interSpikeInterval; allows index to correspond 
n=1;
interSpikeInterval(n+1:end+1,:) = interSpikeInterval(n:end,:);
interSpikeInterval(n,:) = (0);

%Find spikes following 10 s of silence (assume onset)
locs_onset = find (interSpikeInterval(:,1)>100000);

%insert the first epileptiform event into array (not detected with algo)
n=1;
locs_onset(n+1:end+1,:) = locs_onset(n:end,:);
locs_onset(n) = n;
    
               
%% finding Offset 
%should not be a light-triggered spike or an artifact

offsetTimes = zeros(numel (locs_onset),1);

locs_offset = locs_onset - 1;
locs_offset(1) = [];    % there is no spike preceding the very 1st spike
locs_offset(end) = locs_spike(end,1) %insert last spike as last event's offset

for i=1:numel(locs_offset);
    offsetTimes(i) = time(locs_spike(locs_offset(i)));      
end


offsetTimes(end) = time(locs_spike(end,1));

%% Onset times (s)
onsetTimes = zeros(numel (locs_onset),1);
for i=1:numel(locs_onset)
      onsetTimes(i) = time(locs_spike(locs_onset(i)));      
end

%% find epileptiform event duration
duration = offsetTimes-onsetTimes;

%putting it all into an array 
epileptiform = [onsetTimes, offsetTimes, duration];

end

