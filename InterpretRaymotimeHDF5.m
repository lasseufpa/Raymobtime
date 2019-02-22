%Interpret HDF5 files from Raymobtime
%e-mail: raymobtime@gmail.com

%Inputs
numEpisodes = 1;          %Number of episodes to be read
raymobtimePath = 'C:\';   %Inset the location of the files to be read
filePrefix= '';           %Include the file name without the number that counts episodes
extension='.hdf5';        %Include file extension
numOfInvalidChannels = 0; %For computing number of invalid channels, if any

for e=0:numEpisodes-1
    fileName = [raymobtimePath filePrefix num2str(e) extension];
    disp(['Processing ' fileName])
    
    allEpisodeData=readAllEpisodeData(fileName);
    [numScenes, numTxRxPairs, maxNumPaths, numPathParameters]=size(allEpisodeData);
    
    for s=1:numScenes
        for r=1:numTxRxPairs
            disp(['Processing episode ' num2str(e) ' scene ' ...
                num2str(s) ' of receiver ' num2str(r)])
            
            % Check if all rays are valid
            channelRays=channelRaysDiscardingInvalids(allEpisodeData,s,r);
            if  channelRays == -1 %value returned when all rays are invalid
                numOfInvalidChannels = numOfInvalidChannels + 1;
                continue %next Tx / Rx pair
            end
            
            [numPaths, numParameters] = size(channelRays);
            %support files with 7 or 8 ray information (8 is ray phase)
            doesItIncludeRayPhase = 0;
            if numParameters==8
                doesItIncludeRayPhase = 1;
            end
            %Insite adopts theta as elevation and phi as azimuth
            %<received power(dBm)>
            %<time of arrival(sec)>
            %<arrival theta(deg)>  => elevation
            %<arrival phi(deg)> => azimuth
            %<departure theta(deg)> => elevation
            %<departure phi(deg)> => azimuth
            %InSite provides angles in degrees. Convert to radians
            %Note that Python wrote departure first, while InSite writes arrival.
            gainMagnitude = channelRays(:,1); %received power in dBm
            timeOfArrival = channelRays(:,2); %time of arrival in seconds
            AoD_el = channelRays(:,3); %elevation angle of departure in degrees
            AoD_az = channelRays(:,4); %azimuth angle of departure in degrees
            AoA_el = channelRays(:,5); %elevation angle of arrival in degrees
            AoA_az = channelRays(:,6); %azimuth angle of arrival in degrees
            isLOS = channelRays(:,7);  %flag 1 for LOS ray, flag 0 for NLOS ray
            if doesItIncludeRayPhase == 0
                %it was not specified in first 5gm data version, so if we don't
                %have it, generate uniformly distributed phase
                gainPhase = 2*pi*rand(size(gainMagnitude));
            else
                gainPhase = channelRays(:,8)*pi/180; %ray phases recorded from InSite;
            end
            
            gainMagnitude = 10.^(0.1*gainMagnitude); %transform to linear
            complexGain=gainMagnitude .* exp(1j * gainPhase); %consider complex gain
            isChannelLOS = sum(isLOS); 
            
            
            %%Insert desired post processing of ray data
            
        end        
    end    
end
