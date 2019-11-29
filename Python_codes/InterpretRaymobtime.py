#Interpret HDF5 files from raymobtime
#e-mail: raymobtime@gmail.com
import h5py
import math
import numpy as np
import readAllEpisodeData as rda
import channelRaysDiscardingInvalids as chin
import os

#Inputs
numEpisodes = range(0,1,1) #interator that determines number of episodes to be read
raymobtimepath = '/home/lasse/Documentos/Isabela/5GMDATA/hdf5_dataset/insite_data_s001_carrier2.8GHz/' #Insert the location of the files to be read
filePrefix= 'rosslyn_fixed_2.8GHz_Ts5ms_V_e';           #Include the file name without the number that counts episodes
extension='.hdf5';        #Include file extension
numOfInvalidChannels = 0 #For computing number of invalid channels, if any
arrayName = 'allEpisodeData' #Array name, other arrays can be checked with "list(array.keys())" comand

for index in numEpisodes:
   fileName = os.path.join(raymobtimepath,filePrefix+'{0}'.format(index)+extension) #filename in hdf5 extension, without the episode counter
   print ('Processing {}'.format(fileName))
   allEpisodeData = rda.Rdata(fileName)
   [numScenes, numTxRxPairs, maxNumPaths, numPathParameters]=allEpisodeData.shape
   i_scenes =range(1,numScenes+1,1)
   i_pair=range(1,numTxRxPairs+1,1)

   for index_s in i_scenes:
		for index_p in i_pair:
			print ('Processing episode  {}'.format(index)+' scene {}'.format(index_s)+' of receiver {}'.format(index_p))

			#Check if all rays are valid
			channelRays=chin.DiscardingInvalids(allEpisodeData,index_s,index_p)
			if  (channelRays.all == -1): #value returned when all rays are invalid
				numOfInvalidChannels = numOfInvalidChannels + 1
				continue #next Tx / Rx pair

			[numPaths, numParameters] = channelRays.shape   #support files with 7 or 8 ray information (8 is ray phase)
			doesItIncludeRayPhase = 0

			if (numParameters==8):
				doesItIncludeRayPhase = 1

			gainMagnitude = channelRays[:,0] # received power in dBm
			timeOfArrival = channelRays[:,1] #time of arrival in seconds
			AoD_el = channelRays[:,2] #elevation angle of departure in degrees
			AoD_az = channelRays[:,3] #azimuth angle of departure in degrees
			AoA_el = channelRays[:,4] #elevation angle of arrival in degrees
			AoA_az = channelRays[:,5] #azimuth angle of arrival in degrees
			isLOS = channelRays[:,6]  #flag 1 for LOS ray, flag 0 for NLOS ray
			if (doesItIncludeRayPhase == 0):
				gainPhase = 2*math.pi*np.random.uniform(0,1,len(gainMagnitude))
				# it was not specified in first 5gm data version, so if we don't
				# have it, generate uniformly distributed phase
			else:
				gainPhase = channelRays[:,7]*math.pi/180 #ray phases recorded from InSite
			
			gainMagnitude = np.power(10,(0.1*gainMagnitude)) #transform to linear
			complexGain=np.power(gainMagnitude,1j * gainPhase) #consider complex gain
			isChannelLOS = sum(isLOS)