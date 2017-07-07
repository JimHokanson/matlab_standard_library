function r = findLocalPeaks(data,search_type)
%x  Finds points that are local maxima, minima, or both
%
%   result = sl.array.findLocalPeaks(data, search_type, varargin)
%
%       x       x
%     x   x x x   x   x
%   x               x   x
%       o       o     o     <= points identified as local maxima
%
%   Inputs
%   ------
%   data :
%   search_type :
%       - 'max'
%       - 'min'
%       - 'both'
%
%
%   Optional Inputs
%   ---------------
%   edges_can_be_peaks : default false
%   max_threshold : default []
%       Not used by default. 
%   min_threshold : default []
%   threshold : default []
%       This currently behaves as a global 
%   n_peaks_guess : default 20
%
%   Outputs
%   -------
%   result : sl.array.results.local_peaks 
%
%   Examples
%   --------
%
%       TODO!
%
%   Improvements
%   ------------
%   1) Support adding a sample # restriction that allows only
%   finding points that are bigger than all neighbors within a certain
%   region. The current algorithm only looks at direct neighbors.
%   2) Allow for a 2-element threshold for 'both' where the 1st element
%   applies to the max and the 2nd to the min
%
%   Test Code
%   ---------
%   Test code is located at the end of this file ...
%
%   See Also
%   --------
%   sl.array.results.local_peaks

in.indices_only = false;
in.edges_can_be_peaks = false;
in.max_threshold = [];
in.min_threshold = [];
in.threshold = [];
in.n_peaks_guess = 20;
in = sl.in.processVarargin(in,varargin);

%---------------------------------------

%Input handling
%--------------------
if in.n_peaks_guess < 1
    in.n_peaks_guess = 10;
end

r = sl.array.results.local_peaks;

switch search_type
    case 'max'
        r = h__findMaxima(data,r,true,in);
    case 'min'
        r = h__findMaxima(data,r,false,in);
    case 'both'
        r = h__findMaxima(data,r,search_type,in);
        r = h__findMaxima(data,r,search_type,in);
        merged_indices = sl.array.mergesort(r.min_indices,r.max_indices);
        r.indices = merged_indices;
        r.values = data(merged_indices);
    otherwise
        error('unrecognized type input')
end

if in.indices_only
    r = r.indices;
end

%---------------------------------------

end

function r = h__findMaxima(data,r,is_max,in)

if is_max
    if isempty(in.threshold) && isempty(in.max_threshold)
        threshold = NaN;
    elseif isempty(in.threshold)
        threshold = in.max_threshold;
    else
        threshold = in.threshold;
    end
    peak_indices = h__findLocalMaxima(data,threshold,in);
    r.indices = peak_indices;
    r.values = data(peak_indices);
    r.max_indices = peak_indices;
    r.max_values = r.values;
else
  	if isempty(in.threshold) && isempty(in.min_threshold)
        threshold = NaN;
    elseif isempty(in.threshold)
        threshold = in.min_threshold;
    else
        threshold = in.threshold;
    end
    %TODO: Avoid the negation for large data sets - need to duplicate
    %the logic :/
 	peak_indices = h__findLocalMaxima(-data,threshold,in);
    r.indices = peak_indices;
    r.values = data(peak_indices);
    r.min_indices = peak_indices;
    r.min_values = r.values;
end

end

function peak_indices = h__findLocalMaxima(d, threshold, in)

% in.edges_can_be_peaks = false;
% in.n_peaks_guess = 20;


cur_output_I = 0;
peak_indices = zeros(1,in.n_peaks_guess);

cur_input_I = 2;
current_value = d(1);
next_value = d(2);
if in.edges_can_be_peaks
    if d(1) > d(2)
        peak_indices(1) = 1;
        cur_output_I = 1;
    elseif d(1) == d(2)
       [next_value,peak_indices,cur_output_I,cur_input_I] = ...
        h__seekRight(d,current_value,1,peak_indices,cur_output_I);
    end
end

stop_point = length(d)-1;
while cur_input_I < stop_point
    
    last_value = current_value;
    current_value = next_value;
    next_value = d(cur_input_I+1);
    
    if current_value > last_value
        if current_value < next_value
            %Simple case, not greater than the next value
            %----------------------------------------------
            %- next value is possible
            cur_input_I = cur_input_I + 1;
        elseif current_value > next_value
            %Simple case, greater than left and right
            %----------------------------------------
            cur_output_I = cur_output_I + 1;
            if cur_output_I > length(peak_indices)
                %Doubling of size
                peak_indices = [peak_indices zeros(1,cur_output_I)]; %#ok<AGROW>
            end
            peak_indices(cur_output_I) = cur_input_I;
            cur_input_I = cur_input_I + 2;
        else
            %Complex, greater than previous, same as next
            %---------------------------------------------
            % - precede to the right to determine if max or not
            % - least likely outcome, thus last
            [next_value,peak_indices,cur_output_I,cur_input_I] = ...
             h__seekRight(d,current_value,cur_input_I,peak_indices,cur_output_I);

        end
    else
        %not greater than the previous value, move to the next value
        cur_input_I = cur_input_I + 1;
    end
