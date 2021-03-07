#Interpret HDF5 files from raymobtime
#e-mail: raymobtime@gmail.com

import h5py
import math
import numpy as np
import readAllEpisodeData as rda
import channelRaysDiscardingInvalids as chin
import os

#Inputs
numEpisodes = range(0,100,1) #interator that determines number of episodes to be read
insite_version = 3.2 #consult on raymobtime datasets table
raymobtimepath = './ray_tracing_data_s008_carrier60GHz' #Insert the location of the files to be read
filePrefix = 'rosslyn_mobile_60GHz_ts0.1s_V_Lidar_e';           #Include the file name without the number that counts episodes
extension ='.hdf5';        #Include file extension
numOfInvalidChannels = 0 #For computing number of invalid channels, no need to change
arrayName = 'allEpisodeData' #Array name, other arrays can be checked with "list(array.keys())" comand
# output_parameters [0] gainMagnitude,[1] timeOfArrival,[2] AoD_el,[3] Aod_az,[4] AoA_el,[5] AoA_az,[6] isLOS,[7] gainPhase

for index in numEpisodes:
   fileName = os.path.join(raymobtimepath,filePrefix+'{}'.format(index)+extension) #filename in hdf5 extension, without the episode counter
   print ('Processing {}'.format(fileName))
   allEpisodeData = rda.Rdata(fileName)
   [numPathParameters, maxNumPaths, numTxRxPairs, numScenes]=allEpisodeData.shape
   i_scenes =range(1,numScenes+1,1)
   i_pair=range(1,numTxRxPairs+1,1)


   for index_s in i_scenes:
        for index_p in i_pair:
            print ('Processing episode  {}'.format(index)+' scene {}'.format(index_s)+' of receiver {}'.format(index_p))
            channelRays=chin.DiscardingInvalids(allEpisodeData,index_s,index_p)
            channel_type = type(channelRays)
            #print(channelRays)
            if channel_type == int:
                if  (channelRays == -1): #value returned when all rays are invalid
                    numOfInvalidChannels = numOfInvalidChannels + 1
                    continue #next Tx / Rx pair
            elif channel_type == np.ndarray:
                if  (channelRays.all() == -1): #value returned when all rays are invalid
                    numOfInvalidChannels = numOfInvalidChannels + 1
                    continue #next Tx / Rx pair

            [numParameters, numPaths] = channelRays.shape   #support files with 7 or 8 ray information (8 is ray phase)
            doesItIncludeRxAngle = 0

            if (numParameters >= 9):
                doesItIncludeRxAngle = 1

            gainMagnitude = channelRays[0,:] # received power in dBm
            timeOfArrival = channelRays[1,:] #time of arrival in seconds
            AoD_el = channelRays[2,:] #elevation angle of departure in degrees
            AoD_az = channelRays[3,:] #azimuth angle of departure in degrees
            AoA_el = channelRays[4,:] #elevation angle of arrival in degrees
            AoA_az = channelRays[5,:] #azimuth angle of arrival in degrees
            isLOS = channelRays[6,:]  #flag 1 for LOS ray, flag 0 for NLOS ray
            if (insite_version <= 3.2):
                gainPhase = 2*math.pi*np.random.uniform(0,1,len(gainMagnitude))
                # it was not specified in first 5gm data version, so if we don't
				# have it, generate uniformly distributed phase
            else:
                gainPhase = channelRays[7,:]*math.pi/180 #ray phases recorded from InSite
            if doesItIncludeRxAngle:
                RxAngle = channelRays[8,:]
			
            gainMagnitude = np.power(10,(0.1*gainMagnitude)) #transform to linear
            complexGain=np.power(gainMagnitude,1j * gainPhase) #consider complex gain
            isChannelLOS = sum(isLOS)
            #example: Return gainMagnitude (options - timeOfArrival, AoD_az, AoD_el, 
            # AoA_az, AoA_el, isLOS, gainPhase, RxAngle)
            print(gainMagnitude)
