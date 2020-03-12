function channelRays=channelRaysDiscardingInvalids(allEpisodeData,sceneNum,rxtxPair)
%function channelRays=channelRaysDiscardingInvalids(allEpisodeData,sceneNum,rxtxPair)
%return only valid rays
channelRays = squeeze(allEpisodeData(sceneNum,rxtxPair,:,:));
[numRaysPerTxRxPair, numParametersPerRay]=size(channelRays);
theNaN = isnan(channelRays);
sumOfNaN = sum(theNaN(:));
if  sumOfNaN > 0
    %there is at least one NaN, so, need to check
    if  sumOfNaN == numRaysPerTxRxPair*numParametersPerRay
        %the whole channel is invalid (there is not a single valid
        %ray)
        channelRays = -1;
    else
        validRays = (theNaN(:,1)==0);
        channelRays = channelRays(validRays,:);
    end
end
