function [input1,input2,ROT_METHOD,SCALE_METHOD,WINDOW_TYPE,DISP_TEXT,PERF_LEVEL,WINDOW_SCALE] = fm_parse_inputs(data)
% fm_parse_inputs(data)
%
% could do with some error-checking in here maybe

input1 = data.input1;   % send in non zero-padded images means changing this
input2 = data.input2;
%input1_windowed = data.input1_windowed;
%input2_windowed = data.input2_windowed;
ROT_METHOD = data.RotInterp;
SCALE_METHOD = data.SclInterp;
WINDOW_TYPE = data.windowType;
DISP_TEXT = data.dispText;
PERF_LEVEL = data.performanceLevel;
WINDOW_SCALE = data.windowScale;