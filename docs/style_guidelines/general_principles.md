## Overview ##

This document is meant to provide a general overview of some of the thoughts that went or that are going into my design of this repository. It seems to me that most seasoned Matlab coders tend to create a personal library of functions that they use when writing code. The alternative is to write everything from scratch or to copy and paste code when switching from one project to another. Although this sounds silly, I think most people do this more often than they realize.

Consider the following task, which was the first example that popped into my head. The task is to get a list of folders in a directory and to return that list as a set of absolute paths. The code might look as such:

````matlab
base_path = cd;
d = dir(base_path);
d(~[d.isdir]) = [];
file_paths = cellfun(@(x) fullfile(base_path,x),{d.name},'un',0);
````


## The Matlab way of doing things ##


## When to create a function or not ##


## What belongs in this repository and what doesn't ##

