## Explain Error ##

The goal of this project is to help explain errors. The idea is that often times in a programming language the concern is simply with letting the user know that an error occurred, not with necessarily explaining in a coherent way how to fix the error, as that takes considerably more work. However for a programmer, especially a novice to the language, I think this type of functionality could significantly improve the programming experience.

The envisioned usage is as follows:

````Matlab
obj.applied_stimulus_matcher.getStimulusMatches();
'Attempt to reference field of non-structure array.'

explain()
````

This is a relatively easy example to parse, since we are only doing 'dot' referencing twice. Running the explain command could do one of two general things.

## Explain: Part 1, verbose explanation ##

Part 1 of the solution is to provide a verbose explanation of the problem. For example, one could show something like the following text:

````Matlab
%Referencing a field typically involves the following notation:
s.my_field 
%where we are getting the value stored in the field "my_field" from the structure or object "s"
%
%If s is not a structure, then you get the error shown, for example:
s = [];
s.my_field; %This doesn't make any sense, as is "s" is not an object or structure.

s = 2;
s.my_field; %Again, this doesn't make sense

````

## Explain: Part 2, help with the error ##

This section would try to assist with the specifics of the current error, consider the previous case:
````Matlab
obj.applied_stimulus_matcher.getStimulusMatches();
'Attempt to reference field of non-structure array.'
````

In this case, the code could traverse the object hierarchy, showing that applied_stimulus_matcher is not an object or structure. It is also possible that obj is not an object or structure, and the code would need to determine this. By convention however, obj tends to refer to an object instance. For "bonus points", the code could refer a tool which I've been meaning to develop which looks for object initialization, to see where 'applied_stimulus_matcher' should be getting defined, for further debugging.

## Updating ##

The code itself would likely always be a work in progress, but having a framework for logging errors and adding notes and examples would be helpful. 

## Layout ##

I was thinking about having part 1 being displayed first, at least in a very terse format, followed by part 2, with possibly a link to a more extended version of part 1. The final code might look like:

````
explain()

Part 1:
You are doing something like this:
a = [];
a.my_property
Which doesn't make sense since 'a' is not a property or object

Part 2:
Code analysis thinks that the code is failing because:
'applied_stimulus_matcher' is not an object or structure

Since obj is most likely an object, you can use the following command:
enumerateObjectAssignments('applied_stim_manager') %Notice, Matlab should know the class name
%also, this could be a link
to see where 'applied_stimulus_matcher' is initialized
````

## Code analysis ##
Part of this would rely on code analysis. I've starting working on documenting the mlint functionality of Matlab (TODO: Insert link). Also, one would need to rely on lasterror:

````Matlab
le = lasterror;

le => 
       message: 'Attempt to reference field of non-structure array.'
    identifier: 'MATLAB:nonStrucReference'
         stack: [0x1 struct]
````

## Other Code Tie In ##

From this it is also might be obvious that there is some need to provide hooks, most likely based on the identifier, for allowing non-Matlab code to also take advantage of this infrastructure.
