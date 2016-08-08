function fh = getConversionFunction(source_unit,output_unit)
%
%
%   fh = sci.units.getConversionFunction(source_unit,output_unit)
%
%   Inputs:
%   -------
%   source_unit : string
%   output_unit : string 
%
%
%Eventually I want to expand all of this but for now we'll hardcode what we
%need

%IMPORTANT:
%----------
%Right now I am going with case sensitivity.

%http://www.mathworks.com/matlabcentral/fileexchange/9873-simple-units-and-dimensions-for-matlab
%http://www.mathworks.com/matlabcentral/fileexchange/35258-unit-converters

if strcmp(source_unit,output_unit)
    fh = @(x)(x);
    return
end

combined_units = sprintf('%s#%s',source_unit,output_unit);

switch combined_units
    case 'V#uV'
        fh = @(x)times(x,1e6);
    case 'V#mV'
        fh = @(x)times(x,1e3);
    case {'cmH20#cm H20','cm H20#cm H2O'};
        %Yikes, why aren't we using the letter O instead of the # 0 ...
        fh = @(x)x;
% % %     case 's#ms'
% % %     case 's#min'
% % %     case 's#hr
    otherwise
        error('Unsupported case: From "%s" to "%s"',source_unit,output_unit)
end

end