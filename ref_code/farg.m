%FARG	to look up function syntax in an M-file
%
%	FARG parses an M-file for FUNCTION tags
%	and extracts their syntax
%	these functions/calls are collected
%	- M = main function
%	- S = subfunctions
%	- N = nested functions
%	- A = anonymous functions
%	- E = eval class calls
%	- X = unresolved calls
%
%SYNTAX
%-------------------------------------------------------------------------------
%	 E    = FARG
%			returns the current FARG engine structure in E
%	        FARG FNAM  OPT1  ...  OPTx
%	 P    = FARG(FNAM,'OPT1',...,'OPTx')
%	[P,E] = FARG(...);
%
%INPUT
%-------------------------------------------------------------------------------
% FNAM	:	name of an M-file or P-file including a full or partial path
%		- a P-file must have a corresponding M-file or an error is
%		  generated
%
% OPT		description
% ----------------------------------------------------------------
%    -h	:	show file synopsis only
%    -e	:	show eval class calls
%    -w	:	show warnings
%    -l	:	do NOT make LINE entries open the file (see below)
%		- use this option if your output is NOT directed
%		  to the command window, e.g., a html file
%		- a copy/paste from the command window will remove
%		  the lineopen syntax automatically
%    -s	:	do NOT print run-time output
%		- this option is turned off automatically if
%		  the file has fatal syntax errors
%    -d	:	save lex parser engine
%
%OUTPUT
%-------------------------------------------------------------------------------
% E	:	FARG engine parameters
% P	:	runtime output saved in a character string in this format
%
%	MLINT error-free function:
%
%				T	= type of function/call
%				    C	= McCabe/cyclomatic complexity
%
%	function#   |   line#:	T   C	syntax
%	--------------------------------|--|--|--|--------------------
%	1		____x:	+	M		= main
%	x		____x:	-	S		= subfunction
%	x		____x:	.	   N		= nested function
%	x		____x:	@	      A		= anonymous function
%	x		____x:	!	      E		= eval class call
%	x		____x:	?	         X	= unresolved call
%
%	function with fatal syntax error(s):
%
%	line#:	column#	= <offending syntax>
%	---------------------------------------
%	____x:	y	= <MLINT error message>
%
%NOTE
%-------------------------------------------------------------------------------
%	- clicking on the underlined LINE entry opens the
%	  function in the editor at the corresponding line
%	- whitespaces and continuation statements are removed
%	  for better readability of the function syntax
%	- EOL markers may be indicated by <;>s in FARG_ANONYMOUS
%	  definitions, which still yield a valid, executable
%	  syntax when copy/pasted into the command window (see demo)
%	- definitions are indented according to the function
%	  type for easy reading
%	- current EVAL class calls are eval|evalc|evalin|feval
%	- FARG_ANONYMOUS functions are extracted from SCRIPTs
%	- FARG_ANONYMOUS functions are shown in the full context
%	  of their surrounding statement
%	- if the lex parser encounters fatal errors, it
%	  will stop processing and print a list of the
%	  offending syntax
%
%	  see also: mlint, depfun, depdir, which, functions
%
%EXAMPLE
%-------------------------------------------------------------------------------
%	farg amp1dae	% a MATLAB stock function from the demo folder
%
% % MATLAB version  :   7.8.0.347 (R2009a)                          
% % FARG   version  :   21-Jun-2010 02:16:38                        
% % run    date     :   21-Jun-2010 02:16:38                        
% %                                                                 
% % FILE            :   F:\usr\r2009a\toolbox\matlab\demos\amp1dae.m
% % - Pcode         :                                               
% % - type          :   FUNCTION                                    
% % - date          :   21-Jun-2005                                 
% % - time          :      15:24:08                                 
% % - size          :          2639   bytes                         
% % - LEX tokens    :           554                                 
% %   - lines       :            88                                 
% %   - comments    :            34 /           38.64 %             
% %   - empty       :            14 /           15.91 %             
% %   - warnings    :             0                                 
% %   - complexity  :             1   max                           
% % - calls         :            24                                 
% %   - stock/user  :            10 / unique    10                  
% % - functions     :             3                                 
% %   - main        : +           1 / recursion 0                   
% %   - subroutines : -           0                                 
% %   - nested      : .           1                                 
% %   - anonymous   : @           1                                 
% %   - eval        : !           0                                 
% %   - unresolved  : ?           0                                 
% %                                                                 
% % FUNCTIONS                                                       
% %     #|line      : T  C  syntax                                  
% % ------------------------|--|--|--|---------------------         
% %     1|         1: +  1  amp1dae                                 
% %     2|        31: @           Ue=@(t) 0.4*sin(200*pi*t)         
% %     3|        74: .  1     dudt=f(t,u)                          

%{
	M-FILE content:
	function	ao=dummy1(ai)

	LEX output: r2007b
	'line/col(length): type: token'
	-------------------------------
	'178/ 1(8): FUNCTION:  FUNCTION'	= ixb		2 FUNCTION
	'178/10(2): <NAME>:  ao'
	'178/12(1): '=':  '=''
	'178/13(6): <NAME>:  dummy1'
	'178/19(1): '(':  '(''
	'178/20(2): <NAME>:  ai'
	'178/22(1): ')':  ')''
	'178/31(1): <EOL>:  <EOL>'		= ixb+ixl	2 EOL
%}

% created:
%	us	02-Jan-2005
% modified:
%	us	21-Jun-2010 02:16:38

%{
	g=evalc('farg amp1dae -l');
	g=char(deblank(strread(g,'%s','delimiter','')))
%}

