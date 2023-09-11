function time_out = matlabToMSBase1601(ml_time)

time_since_1601_s = ml_time - 584755;

time_out = uint64(time_since_1601_s*8.64e11);


end