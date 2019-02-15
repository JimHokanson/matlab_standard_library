function t = getExampleTable()
%X Loads an example table to play with
%
%   t = sl.table.getExampleTable()

    load patients
 	t = table(LastName,Gender,Age,Height,Weight,Smoker,Systolic,Diastolic);

end