File and folder listing with sl.dir.getList
===========================================

If ever there was a function that should actually be part of a standard library, it should probably be a function which supports listing of files and folders in subdirectories of a given folder path. The function dir() serves to list files and folders in a single directory, but not in the subdirectories. The numerous examples of this on the file exchange seem to agree but they've always had a few problems.

These are a list of functions I found on the file exchange to accomplish my task. Some may have a feature here or there that is not in my code, but overall I think mine is the most well rounded and has the best overall performance.

The List:
---------

- The # on the left indicates the # of downloads in the last 30 days when I was looking (around mid-February 2015).
- Values are ordered by their FEX #
- List may not be exhaustive


49 http://www.mathworks.com/matlabcentral/fileexchange/1492-subdir--new-
6 http://www.mathworks.com/matlabcentral/fileexchange/1570-dirdir
13 http://www.mathworks.com/matlabcentral/fileexchange/2118-getfilenames-m
33 http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr--find-files-recursively-filtering-name--date-or-bytes-
22 http://www.mathworks.com/matlabcentral/fileexchange/15505-recursive-dir
75 http://www.mathworks.com/matlabcentral/fileexchange/15859-subdir--a-recursive-file-search
5 http://www.mathworks.com/matlabcentral/fileexchange/16216-regexpdir
4 http://www.mathworks.com/matlabcentral/fileexchange/16217-wildcardsearch
131 http://www.mathworks.com/matlabcentral/fileexchange/19550-recursive-directory-listing
13 http://www.mathworks.com/matlabcentral/fileexchange/21791-search-files-recursively--dir2-
7 http://www.mathworks.com/matlabcentral/fileexchange/22829-file-list
5 http://www.mathworks.com/matlabcentral/fileexchange/24567-searchfile
5 http://www.mathworks.com/matlabcentral/fileexchange/25753-new-dir-m
16 http://www.mathworks.com/matlabcentral/fileexchange/31343-enlist-all-file-names-in-a-folder-and-it-s-subfolders
26 http://www.mathworks.com/matlabcentral/fileexchange/32036-dirwalk-walk-the-directory-tree
91 http://www.mathworks.com/matlabcentral/fileexchange/32226-recursive-directory-listing-enhanced-rdir
5 http://www.mathworks.com/matlabcentral/fileexchange/39804-creating-file-and-folder-trees
17 http://www.mathworks.com/matlabcentral/fileexchange/40016-recursive-directory-searching-for-multiple-file-specs
9 http://www.mathworks.com/matlabcentral/fileexchange/40020-dir-read
30 http://www.mathworks.com/matlabcentral/fileexchange/40149-expand-wildcards-for-files-and-directory-names
15 http://www.mathworks.com/matlabcentral/fileexchange/41135-folders-sub-folders
7 http://www.mathworks.com/matlabcentral/fileexchange/43704-getdirectorycontents
5 http://www.mathworks.com/matlabcentral/fileexchange/44089-rdir-dos
3 http://www.mathworks.com/matlabcentral/fileexchange/46873-dir-crawler-m

Goals:
------

I wanted a function that was:
- fast
- flexible
- easy to call
- easily expandable
- returned values that were ready to use - i.e. full file paths

I think the function that I wrote finally starts to approach those goals. I'm leaving out some mex code that I have access to, since mex code always gets me nervous. I've included some calls to the .NET framework which can significantly speed up the results.

How to go faster:
-----------------

The following are some thoughts on how to make these types of functions go faster.

- Build filtering into the listing mechanism, not after the fact.
- Get only what is needed. Creating the structure returned by dir() can be expensive (relatively speaking) to create compared to just getting a name.
- Implement system specific searching. The .NET code is a step in this direction. I would hope that the .NET code can take advantage of Windows file/directory indexing. I'd eventually like to get something similar for Macs.