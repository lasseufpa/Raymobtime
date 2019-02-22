function allEpisodeData=readAllEpisodeData(fileName)
% function allEpisodeData=readAllEpisodeData(fileName)
%Read all episode data within given file.
%Returns a data structure with all channels, scenes and rays.
%Each row of rays has a struct with 7 or 8 fields: path_gain, timeOfArrival,
%departure_elevation, departure_azimuth,  arrival_elevation,
%arrival_azimuth, isLOS. The 8-th are the phases of the ray and may not
%be present. Angles are read in degrees and converted to radians.
%NOTE: this returns only the valid rays (the number of rays may vary given
%that not all channels have the maximum number of rays). Also, the
%information about the specific scene and receiver is lost. In case you
%need this information, use the first 2 lines of code and deal directly
%with array allEpisodeData.

allEpisodeData=readArrayFromHDF5(fileName, 'allEpisodeData');

dimension = length(size(allEpisodeData));
if dimension == 3
    %assumes the episode has just one scene and Matlab turned the 4d into
    %a 3d, so add a singleton dimension.
    %From:
    %https://stackoverflow.com/questions/32583295/how-can-i-add-a-trailing-singleton-dimension-to-a-matrix
    allEpisodeData = permute(allEpisodeData, [4 1 2 3]);
end
