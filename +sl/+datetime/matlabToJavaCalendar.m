function java_cal = matlabToJavaCalendar(matlab_time)
%
%   java_cal = sl.datetime.matlabToJavaCalendar(matlab_time)
%
%   Output
%   -------
%   java_cal: [java.util.GregorianCalendar]
%       

%{
    c1 = sl.datetime.matlabToJavaCalendar(now);
    c2 = sl.datetime.matlabToJavaCalendar(now-100);

    tz1 = c1.getTimeZone; %Note t2 would be the same

    in1 = tz1.inDaylightTime(c1.getTime);
    in2 = tz1.inDaylightTime(c2.getTime);

    if (in1 == in2)
        %do nothing
    elseif in1
        %c1 EDT, c2 is EST
        %Subtract 1 hour to c2
    else
        %c1 EST, c2 EDT
        %Add 1 hour to c2
    end

    java_cal = sl.datetime.matlabToJavaCalendar(now);
    tz = java_cal.getTimeZone;
    d = java_cal.getTime()
    tz2 = java.util.TimeZone.getTimeZone('EDT');
    d_long = d.getTime;
    disp(tz2.getOffset(d_long))
    disp(tz.inDaylightTime(d))

    tz.inDaylightTime(java_cal.getTime())
%}

[Y,MO,D,H,MI,S] = datevec(matlab_time); 
%https://docs.oracle.com/javase/7/docs/api/java/util/Calendar.html

temp = cell(1,length(Y));
for i = 1:length(Y)
    java_cal = java.util.Calendar.getInstance();
    %https://docs.oracle.com/javase/7/docs/api/java/util/Calendar.html#set(int,%20int,%20int,%20int,%20int,%20int)
    %Month is 0 based
    java_cal.set(Y(i), MO(i)-1, D(i), H(i), MI(i), S(i));
    temp{i} = java_cal;
end

java_cal = [temp{:}];

%TimeZone.getTimeZone("EDT").getOffset(date.getTime());

%java_cal.get(java_cal.YEAR)

%inDaylightTime

end