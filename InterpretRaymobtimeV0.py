#Interpret HDF5 files from raymobtime
#e-mail: raymobtime@gmail.com
import h5py
import numpy
import readAllEpisodeData as rda
#Inputs
numEpisodes = range(0,200,1) #interator that determines number of episodes to be read
raymobtimepath = 'C:' #Insert the location of the files to be read
numOfInvalidChannels = 0

for index in numEpisodes:
   fileName = ('rosslyn_fixed_2.8GHz_Ts5ms_V_e{}.hdf5'.format(index)) #filename in hdf5 extension, without the episode counter
   print ('processing {}'.format(fileName))

teste = rda.readArray(fileName)
print (teste)
