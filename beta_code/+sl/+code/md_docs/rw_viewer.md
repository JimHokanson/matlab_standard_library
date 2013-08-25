## Read-Write Viewer ##

The goal of this class is to assist with displaying read/write information about a variable.

## Rough Outline ##
1. Specify the read/write assignment to look for in 'e_text_to_find'
- Upon pressing update, the results should be displayed in lb_results where each line is the text for a read or a write
- On selecting a line in the listbox, the line should be shown in context in e_raw
- The pop-up-menu should toggle between reads, writes, and both