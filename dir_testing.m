function dir_testing(examine_output)

tic
for i = 1:5
    file_paths = run1();
end
toc
tic
for i = 1:5
    output     = run2();
end
toc

% % % %     tic
% % % %     output3    = run3();
% % % %     toc
% % % %
% % % % %     d1 = setdiff(file_paths,output);
% % % % %     d2 = setdiff(output,file_paths);
% % % %     output4 = sl.path.toCellstr(output3);
if nargin && examine_output
    keyboard
end

end

function file_paths = run1()
obj = sl.dir.searcher.folder_default;
opt = obj.filter_options;
opt.first_chars_ignore = '.+@';
opt.dirs_ignore        = {'private'};
file_paths = obj.searchDirectories(cd);
end

function output = run2()
output = getDirectoryTree(cd);
end

function output3 = run3()
output3 = genpath(cd);
end