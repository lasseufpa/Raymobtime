function array=readArrayFromHDF5(fileName, arrayName)
% function array=readArrayFromHDF5(fileName, arrayName)
%Read a HDF5 written by e.g. Python

%See
%https://stackoverflow.com/questions/21624653/python-created-hdf5-dataset-transposed-in-matlab
%do not forget the / in second argument '/arrayName', which was
%used when the file was saved
array=h5read(fileName,['/' arrayName]);
%need to permute dimensions of 4-d tensor
array = permute(array,ndims(array):-1:1);
