function varargout = resample(objs,new_fs_or_new_fs_objs,varargin)
%x Change the sampling frequency of the data
%
%   Calling Forms:
%   --------------
%   new_objs = resample(objs,new_fs,varargin)
%
%   new_objs = resample(objs,objs_with_fs_to_match,varargin)
%
%   Inputs:
%   -------
%   objs : sci.time_series.data
%   new_fs :
%       The new sampling frequency
%   objs_with_fs_to_match : sci.time_series.data
%       Either 1 object or multiple objects may be passed in.
%       When 1 object is passed in, the fs of that object is
%       used for all of the input 'objs'. If multiple values
%       are passed in then it must be the same length as 'objs'
%       and each fs from this input is assigned to each element
%       in 'objs'
%
%   Optional Inputs:
%   ----------------
%   data_lengths_to_match : sci.time_series.data
%       Pass this in when you want to ensure that the # of samples
%       matches some other object.
%
%   Improvements:
%   -------------
%   1) Expose more options in the underlying resample() implementation
%
%   Examples:
%   ---------
%   1) Resample pressure data at 100 Hz
%   pres_data.resample(100)
%   pelvic_eng = pelvic_eng.resample(pres_data,'data_lengths_to_match',pres_data);
%
%   See Also:
%   resample %signal processing toolbox

in.data_lengths_to_match = [];
in = sl.in.processVarargin(in,varargin);

if nargout
    temp = copy(objs);
else
    temp = objs;
end

%Determination of the new sampling frequency
n_objs = length(objs);
if isobject(new_fs_or_new_fs_objs)
    new_fs_objs = new_fs_or_new_fs_objs;
    if n_objs == 1
        new_fs_all = new_fs_objs.time.fs;
    elseif length(new_fs_objs) == 1
        new_fs_all = zeros(1,n_objs);
        new_fs_all(:) = new_fs_objs.time.fs;
        
    else
        time_objs = [new_fs_objs.time];
        new_fs_all = [time_objs.fs];
    end
else
    if n_objs == 1
        new_fs_all = new_fs_or_new_fs_objs;
    elseif length(new_fs_or_new_fs_objs) == 1
        new_fs_all = zeros(1,n_objs);
        new_fs_all(:) = new_fs_or_new_fs_objs;
    else
        new_fs_all = new_fs_or_new_fs_objs;
    end
end

%Run resampling  ---------------------------------------------
for iObj = 1:n_objs
    cur_obj  = temp(iObj);
    new_fs = new_fs_all(iObj);
    old_fs = cur_obj.time.fs;
    if new_fs == old_fs
        %do nothing
    elseif new_fs > old_fs
        P = new_fs/old_fs;
        if abs(P - round(P)) > eps
            error(['Only integer upsampling currently supported' ...
                ', trying to go from %g to %g results in an' ...
                ' upsample rate of %g'],old_fs,new_fs,P)
            
            %NOTE: If we get P = 5.5, then we could essentially do
            %
            %   P = 11 and Q = 2
            %
            %Driving P high however seems like it could be
            %dangerous in terms of memory usage
            %
            %   We could just set an arbitrary memory usage
            %   that we wouldn't exceed. Or alternatively, never
            %   allow a small P/Q ratio but a high P
        end
        
        Q = 1;
    else
        Q = old_fs/new_fs;
        if abs(Q - round(Q)) > eps
            error(['Only integer downsampling currently supported' ...
                ', trying to go from %g to %g results in an' ...
                ' downsample rate of %g'],old_fs,new_fs,Q)
        end
        P = 1;
    end
    
    %TODO: I want to rewrite this resample to be nicer
    
    %Main call to the resample() function of the signal
    %processing toolbox
    cur_obj.d = resample(cur_obj.d,P,Q);
    cur_obj.time.dt = 1/new_fs;
    cur_obj.time.n_samples = cur_obj.n_samples;
end

%Adjust data lengths so that we have the same length data
%---------------------------------------------------------------
if ~isempty(in.data_lengths_to_match)
   %Let's currently assume a 1 to 1 ratio
   d2 = in.data_lengths_to_match;
   if length(d2) ~= length(temp)
       error('Lengths must match')
   end
   for iObj = 1:length(temp)
      cur_obj = temp(iObj);
      cur_ref = d2(iObj);
      n_samples_temp = cur_obj.n_samples;
      n_samples_ref  = cur_ref.n_samples;
      %
      %Approaches:
      %- shorten ref  - maybe, would rather not
      %- shorten obj  - easy
      %- lengthen ref - NO
      %- lengthen obj - how?
      if n_samples_temp == n_samples_ref
          %Great!
      elseif n_samples_temp > n_samples_ref
          %shorten
          cur_obj.d(n_samples_ref+1:end,:,:) = [];
          %Adjust time
          %perhaps eventually place a listener on this ...
          cur_obj.time.n_samples = n_samples_ref;
      else
          %lengthen cur_obj OR shorten ref
          %
          % - perhaps lengthen if relatively little difference
          %otherwise consider shortening the ref
      end
   end
end



if nargout
    varargout{1} = temp;
end
end