end

%Edge handling
%-----------------------------------------------
if in.edges_can_be_peaks   
   %End point
   %---------
   if d(end) > d(end-1)
       cur_output_I = cur_output_I + 1;
       if cur_output_I > length(peak_indices)
          peak_indices(end+1) = length(d); 
       else
           peak_indices(cur_output_I) = length(d);
       end
   end
end

%Trimming
%--------------------------------------
peak_indices(cur_output_I+1:end) = [];
if ~isnan(threshold)
   peak_indices(d(peak_indices) < threshold) = [];
end


end

function [next_value,peak_indices,cur_output_I,next_input_I] = ...
    h__seekRight(d,cur_value,cur_input_I,peak_indices,cur_output_I)
%
%
%   Inputs
%   ------
%   cur_value
%   cur_input_I
%   peak_indices
%   cur_output_I
%
%
%   We keep going to the right until we run out data or until a point
%   is not the same as the current value. If the value is larger, then our 
%   current value is not a peak. If the value is smaller, than our current
%   value is a peak. This is illustrated in the code below.
%
%   TODO: Document inputs and outputs


%Find the next point which is not equal to the current value
%---------------------------------------------------------------
next_test_index = cur_input_I + 2;
while (next_test_index <= length(d) && cur_value == d(next_test_index))
    next_test_index = next_test_index + 1;
end

%Process stop reason
%----------------------------
is_local_max = true;
if next_test_index > length(d) 
    %Ran out of data, so our point is a local max
    %--------------------------------------------
    next_value = NaN;
    next_input_I = next_test_index;
elseif cur_value > d(next_test_index)
    %Eventually our point went down, so we have a local max
    %
    %          o . . . . .
    %  . . . .             x . . . .
    %   o - point we are curious about
    %   x - point we stopped at, so 'o' is a local peak
    
    next_value = d(next_test_index);
    %current_value = d(stop_index-1); %which is the current value
    next_input_I = next_test_index + 1;
else
    %not a local max, since we decreased relative to the next peak
    %
    %                      x . . . .
    %          o . . . . .
    %  . . . .  
    %   o - point we are curious about
    %   x - point we stopped at, so 'o' is not a local peak
    
    is_local_max = false;
    next_value = d(next_test_index);
    next_input_I = next_test_index;
end 

if is_local_max
    cur_output_I = cur_output_I + 1;
    if cur_output_I > length(peak_indices)
        %Doubling of size
         peak_indices = [peak_indices zeros(1,cur_output_I)];
    end
    peak_indices(cur_output_I) = cur_input_I; 
end
 

end

function h__tests()
profile on
tic
N = 1e8;
fh = @sl.array.findLocalPeaks;
d = zeros(1,N);
d(N) = 1;

%Edge testing
%---------------------------------------------------------
%Ignoring edge peaks
r = fh(d,'max','indices_only',true);
assert(isempty(r),'Expected no results')

%Not ignoring edge peaks
r = fh(d,'max','edges_can_be_peaks',true,'indices_only',true);
assert(isequal(r,N),'Last point should be a peak')

%First edge
d(1) = 1;
r = fh(d,'max','edges_can_be_peaks',true,'indices_only',true);
assert(isequal(r,[1 N]),'first edge with seeking error');

%Ege Peak requires right seeking
d(2:5) = 1;
r = fh(d,'max','edges_can_be_peaks',true,'indices_only',true);
assert(isequal(r,[1 N]),'first edge with seeking error');

%Main functionality testing
%---------------------------------------------------------
d(:) = 0;
d(2:5:N) = 1;
r = fh(d,'max','indices_only',true);
assert(isequal(r,2:5:N),'mismatch in basic peek finding');

%bumping to the right, peaks should still be the first points
d(3:5:N) = 1;
r = fh(d,'max','indices_only',true);
assert(isequal(r,2:5:N),'mismatch in basic peek finding');

%Threshold testing
%TODO


%test run at the end
d(:) = 0;
d(N-10:N) = 1;
r = fh(d,'max');
assert(isequal(r,N-10),'peak at end matches')
toc
profile off
profile viewer

end