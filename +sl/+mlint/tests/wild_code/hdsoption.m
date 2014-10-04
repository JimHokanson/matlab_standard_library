function out = hdsoption(varargin)                                              
  %HDSOPTION(...)  Set options for HDS database behavior.
  %   HDSOPTION('optionStr', Value, ...) sets the option
  %   definined in 'optionStr' to 'value'. For all available
  %   options, see below. 
  %
  %   HDSOPTION('default') sets all options back to their
  %   default values.
  %
  %   Options:
  %
  %   'metaMode'      : Meta data retrieval mode.
  %   'dataMode'      : Data retrieval mode.
  %   'decimation'    : Vector with decimation values. 
  %   'loadLimit'     : Threshold limiting the size of loaded data.
  %   'maxNCFileSize' : Sets the maximum data file size in bytes.
  %   
  %   
  %   -- metaMode --
  %
  %   MetaMode 0 (default)
  %
  %     When an object is loaded from disk by indexing a property in a parent object, the HDS
  %     Toolbox will load all objects in the associated MAT-file and disregard any objects that are
  %     not requested by the user. 
  %
  %     This option usually results in faster retrieval when all or most objects in a property of an
  %     HDS-object are loaded simultaneously. If you want to get specific objects from disk, this
  %     might be a little slower and you can choose to switch to 'metaMode 2'.
  %     
  %   MetaMode 1
  %   
  %     When an object is loaded from disk, the specific variable containing the object is loaded 
  %     from disk. This is usually slower than 'metaMode 1' but can be faster in case you load
  %     single objects from a MAT-file with large number of variables. (This is also different 
  %     depending on Windows/Mac)
  %     
  %   -- dataMode --
  %
  %   DataMode 1 (default):
  %
  %   	In this mode, each time a dataproperty is accessed, the
  %   	retrieved data is stored in the object and consecutive
  %   	requests for the data are retrieved from memory. This
  %   	works well as long as the retrieved data 
  %
  %   DataMode 2:
  %       
  %       In this mode, each time the dataproperty is accessed,
  %       the data is loaded from disk and not stored in the
  %       object. Data can automatically be decimated by setting
  %       the 'decimation' option with the HDSOPTIONS method. In
  %       this mode, data is read-only. This mode is mostly
  %       usefull if the data property contains massive amounts
  %       of data and you are interested in the complete data set
  %       or a decimated version.
  %   	
  %   -- loadLimit --
  %
  %   This option is only used when 'dataMode' == 1. When a subset of
  %   data is requested from a 'data'-property, the HDS- toolbox will
  %   load the complete dataset into the object if the total number of
  %   points in the dataset does not exceed the 'loadLimit'.
  %
  %   If the dataset contains more points, only the requested subset is
  %   loaded into memory. Subsequent data requests will check what subset
  %   is in memory and retrieve additional points if necessary.
  %
  %   -- decimation -- (Not implemented yet)
  %   
  %   This option is only used when 'dataMode' == 2. The decimation
  %   option is either a single value or a vector of decimation values.
  %   When data is requested from a 'data'-property and the decimation
  %   factor is set to ~= 1, decimated data is returned by the HDS-
  %   toolbox. If the option is a single value, the largest dimension
  %   will be decimated. If the option is a vector, it can set decimation
  %   in multiple dimensions. 
  %
  %   No smoothing or filtering is applied for the decimation such that:
  %   x(1:2500) with the decimation option set to 25 returns the same
  %   data as x(1:25:2500) without decimation.
  %
  
  % Copyright (c) 2012, J.B.Wagenaar
  % This source file is subject to version 3 of the GPL license, 
  % that is bundled with this package in the file LICENSE, and is 
  % available online at http://www.gnu.org/licenses/gpl.txt
  %
  % This source file can be linked to GPL-incompatible facilities, 
  % produced or made available by MathWorks, Inc.
  
  persistent options

  try
    if isempty(options)
      options = struct('decimation',1, 'metaMode',0, 'dataMode',1, 'maxNCFileSize',1e9,'loadLimit',1e5);
      mlock
    end

    if nargin
      if strcmp(varargin{1},'default')
        assert(length(varargin) ==1, ...
          'HDS:HDSOPTION','HDSOPTION  Setting HDSOPTION to ''default'' values requires only one input.');
        options = struct('decimation',1, 'metaMode',0, 'dataMode',1, 'maxNCFileSize',1e9,'loadLimit',1e5);
      end
    else
      out = options;
      return
    end

    ix = 1;
    while ix < nargin
      if nargin >= (ix + 1)
        switch varargin{ix}
          case 'decimation'
            assert(isnumeric(varargin{ix+1}) && isvector(varargin{ix+1}), ...
              'HDSOPTION: Incorrect value for ''decmation'' option.');
            options.decimation = varargin{ix+1};
            ix = ix+2;
          case 'metaMode'
            assert(varargin{ix+1} ==0 || varargin{ix+1}==1, ...
              'HDSOPTION: Incorrect value for ''metaMode'' option.');
            options.metaMode = varargin{ix+1};
            ix = ix+2;  
          case 'dataMode'
            assert(varargin{ix+1} ==1 || varargin{ix+1}==2, ...
              'HDSOPTION: Incorrect value for ''dataMode'' option.');
            options.dataMode = varargin{ix+1};
            ix = ix+2;
          case 'maxNCFileSize'
            assert(isnumeric(varargin{ix+1}) && length(varargin{ix+1})==1, ...
              'HDSOPTION: Incorrect value for ''maxNCFileSize'' option.');
            options.maxNCFileSize = varargin{ix+1};
            ix = ix+2;                  
          case 'loadLimit'
            assert(isnumeric(varargin{ix+1}) && length(varargin{ix+1})==1, ...
              'HDSOPTION: Incorrect value for ''loadLimit'' option.');
            options.loadLimit = varargin{ix+1};
            ix = ix+2;

          case 'default'
            error('HDS:HDSOPTION',['HDSOPTION  Setting HDSOPTION to ''default'' '...
              'values requires only one input.']);
          otherwise
            error('HDS:HDSOPTION','HDSOPTION: Incorrect option.');
        end
      end
    end

    out = options;
    
  catch ME
    throwAsCaller(ME)
  end

end
