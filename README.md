# Jim's Standard Matlab Library #

This repository was created in order to supplement other projects that I was working on. 

When I began work different repositories, I found myself copying specific functions that I needed from other repositories. When I would make a change or update to the function it was difficult to propagate. 

IMHO Matlab has a terrible habit of encouraging cheap functions that live in the global namespace. They are cheap in the sense that many different versions might exist in public for doing nearly the same thing. One of the goals of the standard library is to try and provide organized code that does things well. When possible it is desirable to add functionality (read options) to a function instead of creating a new one with a slight difference.

## Status ##
This library will probably always be a work in progress.

## Usage ##

Most of the functions are prefixed with the package 'sl'.

For example, one  class I use a lot is called handle_light. This class was copied from some online exchange and it basically attempts to hide methods of the handle class, cleaning up things like tab completion and the default methods display.

This class can be accessed using:

	sl.obj.handle_light

A typical usage example would be:

	classdef my_class < sl.obj.handle_light


## Design Decisions ##
1. I was originally going to call the top level package jsl (Jim's Standard Library as opposed to Standard Library). This however would have been a little too 'me' focused. It also would have added an extra character
2. I currently only plan on having a depth of two packages. My plan is to have further organization occur via web documentation ...
3. I try to reduce function outputs and instead return objects if further analysis or interpretation may be needed.
4. I tend to prefer parsing of optional inputs using:

	`sl.in.processVarargin`
	
	See the definition of the function on how to use it.

5. Where possible functions should be named with the parent in mind:

	`sl.cellstr.join`

	In this case join doesn't make much sense without cellstr. As of this writing Matlab has poor package importing capabilities (specifically for classes) and with short top level package names it is expected that in general it will be preferable to type the full name of the package rather than importing and running the function without the package name. 

## Benefits ##

1. A less polluted global namespace
2. Some help with tab completion due to subclass organization
3. Reduction in code redundancy


## What's not covered? ##
This is not meant to cover larger/topic specific projects.