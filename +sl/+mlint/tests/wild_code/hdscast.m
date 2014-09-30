function obj = hdscast(oldobjs, targetobjs, varargin)
    %HDSCAST  Casts a structure or object as an object of specified class.
    %
    %   HDSCAST(DATA, 'class') Casts the array of objects or structs in
    %   DATA as an array of equal size of the specified HDS-class. Propertu
    %   values in DATA will be copied to the properties with the same
    %   property names in the HDS objects. If the property names in DATA
    %   do not match the property names in the HDS-objects, only the
    %   matching properties will be copied.
    %
    %   HDSCAST(DATA, OBJ) Same behavior as above, except that the method
    %   does not generate new HDS-class objects but populates the provided
    %   objects OBJ. The length of OBJ should be the same as the length of
    %   DATA.
    % 
    %   HDSCAST(... , PROPNAMES) You can specify which properties should be
    %   copied in a cell array of strings with indicating the property
    %   names. Providing PROPNAMES will display a warning when the method
    %   fails to copy the property values. There are two options:
    %
    %       1) PROPNAMES is a vector of names: in this case the method will
    %          only copy the specified properties to the HDS object
    %          properties with the same name.
    %       2) PROPNAMES is an 2xN array with property names where the
    %          first row indicates the property names in DATA and the
    %          second row indicates the property names in the HDS-objects
    %          where the values should be copied to.
    %
    %   HDSCAST(... , '-incl') The '-incl' parameter is used to include
    %   property values in DATA that could not be copied to the
    %   HDS-objects. When '-incl' is added as an input argument, a
    %   'Transient' property ('orphanProps') will be added to the
    %   HDS-object which contains a structure-array with name/value pairs
    %   of the properties of DATA that could not succesfully be copied.
    %   This property is 'Transient' and will therefore NOT be saved to
    %   disk. If PROPNAMES are supplied as input arguments, this parameter
    %   will be ignored.
    %
    %   HDSCAST(... , '-inclP') Behaves similarly to the previous option
    %   except that the 'orphanProps' property is now added permanently to
    %   the object. When PROPNAMES are supplied as input arguments, this
    %   parameter will be ignored.
    
    % Copyright (c) 2012, J.B.Wagenaar
    % This source file is subject to version 3 of the GPL license, 
    % that is bundled with this package in the file LICENSE, and is 
    % available online at http://www.gnu.org/licenses/gpl.txt
    %
    % This source file can be linked to GPL-incompatible facilities, 
    % produced or made available by MathWorks, Inc.
    
    % Check inputs; find option string
    missingAction = 'noAction';
    propnameidx  = 0;
    if nargin < 2
        throwAsCaller(MException('HDS:hdscast','HDSCAST: Insufficient input arguments.'));
    elseif nargin == 3
        if ischar(varargin{1})
            if strcmp(varargin{1}, '-incl')
                missingAction = 'incl';
            elseif strcmp(varargin{1}, '-inclP')
                missingAction = 'inclP';
                propnameidx = 1;
            else
                throwAsCaller(MException('HDS:hdscast',sprintf('HDSCAST: Incorrect input argument: ''%s''.',varargin{1})));
            end
        elseif iscellstr(varargin{1})
            propnameidx = 1;
        else
            throwAsCaller(MException('HDS:hdscast','HDSCAST: Incorrect input argument; Property names should be a cell array of strings.'));
        end
    elseif nargin == 4
        if ischar(varargin{1}) && iscellstr(varargin{2})
            propnameidx = 2;
            if strcmp(varargin{1}, '-incl')
                missingAction = 'incl';
            elseif strcmp(varargin{1}, '-inclP')
                missingAction = 'inclP';
            else
                throwAsCaller(MException('HDS:hdscast',sprintf('HDSCAST: Incorrect input argument: ''%s''.',varargin{1})));
            end   
        elseif ischar(varargin{2}) && iscellstr(varargin{1})
            propnameidx = 1;
            if strcmp(varargin{2}, '-incl')
                missingAction = 'incl';
            elseif strcmp(varargin{1}, '-inclP')
                missingAction = 'inclP';
            else
                throwAsCaller(MException('HDS:hdscast',sprintf('HDSCAST: Incorrect input argument: ''%s''.',varargin{1})));
            end
        else
            throwAsCaller(MException('HDS:hdscast','HDSCAST: Incorrect input arguments.'));
        end
    end
    
    if ~(isobject(oldobjs) || isstruct(oldobjs))
        throwAsCaller(MException('HDS:hdscast','HDSCAST: First argument to method should be a structure or a Matlab object.'));
    elseif ischar(targetobjs)
        try
			hdspreventreg(true);
            eval(sprintf('tempObj(%i) = %s;',length(oldobjs), targetobjs))
			hdspreventreg(false);
            if ~isa(tempObj,'HDS')
                throwAsCaller(MException('HDS:hdscast','HDSCAST: Second argument to method should be string with the name of a HDS-class or a HDS-class object.'));
            end
        catch ME
            switch ME.identifier
                case 'HDS:init'
                    rethrow(ME);
                otherwise
                    throwAsCaller(MException('HDS:hdscast','HDSCAST: Second argument to method should be string with the name of a HDS-class or a HDS-class object.'));
            end
        end
    elseif isa(targetobjs,'HDS')
        if length(oldobjs) ~= length(targetobjs)
            throwAsCaller(MException('HDS:hdscast','HDSCAST: The length of the OLDOBJ and the TARGETOBJS should be equal.'));
        end
    else
        throwAsCaller(MException('HDS:hdscast','HDSCAST: TARGETOBJS should either be a string indicating a proper HDS-class or belong to the HDS-class.'));
    end

    % Define resulting obj
    if ischar(targetobjs)
        obj = tempObj;
    else
        obj = targetobjs;
    end
    
    % Check if property names are indicated and whether they exist.
    if propnameidx
        if size(varargin{propnameidx},1) == 1
            oProps = varargin{propnameidx};
            nProps = varargin{propnameidx};
        elseif size(varargin{propnameidx},1) == 2
            oProps = varargin{propnameidx}(1,:);
            nProps = varargin{propnameidx}(2,:);
        else
            throwAsCaller(MException('HDS:hdscast','HDSCAST: Input argument specifying property names should have 1 or 2 rows.'));
        end
        
        % Get fieldnames of struct to expose hidden properties.
        warning('OFF','MATLAB:structOnObject');
        realpropsOld = fieldnames(struct(oldobjs));
        existInOld = cellfun(@(x) any(strcmp(x, realpropsOld)), oProps);
        realpropsNew = fieldnames(struct(obj));
        existInNew = cellfun(@(x) any(strcmp(x, realpropsNew)), nProps);
        warning('ON','MATLAB:structOnObject');
        
        if ~all(existInOld)
            throwAsCaller(MException('HDS:hdscast','HDSCAST: Not all properties supplied as input arguments exist in the original object/structure.'));
        elseif ~all(existInNew)
            throwAsCaller(MException('HDS:hdscast','HDSCAST: Not all properties supplied as input arguments exist in the target object/structure.'));
        end
        
        mustMatch = true;
    else
        oProps = fieldnames(oldobjs);
        nProps = oProps;
        mustMatch = false;
    end
    
    % Call the HDS method to set properties as this will bypass the subsref
    % and subsasgn functions. 
    obj = castHDSprops(obj, oldobjs, oProps, nProps, missingAction, mustMatch);
  
end