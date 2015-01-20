function getProcessMemoryUsage(process_name)
%
%
%   sl.os.getMemoryUsage
%
%
%   This should return an object with process information
%   as well as the different memory usages ...

error('Not yet implemented')
%
%

%feature('getpid')
%feature('MemStats')

%NOTE: This could return multiple values ...
wtf = System.Diagnostics.Process.GetProcessesByName(process_name);


%             Length: 1
%         LongLength: 1
%               Rank: 1
%           SyncRoot: [1x1 System.Diagnostics.Process[]]
%         IsReadOnly: 0
%        IsFixedSize: 1
%     IsSynchronized: 0

e = wtf.GetEnumerator;

e.MoveNext;

wtf2 = e.Current();

