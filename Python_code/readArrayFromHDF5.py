'''function allEpisodeData=readAllEpisodeData(fileName) Read all episode data within given file. Returns a data structure with all channels, scenes and rays. 
Each row of rays has a struct with 7 or 8 fields: path_gain, timeOfArrival, departure_elevation, departure_azimuth,  arrival_elevation, arrival_azimuth, isLOS. 
The 8-th are the phases of the ray and may not be present. Angles are read in degrees and converted to radians. NOTE: this returns only the valid rays (the number of rays may vary given that not all channels have the maximum number of rays). Also, the information about the specific scene and receiver is lost. In case you need this information, use the first 2 lines of code and deal directly with array allEpisodeData.'''
import numpy as np
import h5py


def readArray(fileName, arrayName):
   openFile = h5py.File(fileName, 'r')
   #tst = list(array.keys())
   array = openFile[arrayName]
   zyx = np.arange(array.ndim)[::-1]  
   array = np.transpose(array,zyx)

   return array


  



   

