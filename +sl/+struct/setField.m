function setField
%
%   Code relies on mex, compile with:
%   mex setField.c
%
%   Examples
%   ---------
%   s = struct;
%   wtf = sl.struct.setField(s,'wtf batman',5);
%
%   %Note, access can be done with:
%   wtf.('wtf batman')
%
%   %Override test
%   wtf = sl.struct.setField(wtf,'wtf batman',1);
%
%   %More testing
%   wtf.test = 3;
%   wtf.nope = 4;
%   wtf = sl.struct.setField(wtf,'nope','cheese');
%   wtf = sl.struct.setField(wtf,'! !','wow');
%   wtf = sl.struct.setField(wtf,'test',struct());
%
%   wtf = 
%   struct with fields:
% 
%     wtf batman: 1
%           test: [1×1 struct]
%           nope: 'cheese'
%            ! !: 'wow'

error('Mex function setField.c not compiled')