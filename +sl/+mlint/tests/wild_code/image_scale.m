function output = image_scale(input,lower,upper)
% USAGE : output = image_scale(input,lower,upper)
%
% input = image to be scaled
% lower,upper = new limits to impose on image
% output = newly-scaled image
%
% Adam Wilmer, 25-4-02

iu = max(max(input)); il = min(min(input));
output = ((upper-lower)*((input-il)/(iu-il)))+lower;