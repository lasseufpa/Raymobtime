function rays=readChannelEpisodeHDF5File(fileName)
% function rays=readChannelEpisodeHDF5File(fileName)
%Read all valid channel matrices in the episode within fileName.
%Returns a data structure with valid channels.
%Each row of rays has a struct with 7 or 8 fields: path_gain, timeOfArrival,
%departure_elevation, departure_azimuth,  arrival_elevation,
%arrival_azimuth, isLOS. The 8-th are the phases of the ray and may not
%be present. Angles are read in degrees and converted to radians.
%NOTE: this returns only the valid rays (the number of rays may vary given
%that not all channels have the maximum number of rays). Also, the
%information about the specific scene and receiver is lost. In case you
%need this information, use readAllEpisodeData.m

%Read hdf5 file in Matlab
allEpisodeData=readAllEpisodeData(fileName);

[numScenesPerEpisode, numTxRxPairsPerScene, numRaysPerTxRxPair, ...
  numParametersPerRay] = size(allEpisodeData);

%% Now create data structure with valid channels
numOfInvalidChannels = 0;
numOfValidChannels = 0;
currentChannel = 1;
%the array rays will grow inside the loop
for s=1:numScenesPerEpisode
    for r=1:numTxRxPairsPerScene
        insiteData=channelRaysDiscardingInvalids(allEpisodeData,s,r);
        if  insiteData == -1 %value returned for invalid channels
            numOfInvalidChannels = numOfInvalidChannels + 1;
            continue %next Tx / Rx pair
        end
        %received power
        powerLinearScale = (10.^(insiteData(:,1)/10)); %log (dBm) to mWatts
        %assume the transmitter used power of 0 dBm
        gainMagnitude = sqrt(powerLinearScale);
        
        timeOfArrival = insiteData(:,2);
        
        %Insite adopts theta as elevation and phi as azimuth
        %path summary:
        %<path number>
        %<total interactions for path> (not including Tx and Rx)
        %<received power(dBm)>
        %<time of arrival(sec)>
        %<arrival theta(deg)>  => elevation
        %<arrival phi(deg)> => azimuth
        %<departure theta(deg)> => elevation
        %<departure phi(deg)> => azimuth
        %InSite provides angles in degrees. Convert to radians
        %Note that Python wrote departure first, while InSite writes
        %arrival.
        AoD_el = degtorad(insiteData(:,3));
        AoD_az = degtorad(insiteData(:,4));
        AoA_el = degtorad(insiteData(:,5));
        AoA_az = degtorad(insiteData(:,6));
        isLOS = insiteData(:,7);
        if numParametersPerRay == 9
            %the phase was extracted from the channel impulse respose
            rayPhases = degtorad(insiteData(:,8));
            %and also the angle the receiver object has
            rxObjectAngle = degtorad(insiteData(:,9));
        elseif numParametersPerRay == 8
            %the phase was extracted from the channel impulse respose
            rayPhases = degtorad(insiteData(:,8));
        elseif numParametersPerRay == 7
            %create uniform phase
            rayPhases = 360*rand(size(AoA_az));
        else
            error_msg = ['Unexpected! numParametersPerRay = ' ...
                num2str(numParametersPerRay)]
            error(error_msg )
        end
        
        %order the rays to have the shortest path first
        [timeOfArrival,sortedIndices] = sort(timeOfArrival);
        theseRays=[];
        theseRays.gainMagnitude = gainMagnitude(sortedIndices);
        theseRays.timeOfArrival = timeOfArrival;
        theseRays.AoA_el = AoA_el(sortedIndices); %not currently used
        theseRays.AoD_el = AoD_el(sortedIndices); %not currently used
        theseRays.AoA_az = AoA_az(sortedIndices);
        theseRays.AoD_az = AoD_az(sortedIndices);
        theseRays.isLOS = isLOS(sortedIndices);
        theseRays.rayPhases = rayPhases(sortedIndices);
        theseRays.rxObjectAngle = rxObjectAngle(sortedIndices);
        
        rays(currentChannel) = theseRays; %growing inside loop
        currentChannel = currentChannel + 1;
        numOfValidChannels = numOfValidChannels+1;
    end
end

%% In case there is no valid channel
%if the Tx gain is too small, maybe no rays arrive at the receiver
if numOfValidChannels == 0
    rays=[];
    warning(['No valid channels in file ' fileName])
    return
end
