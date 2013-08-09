## Overview ##

This document is meant to provide a general overview of some of the thoughts that went or that are going into my design of this repository. It seems to me that most seasoned Matlab coders tend to create a personal library of functions that they use when writing code. The alternative is to write everything from scratch or to copy and paste code when switching from one project to another. Although this sounds silly, I think most people do this more often than they realize.

Consider the following task, which was the first example that popped into my head. The task is to get a list of folders in a directory and to return that list as a set of absolute paths. The code might look as such:

````matlab
base_path = cd;
d = dir(base_path);
d(~[d.isdir]) = [];
file_paths = cellfun(@(x) fullfile(base_path,x),{d.name},'un',0);
````

This works fine although it takes 3 lines of code (skipping the base path initialization) to set it up and it isn't all that clear. In addition, this fails to remove things like hidden files and the dreaded '.' and '..' paths. Most importantly I feel this is a real example of the type of code that someone might continually rewrite instead of moving to a function. The proper (and as yet unwritten) way of doing this to have something like the following.

````matlab
temp = sl.dir.getFoldersInDirectory(base_path);
file_paths = temp.file_paths; %Lazy property evaluation
````

What does this function do, it returns an object that provides information about folders in a directory. Here are some additional possible calls.

````matlab
temp = sl.dir.getFoldersInDirectory(base_path,'include_hidden',true);
folder_names = temp.folder_names; %Return names instead of the full paths

temp = sl.dir.getFoldersInDirectory(base_path,'filters',{'modified', @(x) x > now - 1,'regexp','^asdf'}); %Let's filter on the date and starts with 'asdf'
````

The main point of these examples is that we have created a specific function which I think is much improved over the top example.


## The Matlab way of doing things ##

JAH NOTE: I'm at this point

## When to create a function or not ##


## What belongs in this repository and what doesn't ##

