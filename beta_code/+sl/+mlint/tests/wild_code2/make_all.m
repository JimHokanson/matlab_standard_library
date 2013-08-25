function make_all
% MAKE_ALL Make all the mex files in the matlab repository
%
%
% tags: mex support
% see also: make

% Make the one object to rule them all
% =========================================================================
try
make_MexSupport
catch ME
   simpleExceptionDisplay(ME)
   % This is a fatal error because all subsequent objects require MexSupport
   fprintf('Could not construct Mex Support, aborting!');
   return
end

% CalcFrFast requires computeEdgeIndices.obj object to be compiled first 
% =========================================================================
pushd(fullfile(MATLAB_SVN_ROOT,'arrayRelated','private'))
make_computeEdgeIndices
popd

pushd(fullfile(MATLAB_SVN_ROOT,'spikeHandling','private'))
make_calcFrFast
popd


% The rest can be done in any order
% =========================================================================
make_dir_list = { ...
    fullfile(MATLAB_SVN_ROOT,'GeneralMatlab','private'), ... 1
    fullfile(MATLAB_SVN_ROOT,'TDT','dataRetrieval','private'), ... 2
    fullfile(MATLAB_SVN_ROOT,'neuralFormats','plexon','private'), ... 3
    fullfile(MATLAB_SVN_ROOT,'arrayRelated','private'), ... 4
    fullfile(MATLAB_SVN_ROOT,'statsRelated','private'), ... 5
    fullfile(MATLAB_SVN_ROOT,'pathAndDirectoryTools','private'),... 7
    fullfile(MATLAB_SVN_ROOT,'fileRelated','private'), ... 8
    };

makefiles = { ...
    {'make_serialize' 'make_deserialize' 'make_help'} , ... 1
    {'make_getcontinuousdata', 'make_getEventList'}  , ...  2
    {'make_PLXLibrary'}, ... 3
    {'make_qinterp1' 'make_computeNearestIndices'}, ... 4
    {'make_mean','make_pearsoncorr','make_subsetID4'}, ... 5
    {'make_dir'}, ... 7
    {'make_fread','make_fread2'}, ... 8
    };
failures = {};
for iiDir = 1:length(make_dir_list)
    this_dir = make_dir_list{iiDir};
    pushd(this_dir);
    for iiMakefile = 1:length(makefiles{iiDir})
        this_makefile = makefiles{iiDir}{iiMakefile};
        fprintf('%s\n',this_makefile);
        try
            eval(this_makefile);
        catch ME
            simpleExceptionDisplay(ME)
            failures = [failures this_makefile];
        end
    end
    popd;
end
if ~isempty(failures)
   fprintf('Failed to Compile the following files:\n\t%s\n',cellArrayToString(failures,'\n\t')) 
end