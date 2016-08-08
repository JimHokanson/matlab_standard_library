The startup script
------------------

TODO: This needs to be completed

The function startup(), if on the path, is run when Matlab starts up.

Example Script:
---------------
addpath('C:\repos\matlab_git\matlab_standard_library')

sl.initialize();
sl.path.addPackages({'bladder_analysis','ad_sdk','hdf5_matlab','matlab_tdt'});

dbstop if error

cd('C:\repos\matlab_git'); 