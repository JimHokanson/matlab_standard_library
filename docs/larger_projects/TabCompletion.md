## Tab Completion ##

Tab completion is a wonderful thing, but it doesn't always work the way we want it to. Yair documents a way of modifying the way Matlab provides Tab Completion. In addition to specifying how to modify the file, he provides a link on the FEX which allows for comand line modifications of this file.

- http://undocumentedmatlab.com/blog/setting-desktop-tab-completions/
- http://www.mathworks.com/matlabcentral/fileexchange/26830-tabcomplete


## Improvements ##

The following are some thoughts on what I wanted to change from Yair's implementation. 

First, I wanted to have more specific tab completion. For example, when looking to edit a class, I would like a function editc, which specifically provides tab completion for classes, instead of classes, functions, and properties. 

Second, I wanted to remove the manipulation of the file from the command line to a set of instructions in the repository which would be processed. In this way, one could run a function like updateTabCompletion, and as the function name suggests, the tab completion rules would be updated. This seems preferable to having a single place, presumably a startup script, that documents all tab completion modifications.

Third, Yair's FEX code does not fully expose the options available for tab completion. Either one could fully implement every option in some function, that goes from a set of instructions to the xml code used in the file, or alternatively, let the user write their own xml. Writing this directly in the tab completion instructions file is obviously not desirable, as this is specific to a user's computer, but a copy/paste or "macro" insertion mechanism should be feasible.

## Status ##
 
One of the commentors on Yair's website mentions that tab completion of packages is not possible. This has significantly reduced my interest in the project. Yair does describe a way of stealing the bindings so as to offer custom key responses, but that seems like a TON of work. Perhaps one day Matlab will fix the package problem and also allow callbacks on the tab completion as one of the options.