%-------------------------------------------------------------------------------
function	[p,pp]=farg(varargin)

		magic='FARG';
		fver='21-Jun-2010 02:16:38';

% check i/o arguments
	if	~nargin
	if	nargout
		[p,pp]=FARG_ini_par(magic,fver,mfilename,'-d');
	else
		help(mfilename);
	end
		return;
	end

% initialize common parameters
		[p,par]=FARG_ini_par(magic,fver,varargin{:});

% parse file
	if	~par.flg
		[p,par]=FARG_set_text(p,par,1);
		[p,par]=FARG_get_file(p,par);
	if	~par.flg
		[p,par]=FARG_get_calls(p,par);
	if	~par.flg
		[p,par]=FARG_get_entries(p,par);
	end
	end
		[p,par]=FARG_set_text(p,par,2);
	end

% finalize output
	if	nargout
		pp=p;
		pp.hdr=par.hdr;
		pp.res=par.res;
	if	~par.opt.dflg				&&...
		isfield(pp,'par')
		pp=rmfield(pp,'par');
	else
		pp.par=par;
	end
		p=par.res;
	else
		clear p;
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_ini_par(magic,fver,varargin)

		narg=nargin-2;

% initialize common parameters
		F=false;
		T=true;
		p.magic=magic;
		p.([magic,'ver'])=fver;
		p.MLver=version;
		p.rundate=datestr(now);
		p.fnam='';
		p.pnam='';
		p.wnam='';
		p.dnam='';
		p.ftyp='';
		p.mp=[true,true,false];			% M P O
		p.hdr='';
		p.res='';
		p.def={};
		p.sub={};
		p.ixm=[];

		par=p;
		par.txt={};
		par.opt=[];
		par.fh=@FARG_read;

		par.mopt={
			'-m3'
			'-calls'
		};
		par.lopt={
			'-m3'
			'-lex'
		};

% - very simple option parser
		par.opt.dflg=false;
		par.opt.eflg=false;
		par.opt.hflg=false;
		par.opt.line=true;
		par.opt.sflg=true;
		par.opt.Sflg=false;			% hidden option
		par.opt.wflg=false;
	if	narg > 1
	for	i=1:narg
	switch	varargin{i}
	case	'-d'
		par.opt.dflg=true;
	case	'-e'
		par.opt.eflg=true;
	case	'-h'
		par.opt.hflg=true;
	case	'-l'
		par.opt.line=false;
	case	'-s'
		par.opt.sflg=false;
	case	'-S'
		par.opt.Sflg=true;
		par.opt.dflg=true;
	case	'-w'
		par.opt.wflg=true;
	end
	end
	end

		par.fmtnoop='%10d';
		par.fmtopen='<a href="matlab:opentoline(''%s'',%d)">NUMDIG</a>';
		par.fmtopen=strrep(par.fmtopen,'NUMDIG',par.fmtnoop);
		par.fmtmark=sprintf('__&&@@%s@@&&__',par.rundate);	% unique marker
		par.fmtcmp='%1d';

% MLINT R2008b
		par.rexlex='(?<=(:.+:\s+)).+$';
		par.rexmod='(\w+$)|(\d+$)';
		par.lexerr='<LEX_ERR>';
		par.rexcmp='(?<='').*(?='')|(?<=(\s))\d+(?=(\.)$)';
		par.rexcyc='The McCabe complexity of';
% D		par.rexeva='(^feval$)|(^evalc$)|(^evalin$)|(^eval$)|(^assignin$)';
		par.rexeva='(^feval$)|(^evalc$)|(^evalin$)|(^eval$)';
		par.rexfh=@(x) regexp(x,par.rexmod,'match');

		par.ftok={
			'+'	' '		% M: main function
			'-'	' '		% S: subroutine
			'.'	'    '		% N: nested
			'@'	'       '	% A: anonymous
			'?'	'          '	% X: unresolved
			' '	'          '	% U: ML stock functions
			'!'	'       '	% E: eval
			'+'	' '		% R: recursion
			
		};
		par.lexstp={			% @ stop conditions
			'<EOL>'
			''';'''
			''','''
		};
		par.lexbrb={			% @ REVERSE search!
			'''('''
			'''{'''
			'''['''
		};
		par.lexbre={			% @ REVERSE search!
			''')'''
			'''}'''
			''']'''
		};
		par.lent={			% function delimiters
			'FUNCTION'	2
			'<EOL>'		2
		};

		par.scom=...
			@(x) textscan(x,'%d/%d(%d):%[^:]:%s');

		par.mext='.m';
		par.pext={
			'.miss'		0	F
			'.var'		1	F
			'.m'		2	T
			'.mex'		3	T
			'.mdl'		4	T
			'.builtin'	5	T
			'.p'		6	T
			'.folder'	7	F
			'.java'		8	F
		};
		par.mlroot=[matlabroot,filesep,'toolbox'];
		par.ftyp={'SCRIPT','FUNCTION','CLASS'};

		par.stmpl={
			'M'	1	3	true	par.rexfh
			'S'	2	3	false	par.rexfh
			'N'	3	3	true	par.rexfh
			'A'	4	[1,4]	true	par.rexfh
			'X'	5	0	false	''
			'U'	6	3	false	par.rexfh
			'E'	7	0	false	''
			'R'	8	0	false	''
			'O'	9	0	false	''
			'UU'	16	0	false	''
		};
		par.stmplf={
			'fn'	{}	1
			'fd'	{}	1
			'nx'	0	0
			'bx'	[]	2
			'ex'	[]	2
			'lx'	[]	0
			'dd'	[]	1
		};

		par.stmpla.n=zeros(1,size(par.stmpl,1));
		par.senum=par.stmpl(:,1:2).';
		par.senum=struct(par.senum{:});

		par.flg=true;
		par.fver=fver;
		par.rt=0;
		par.shdr=3;
		par.ooff=10-3;				% memo: opentoline offset - n*%+1
		par.crlf=sprintf('\n');
		par.wspace=[' ',sprintf('\t')];
		par.bol='%';
		par.deflin='';

		p.des=par.stmpl(:,1).';
		p.n=par.stmpla.n;

	for	i=1:size(par.stmpl,1)
		fn=par.stmpl{i,1};
	for	j=1:size(par.stmplf,1)
		fm=par.stmplf{j,1};
		par.stmpla.(fn).(fm)=par.stmplf{j,2};
	end
		p.(fn)=par.stmpla.(fn);
	end

