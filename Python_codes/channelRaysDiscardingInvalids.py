import numpy as np
import h5py


def DiscardingInvalids(allEpisodeData,sceneNum,rxtxPair):
	channelRays=np.squeeze(allEpisodeData[:,:,rxtxPair-1,sceneNum-1])
	[numRaysPerTxRxPair, numParametersPerRay]=channelRays.shape
	theNaN = np.isnan(channelRays)
	sumOfNaN=np.count_nonzero(theNaN)
	if  (sumOfNaN > 0):  	#there is at least one NaN, so, need to check
	    	if  (sumOfNaN == numRaysPerTxRxPair*numParametersPerRay): #the whole channel is invalid (there is not a single valid ray)
	        	channelRays = -1
	    	else:
	    		if (theNaN[:,1]=='False'):
	        		validRays = 1
	        		channelRays = channelRays[validRays,:]
	return(channelRays)

