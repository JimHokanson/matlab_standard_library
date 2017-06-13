function mergemex(varargin)
% MATLAB mex function mergemex.m
% Calling syntax:
% >> C = mergemex(A,B)
%
% Purpose: merge two sorted numerical arrays into one.
%
% INPUTS
% - The input arrays A and B must be ascending sorted
% - They must be vectors and same class
% OUTPUT
%   C contains all elements of A and B, ascending sorted
%   C is the same class and have the length of length(A)+length(B).
%
% >> [C idx] = mergemex(A,B)
% returns idx such that C(idx>0) is equal to A and
%                       C(idx<0) is equal to B
%
% Compile on 32-bit platform
%  >> mex -O -v mergemex.c
% On 64-bit platform
%  >> mex -v -O -largeArrayDims mergemex.c
%
% Author Bruno Luong <brunoluong@?????.com>
% Date: 03-Oct-2010

fprintf('MEX file mergemex not yet compiled\nAction:\n');
fprintf('\t mergesa_install\n');