% - get/check file name
		flg=false;
		par.fnam=varargin{1};
		ftype=exist(par.fnam,'file');
		[fpat,frot,fext]=fileparts(par.fnam);	%#ok
	if	isempty(fext)				||...
		ftype ~= par.pext{3,2}
		par.fnam=[frot,par.mext];
	end
	if	ftype ~= par.pext{3,2}
		par.pnam=varargin{1};
	end

		par.pnam=which(par.pnam);
% 		par.pnam=strrep(par.pnam,'\','/');	% always UNIX type separators
	if	isempty(par.pnam)
		par.mp(2)=false;
	end
		par.wnam=which(par.fnam);
% 		par.wnam=strrep(par.wnam,'\','/');	% always UNIX type separators
		wtype=exist(par.wnam,'file');
	if	isempty(par.wnam)			||...
		wtype ~= par.pext{3,2}
		flg=true;
		par.mp(1)=false;
	if	par.opt.sflg
		disp(sprintf('%s> ERROR   M-file not found',p.magic));
		disp(sprintf('-----------   %s',varargin{1}));
	end
	end
		par.dnam=dir(par.wnam);
	if	~flg
		par.dnam.ds=strread(par.dnam.date,'%s','whitespace',' ');
	end
	if	par.mp(2)				&&...
		~par.pext{ftype+1,3}
		par.mp=[false,false];
	end

% create output structure
		p.fnam=par.fnam;
		p.pnam=par.pnam;
		p.wnam=par.wnam;
		p.dnam=par.dnam;
		p.mp=par.mp;

		par.nlen=0;
		par.nlex=0;
		par.nfun=0;
		par.mfun=0;
		par.ncom=0;
		par.nemp=0;
		par.file={};
		par.call={};
		par.mlex={};
		par.comt={};
		par.lex={};
		par.ltok={};
		par.lint={};
		par.flg=flg;
		p.par=par;
		p.s=[];
end
%-------------------------------------------------------------------------------
function	[s,nl]=FARG_read(fnam,mode)

% fast TEXTREAD replacement
%
% 		s=textread(fnam,'%s','delimiter','\n','whitespace','');
%
% mode:
%	0	read file
%	1	read file	-> cellstr
%	2	fnam = string	-> cellstr
%
% note:
%		caller MUST check the existence of FNAM!
%
%		old	new
%		------------------
%		''	[1x0 char]

		s='';
	if	mode <= 1
		fp=fopen(fnam,'rt');
	if	fp > 0
		s=fread(fp,inf,'*char').';
		fclose(fp);
	end
		ie=[strfind(s,sprintf('\n')),numel(s)+1];
		nl=numel(ie);
	end

	if	mode >= 1
	if	mode == 2
		s=fnam;
	end
		s=strread(s,'%s','delimiter','','whitespace','');
		nl=size(s,1);
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_get_file(p,par)

% content
		[par.file,par.nlen]=par.fh(par.wnam,0);
% calls
		par.call=mlintmex(par.wnam,par.mopt{:});
		par.call=par.fh(par.call,2);
% tokens
		par.lex=mlintmex(par.wnam,par.lopt{:});
		par.mlex=par.fh(par.lex,2);
% - comments
		ix=	~cellfun(@isempty,strfind(par.mlex,'%:'))	|...
			~cellfun(@isempty,strfind(par.mlex,'%{:'))	|...
			~cellfun(@isempty,strfind(par.mlex,'%}:'));
% - empty lines
		par.comt=par.mlex(ix);
		par.ncom=sum(ix);

		ix=ismember(par.lex,par.wspace);
		par.lex(ix)='';
		par.lex=par.scom(par.lex);
		par.ltok=[par.lex{:,4},par.lex{:,5}];
		par.lex=cat(2,par.lex{1:3});
		par.nlex=size(par.ltok,1);
		par.nemp=sum(accumarray(par.lex(:,1),par.lex(:,3))==1);

		par=FARG_chk_lint(par);
end
%-------------------------------------------------------------------------------
function	par=FARG_chk_lint(par)

		par.lint.ferr=false;
		par.lint.nerr=0;
		par.lint.err={};
		par.lint.serr=[];
		par.lint.mcyc=nan;
		par.lint.ncyc=[];
		par.lint.cyc={};

% errors/warnings
		err=mlint(par.wnam,'-all');
	if	~isempty(err)
	if	~par.opt.line
		fmt=par.fmtnoop;
		fnc=@(x,y,z) sprintf(['%s %5d>',fmt,': %s'],...
				par.bol,x(1),y(1),z(1,:));
	else
		fmt=par.fmtopen;
		fnc=@(x,y,z) sprintf(['%s %5d>',fmt,': %s'],...
				par.bol,x(1),par.wnam,y(1),y(1),z(1,:));
	end
		par.lint.nerr=numel(err);
		par.lint.serr=err;
		par.lint.err=cellfun(@(x,y,z) fnc(x,y,z),...
			num2cell(1:numel(err)),...
			{err.line},...
			{err.message},...
			'uni',false).';
	end

% cyclomatic complexity
		cyc=mlint(par.wnam,'-cyc');
		cyc={cyc.message}.';
		ix=strncmp(cyc,par.rexcyc,numel(par.rexcyc));
	if	any(ix)
		cyc=regexp(cyc(ix),par.rexcmp,'match');
		cyc=[cyc{:}]';
		par.lint.cyc=reshape(cyc.',2,[])';
		par.lint.ncyc=cellfun(@(x) sscanf(x,'%d'),par.lint.cyc(:,2));
		par.lint.mcyc=max(par.lint.ncyc);
		ncmp=max([1,ceil(log10(par.lint.mcyc))]);
		par.fmtcmp=sprintf('%%%ds',ncmp);
	end

% fatal errors
		lerr=sum(strcmp(par.ltok,par.lexerr),2);
	if	any(lerr)
		par.file=par.fh(par.file,2);
		par.lint.ferr=true;
		par.flg=true;
		par.opt.sflg=true;

		ix=find(lerr);
		nx=numel(ix);

		par.txt=[
			par.txt
			'DONE'
			{
			sprintf('%s LEX errors%6d',par.bol,nx)
			'LINE'
			}
		];
	for	i=1:nx
			nl=par.lex(ix(i),:);
	if	par.opt.line
			el=sprintf(par.fmtopen,par.wnam,nl(1),nl(1));
	else
			el=sprintf(par.fmtnoop,nl(1));
	end
			nl(2)=min([nl(2),numel(par.file{nl(1)})]);
			to=par.file{nl(1)}(nl(2));
		par.txt=[
			par.txt
			{
			sprintf('%s line  %s:   %-1d = <%s>\n',par.bol,el,nl(2),to)
			}
			par.lint.err
		];
	end
		par.txt(4,1)={
			sprintf('%s %s\n',par.bol,repmat('-',1,size(char(par.txt(1:3)),2)-3))
		};
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_get_calls(p,par)

		[p,par]=FARG_get_class(p,par,1);

		ic=find(~cellfun(@isempty,par.stmpl(:,end))).';
	for	i=ic
		fn=par.stmpl{i,1};
		v.(fn)=[];				%#ok
		ix=~cellfun('isempty',regexp(par.call,['^',fn],'match'));
	if	any(ix)
		vtmp=par.stmpl{i,5}(par.call(ix));
		bx=cellfun(@(x) sscanf(x,'%*2s %d %d %*s'),par.call(ix),'uni',false);
		ex=bx;
	if	par.stmpl{i,4}
		ex=cellfun(@(x) sscanf(x,'%*2s %d %d %*s'),par.call(find(ix)+1),'uni',false);
	end
		p.n(i)=sum(ix);
		p.(fn).fn=[vtmp{:}].';
		p.(fn).nx=p.n(i);
		p.(fn).bx=[bx{:}];
		p.(fn).ex=[ex{:}];
		p.(fn).lx=cellfun(@numel,p.(fn).fn);
	end
	end
		p.UU=p.U;

		par.nfun=sum(p.n(1:3));			% M S N [A X U E R]
		par.mfun=par.nfun;			% M S N

% 2008b
% - fatal error which currently is not caught in par.lex!
	if	par.mp(3)				&&...
		p.M.nx > 1
		par.lint.ferr=true;
		par.flg=true;
		par.opt.sflg=true;

		par.txt=[
			par.txt
			'DONE'
			{
			sprintf('%s FATAL ERROR',par.bol)
			'LINE'
			}
			par.lint.err
		];
		par.txt(4,1)={
			sprintf('%s %s\n',par.bol,repmat('-',1,size(char(par.txt(1:3)),2)-3))
		};
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_get_class(p,par,mode)

	switch	mode
% create pseudo FUNCTION from CLASSDEF
	case	1
		ich=find(strncmp('CLASSDEF',par.ltok(:,1),numel('CLASSDEF')));
		ic=ich;
	if	strcmp(par.ltok(ic+1,1),'''(''')
		ic=ic+1;
	while	ic < par.nlex
		ic=ic+1;
	if	strcmp(par.ltok(ic,1),''')''')
		break;
	end
	end
	end
	if	any(ich)
		par.ltok(ich,:)=strrep(par.ltok(ich,:),'CLASSDEF','FUNCTION');
% - fool calls
		par.call=[
			{
			sprintf('M%-1d %-1d %-1d %s',0,par.lex(ic+1,1:2),par.ltok{ic+1,2})
			sprintf('E%-1d %-1d %-1d %s',0,par.lex(ic+1,1:2),par.ltok{ic+1,2})
			}
			par.call
		];
		par.mp(3)=1;
		return;
	end

% - adjust complexity
	case	2
	if	par.mp(3)
		fn=cell(par.nfun,1);
	for	i=1:3
		ix=p.ixm(:,2)==i;
	switch	i
	case	1
		fn(ix)=p.M.fn;
	case	2
		fn(ix)=p.S.fn;
	case	3
		fn(ix)=p.N.fn;
	end
	end

	if	~isempty(par.lint.cyc)
		cyc=par.lint.cyc(:,2);
	else
		cyc={};
	end
		tcyc=[
			repmat({'c'},par.nfun-numel(par.lint.ncyc),1)
			cyc
		];
		ncyc=[
			repmat(-1,par.nfun-numel(par.lint.ncyc),1)
			par.lint.ncyc
		];
		par.lint.cyc=[fn,tcyc];
		par.lint.ncyc=ncyc;
		par.lint.mcyc=max(abs(par.lint.ncyc));
		ncmp=max([2,ceil(log10(par.lint.mcyc))]);
		par.fmtcmp=sprintf('%%%ds',ncmp);
	end
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_get_entries(p,par)

		ixt=false(par.nlex,2);
	for	i=1:size(par.lent,1)
		ctok=par.lent{i,1};
		nmatch=par.lent{i,2};
		ixt(:,i)=sum(strcmp(ctok,par.ltok),2)==nmatch;
	end

% parse LEX output for function definitions
% - remove comments!
		lix=strcmp(par.ltok(:,1),'%');
		ltmp=par.ltok(lix,2);
		par.ltok(lix,2)={''};

% - M: main
% - S: sub
		ixb=[];
		sr={};
	if	par.nfun

		p.ixm=zeros(par.nfun,3);
		ixb=zeros(par.nfun,1);
		ixe=zeros(par.nfun,1);
		ixc=zeros(par.nfun,1);
		ixl=zeros(par.nfun,1);
		sr=cell(size(p.ixm,1),1);

	if	p.N.nx
		nix=p.N.bx(1,:);
		nex=p.N.ex(1,:);
	end

	if	par.mfun
		ixb(1:par.mfun,1)=find(ixt(:,1)==1);
	for	i=1:par.mfun
		ixl(i)=find(ixt(ixb(i)+1:end,2)==1,1,'first');
		sr{i}=par.ltok(ixb(i):ixb(i)+ixl(i),2);
		sr{i}=regexprep(sr{i},'^''','');
		sr{i}=regexprep(sr{i},'''$','');
		ixe(i)=par.lex(ixb(i)+ixl(i),1);
		ixb(i)=par.lex(ixb(i),1);
		ixc(i)=par.lex(ixb(i),2);
		sr{i}=sprintf('%s',sr{i}{2:end-1});
		p.ixm(i,:)=[ixb(i),min([i,2]),ixc(i)];
% - N: nested
	if	p.N.nx					&&...
		numel(nex)
	if	any(ixe(i)<=nex(1))			&&...
		any(ixe(i)>=nix(1))
		p.ixm(i,2)=3;
		nex(1)=[];
		nix(1)=[];
	end
	end
	end
	end
		ixb=p.ixm(:,1);
	end

		[p,par]=FARG_get_class(p,par,2);
% look for unresolved calls
		[p,par]=FARG_chk_entries(p,par);

% - A: add anonymous
	if	p.A.nx
		p=FARG_get_context(p,par,'A',false);
		ss=FARG_set_context(p,par,'A');
		p.A.fn=ss;
		p.A.fd=ss;
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'A',ixb);
	end

% - X: add unresolved
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'X',ixb);
% - R: add recursion
	if	p.R.nx
		p=FARG_get_context(p,par,'R',true);
		ss=FARG_set_context(p,par,'R');
		p.R.fd=ss;
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'R',ixb);
	end
% - E: add eval
	if	p.E.nx					&&...
		par.opt.eflg
		p=FARG_get_context(p,par,'E',true);
		ss=FARG_set_context(p,par,'E');
		p.E.fd=ss;
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'E',ixb);
	end

% save calling syntax
	for	i=1:size(par.stmpl,1)
		cf=par.stmpl{i,1};
		cx=par.stmpl{i,2};
	if	par.nfun
		ix=p.ixm(:,2)==cx;
	if	any(ix)
		p.(cf).fd(1:sum(ix),1)=sr(ix);
	end
		p.n(i)=p.(cf).nx;
	end
	end

		p.ftyp=par.ftyp{sign(par.mfun)+1};
		p.s=@(varargin) FARG_show_entries(p,varargin{:});
	if	par.opt.Sflg
		return;
	end

% finalize output
		[p,par,s]=FARG_set_text(p,par,3);
		par.hdr=s{1};
	if	~par.opt.hflg
		[p,par]=FARG_set_entries(p,par,s,sr,ixb);
	else
		par.res=par.hdr;
	end

% restore ori LEX tokens
		par.ltok(lix,2)=ltmp;
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_chk_entries(p,par)

% check for
% - recursion
% - eval...
% - ML stock functions
% - unresolved functions
%   remove known M S N [A X U]
% NOTE:
% - only the FIRST occurrence of a call is listed in U!

% save all calls
% - exists
		ie=cellfun(@exist,p.UU.fn);
		p.UU.dd=ie.';

		p.U.fd=p.U.fn;
		p.U.dd=nan(size(p.U.fd));

% FUNCTION/CLASS
	if	par.nfun
% - recursion
	if	p.M.nx
		ix=strncmp(p.M.fn{1},p.U.fn,numel(p.M.fn{1}));
		ix=ix&(p.U.lx==p.M.lx);
	if	any(ix)
		ie(ix)=[];
%   >1!
		ia=find(strncmp(par.ltok(:,2),p.M.fn{1},numel(p.M.fn{1})));
		ia=ia(par.lex(ia,3)==p.M.lx);
		ia=ia(3:end);
	if	~isempty(ia)
		na=numel(ia);
		p.U.fn=[p.U.fn;repmat(p.U.fn(ix),na,1)];
		p.U.fd=[p.U.fd;repmat(p.U.fd(ix),na,1)];
		p.U.dd=[p.U.dd;repmat(p.U.dd(ix),na,1)];
		p.U.ex=[p.U.ex,par.lex(ia,1:2).'];
		p.U.bx=[p.U.bx,par.lex(ia,1:2).'];
		p.U.nx=p.U.nx+na;
		ix=[ix;true(na,1)];
	end
		[p,par]=FARG_upd_entries(p,par,'R',ix,~ix);
	end
	end

% - eval...
		ix=~cellfun(@isempty,regexp(p.U.fn,par.rexeva));
	if	any(ix)
		ie(ix)=[];
%   >1!
		ia=regexp(par.ltok(:,2),par.rexeva);
		ia=find(~cellfun(@isempty,ia));
		it=~ismember(par.lex(ia,1:2),p.U.bx(:,ix).','rows');
		ia=ia(it);
	if	~isempty(ia)
		na=numel(ia);
		tok=par.ltok(ia,2);
		p.U.fn=[p.U.fn;tok];
		p.U.fd=[p.U.fd;tok];
		p.U.dd=[p.U.dd;nan(na,1)];
		p.U.ex=[p.U.ex,par.lex(ia,1:2).'];
		p.U.bx=[p.U.bx,par.lex(ia,1:2).'];
		p.U.nx=p.U.nx+na;
		ix=[ix;true(na,1)];
	end
		[p,par]=FARG_upd_entries(p,par,'E',ix,~ix);
	end
	end

% - known S/N
		af=[p.S.fn;p.N.fn];
		im=ismember(p.U.fn,af);

% - known path
		id=cellfun(@which,p.U.fn,'uni',false);
		iw=cellfun(@isempty,id);

		p.U.fd(~iw)=id(~iw);
		p.U.dd=ie(:).';

	if	~isempty(im)
		us=~im&iw&ie;				% unknown source
		p.U.fd(us)=cellfun(@(x) sprintf('%s [source?]',x),p.U.fn(us),'uni',false);
		ur=~im&iw;
		uk=~(ur|im);
		[p,par]=FARG_upd_entries(p,par,'X',ur,uk);
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_upd_entries(p,par,fe,ur,uk)

	for	i=1:size(par.stmplf)
		nr=par.stmplf{i,3};
	if	nr
		fn=par.stmplf{i,1};
	switch	nr
	case	1
		p.(fe).(fn)=p.U.(fn)(ur);
		p.U.(fn)=p.U.(fn)(uk);
	case	2
		p.(fe).(fn)=p.U.(fn)(:,ur);
		p.U.(fn)=p.U.(fn)(:,uk);
	end
	end
	end
		p.(fe).nx=sum(ur);
		p.U.nx=sum(uk);
end
%-------------------------------------------------------------------------------
function	[p,par,sr,ixb]=FARG_add_entries(p,par,sr,fe,ixb)

		sub=p.(fe);
	if	sub.nx
		par.nfun=par.nfun+sub.nx;
		ci=numel(ixb);
		ixb=[ixb;sub.bx(1,:).'];
		p.ixm=[p.ixm;[par.senum.(fe)*ones(sub.nx,2),sub.bx(2,:).']];
		p.ixm(:,1)=ixb;
		sr(ci+1:ci+sub.nx)=sub.fd;
		[ix,ix]=sortrows(p.ixm,[1,3,2]);	%#ok
		sr=sr(ix);
		p.ixm=p.ixm(ix,:);
		ixb=p.ixm(:,1);
	end
		p.def=sr;
end
%-------------------------------------------------------------------------------
function	[p,par]=FARG_set_entries(p,par,s,sr,ixb)

% create function entries
	if	par.nfun
		nfmt=repmat({''},par.nfun,1);
		ix=p.ixm(:,2)<4;			% cyc M S N
	if	any(ix)					% FUNCTION
		nfmt(ix)=par.lint.cyc(:,2);
	else						% SCRIPT
		par.fmtcmp='%1s';
	end
		fmt=strrep('%s%6d|%s: %c  X %s','X',par.fmtcmp);
		omax=0;
	for	i=1:par.nfun
		cn=i+par.shdr;
		s{cn}=sprintf(fmt,...
			par.bol,...
			i,...
			par.fmtmark,...
			par.ftok{p.ixm(i,2),1},...
			nfmt{i},...
			par.ftok{p.ixm(i,2),2});
		s{cn}=deblank(sprintf('%s%s',s{cn},sr{i}));
	if	par.opt.line
		of=sprintf(par.fmtopen,par.wnam,ixb(i),ixb(i));
	else
		of=sprintf(par.fmtnoop,ixb(i));
	end
		omax=max([omax,numel(of)]);
		s{cn}=strrep(s{cn},par.fmtmark,of);
	end

	if	par.opt.line
		s{par.shdr}=[par.bol,' ',sprintf(repmat('-',1,size(char(s),2)-omax+par.ooff))];
	else
		cmax=max(cellfun(@numel,s(par.shdr+1:end)));
		s{par.shdr}=[par.bol,' ',sprintf(repmat('-',1,cmax-3))];
	end

		ix=(p.ixm(:,2)==1) | (p.ixm(:,2)==2);
	if	any(ix)
		sf=[p.M.fn;p.S.fn];
		sf=sf(~cellfun(@isempty,sf));
		sd=sr(ix);
		ns=max(cellfun(@numel,sf));
		fmt=sprintf('%%-%ds   >   %%s',ns);
		sd=cellfun(@(a,b) sprintf(fmt,a,b),sf,sd,'uni',false);
		p.sub=sd;
	end
% set function type tabs
		ix=strfind(par.deflin,'syntax');
		im=cellfun(@numel,par.ftok(:,2));
		s{par.shdr}(ix+im-1)='|';

	else
		s=s(1);
	end
		p.def=sr;
		par.res=s;
end
%-------------------------------------------------------------------------------
function	p=FARG_get_context(p,par,fe,isclosed)

	if	isclosed
		lexstp=par.lexstp;
		par.lexstp{3}=''')''';
	end

		sub=p.(fe);
		[ib,ib]=ismember(sub.bx.',par.lex(:,1:2),'rows');	%#ok
		[ie,ie]=ismember(sub.ex.',par.lex(:,1:2),'rows');	%#ok
% search START
	for	ibx=1:numel(ib)
		nb=0;
	for	ix=ib(ibx):-1:1

% - function
	if	isclosed
	if	any(ismember(par.ltok{ix,2},lexstp))
		ib(ibx)=ix+1;
		break;
	end

% - anonymous
	else
		nb=nb+any(ismember(par.ltok{ix,2},par.lexbre));
	if	nb>0
		nb=nb-any(ismember(par.ltok{ix,2},par.lexbrb));
	elseif	~nb
		im=any(ismember(par.ltok{ix,2},par.lexstp));
	if	im
		ib(ibx)=ix+1;
		break;
	end
	end
	end
	end
	end

% search END
	for	ibx=1:numel(ie)
	for	ix=ie(ibx):par.nlex
		im=any(ismember(par.ltok{ix,2},par.lexstp));
	if	im
		ie(ibx)=ix-1;
		break;
	end
	end
	end

		sub.lx=[ib(:).';ie(:).'];
	if	isclosed
		[sub.lx,ix]=sortrows(sub.lx.');
		sub.fn=sub.fn(ix);
		sub.fd=sub.fd(ix);
		sub.lx=sub.lx.';
		sub.bx=sub.bx(:,ix);
		sub.ex=sub.ex(:,ix);
	end
		p.(fe)=sub;
end
%-------------------------------------------------------------------------------
function	ss=FARG_set_context(p,par,fe)

% anonymous functions
%   note to programmers: this IS very tedious because MLINT
%   does NOT correctly evaluate start/end indices of
%   anonymous functions [r2008b: mlint -calls FUNCTION]!
%   currently, this requires
%   - FARG_set_context()
%   - FARG_set_bracket()

		ss=cell(p.(fe).nx,1);
	for	i=1:p.(fe).nx
		dtok=par.ltok(p.(fe).lx(1,i):p.(fe).lx(2,i),:);
		ix=~strncmp('<STRING>',dtok(:,1),8);
		ie= strncmp('<EOL>',dtok(:,1),5);
		iz=cellfun(@numel,dtok(:,1))==1;
		ix=xor(ix,iz);
		a=par.ltok(p.(fe).lx(1,i):p.(fe).lx(2,i),2);
		a(ix)=regexprep(a(ix),'^['']','');
		a(ix)=regexprep(a(ix),'['']$','');
		a(ie)={';'};
		a=sprintf('%s',a{:});
		a=strrep(a,'...','');
		a=strrep(a,''':'':''',':');
		ix=ismember(a,par.wspace);
		a(ix)='';
		ix=find(a=='@',1,'first');
	if	~isempty(ix)
		ix=find(a(ix:end)==')')+ix-1;
		a=[a(1:ix),' ',a(ix+1:end)];
	end
		ss{i}=FARG_set_bracket(a);
	end
end
%-------------------------------------------------------------------------------
function	s=FARG_set_bracket(s)

		br={
			'[]'	1
			'()'	2
			'{}'	3
%			'<>'	4
		};
		ba=cell(size(br,1),1);
	for	i=1:size(br,1)
		bb=strfind(s,br{i,1}(1));
		be=strfind(s,br{i,1}(2));
		k=zeros(size(s));
		k(bb)=ones(size(bb));
		k(be)=-ones(size(be));
		k=cumsum(k);
		k=[k(end:-1:1),0];
	if	k(1) > 0
		bc=br{i,2}*ones(2,k(1));
	for	j=1:k(2)
		bc(1,j)=find(k(1:end-1)==j&k(2:end)==j-1,1,'first');
	end
		ba{i}=bc;
	end
	end

		ba=cat(2,ba{:});
	if	~isempty(ba)
		ba(1,:)=numel(s)-ba(1,:)+1;
		bc=sortrows(ba.',-1).';
		bc=bc(2,:);
		r=char(1:numel(bc)-1);
	for	i=1:size(br,1)
		r(bc==br{i,2})=br{i,1}(2);
	end
		s=[s,r];
	end
end
%-------------------------------------------------------------------------------
function	[p,par,s]=FARG_set_text(p,par,mode)

	if	par.opt.Sflg
		return;
	end

	switch	mode
	case	1
		par.txt(1,1)={
			sprintf('%s parsing...          %s',par.bol,par.wnam)
		};
		FARG_sdisp(par,char(par.txt));
		par.rt=clock;
		return;
	case	2
		par.rt=etime(clock,par.rt);
		par.txt(2,1)={
			sprintf('%s done                %.4f sec',par.bol,par.rt)
		};

	if	~par.lint.ferr				&&...
		par.opt.wflg				&&...
		par.lint.nerr
		nl=max(cellfun(@numel,par.lint.err));
		par.res=[
			par.res
			{
				sprintf('\n%s WARNINGS',par.bol)
				repmat('-',1,nl)
			}
			par.lint.err
		];
	end
		par.res=char(par.res);

	if	~par.flg
		FARG_sdisp(par,char(par.txt(2:end,1)));
		FARG_sdisp(par,char(par.res));
	else
		par.res=char(par.txt);
		FARG_sdisp(par,par.res(1+p.par.opt.sflg:end,:));
	end
		return;
	case	3
		par.txt=[
			par.txt
			{
			'DONE'
%D			sprintf('%s LEX tokens          %-1d',par.bol,par.nlex)
%D			sprintf('%s file type           %s',par.bol,par.ftyp{sign(par.mfun)+1})
%D			sprintf('%s functions           %-1d',par.bol,par.nfun)
			sprintf('');
			}
		];

	if	~isempty(par.pnam)
		pc=par.pnam;
	else
		pc='';
	end

		nu=numel(unique(p.U.fd));
		s=cell(par.nfun+par.shdr,1);
	if	par.mp(3)
		ftype=par.ftyp{3};
	else
		ftype=par.ftyp{sign(par.mfun)+1};
	end

		s{1}={
			sprintf('%s MATLAB version  :   %s',par.bol,par.MLver)
			sprintf('%s %.4s   version  :   %s',par.bol,par.magic,par.fver)
			sprintf('%s run    date     :   %s',par.bol,par.rundate)
			sprintf('%s',par.bol);
			sprintf('%s FILE            :   %s',par.bol,par.wnam)
			sprintf('%s - Pcode         :   %s',par.bol,pc)
			sprintf('%s - type          :   %s',par.bol,ftype)
			sprintf('%s - date          :   %s',par.bol,par.dnam.ds{1})
			sprintf('%s - time          :      %s',par.bol,par.dnam.ds{2})
			sprintf('%s - size          :   %11d   bytes',par.bol,par.dnam.bytes)
			sprintf('%s - LEX tokens    :   %11d',par.bol,par.nlex)
			sprintf('%s   - lines       :   %11d',par.bol,par.nlen)
			sprintf('%s   - comments    :   %11d /           %.2f %%',par.bol,par.ncom,100*par.ncom/par.nlen)
			sprintf('%s   - empty       :   %11d /           %.2f %%',par.bol,par.nemp,100*par.nemp/par.nlen)
			sprintf('%s   - warnings    :   %11d',par.bol,par.lint.nerr)
			sprintf('%s   - complexity  :   %11d   max',par.bol,par.lint.mcyc);
			sprintf('%s - calls         :   %11d',par.bol,sum(p.n))
			sprintf('%s   - stock/user  :   %11d / unique    %-1d',par.bol,p.U.nx,nu)
			sprintf('%s - functions     :   %11d',par.bol,par.nfun)
			sprintf('%s   - main        : %c %11d / recursion %-1d',par.bol,par.ftok{1,1},p.M.nx,p.R.nx)
			sprintf('%s   - subroutines : %c %11d',par.bol,par.ftok{2,1},p.S.nx)
			sprintf('%s   - nested      : %c %11d',par.bol,par.ftok{3,1},p.N.nx)
			sprintf('%s   - anonymous   : %c %11d',par.bol,par.ftok{4,1},p.A.nx)
			sprintf('%s   - eval        : %c %11d',par.bol,par.ftok{7,1},p.E.nx)
			sprintf('%s   - unresolved  : %c %11d',par.bol,par.ftok{5,1},p.X.nx)
		};
		s{1}=char(s{1});

	if	par.nfun
			ctok=strrep(par.fmtcmp,'d','s');
			ctok=sprintf(ctok,'C');
			par.deflin=sprintf('%s     #|line      : T  %s  syntax',...
				par.bol,ctok);
		s{2}={
			sprintf('%s',par.bol)
			sprintf('%s FUNCTIONS',par.bol)
			par.deflin
		};
		s{2}=char(s{2});
		s{par.shdr}='x';
	end
	end
end
%-------------------------------------------------------------------------------
function	FARG_sdisp(par,txt)

	if	par.opt.sflg
		disp(txt);
	end
end
%-------------------------------------------------------------------------------
function	s=FARG_show_entries(p,varargin)

% display a short synopsis of all/selected calls

		ades=p.des(1:end-1);
	if	nargin > 1
		ix=ismember(lower(ades),lower(varargin));
	else
		ix=true(1,numel(ades));
	end
		ades=p.des(ix);
	if	isempty(ades)
		return;
	end

		s=cell(sum(p.n(ix))+numel(ades),1);
		p.A.fd=repmat({''},p.A.nx,1);
		oa=p.A;
		p.A.fn=p.A.fd;
		sm=-inf;
	for	i=ades(:).'
		sm=max([sm;max(cellfun(@numel,p.(i{:}).fn))]);
	end
		p.A=oa;
		ffmt=sprintf('%%%%%%%% -   %%-%d.%ds > %%s',sm,sm);
		afmt=sprintf('%%%%%%%% -   %%s%%s');

		ix=0;
	for	i=1:numel(ades)
		ix=ix+1;
		cd=ades{i};
		s{ix}=sprintf('%%%% %s %d',cd,p.(cd).nx);
	if	cd == 'A'
		fmt=afmt;
	else
		fmt=ffmt;
	end
	for	j=1:p.(cd).nx
		ix=ix+1;
		s{ix}=sprintf(fmt,p.(cd).fn{j},p.(cd).fd{j});
	end
	end

	if	~nargout
		disp(char(s));
		clear	s;
	end
end
%-------------------------------------------------------------------------------