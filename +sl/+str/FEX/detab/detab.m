% DETAB
%	replaces TAB characters with the appropriate
%	number of SPACE characters
%
% SYNTAX
%		[CS,P] = detab(FILE)
%		[CS,P] = detab(CSTR)
%		[CS,P] = detab(....,OPT1,...,OPTn)
%
% INPUT
% -------
% FILE	:	file name
% CSTR	:	cell array of any size with strings
%			note	the array may contain other classes
% OPT	:	arg	processing
% ---------------------------------------------------------------------------------
% -t	:	len	length of a TAB in SPACES			[def: 8]
% -c	:	char	a character marking the last SPACE of a TAB	[def: ' ']
% -l	:	-	show result in a listbox			[def: none]
% -lp	:	{p,v}	parameter/value pairs to change listbox defs	[def: none]
%
%
% OUTPUT
% -------
% CS	:	cell array of detabulated strings
%			note	CS has the same size as CSTR
% P	:	parameter with these selected fields
%		.par.tab	tabulator header
%		.input		input spec: CELL|file name
%		.cs		size of .input
%		.ns		nr of cells
%		.nc		nr of cell strings
%		.nl		nr of lines with TABs
%		.nt		nr of TABs
%
% EXAMPLE
%		detab DETAB.M using <|> as end-of-TAB marker
%		show result in a listbox
%			[cs,p] = detab('detab.m','-c','|','-l');
%		show tabulator and first 6 lines
%			disp(char([p.par.tab;cs(1:6)]));

% created:
%	us	21-Apr-1992
% modified:
%	us	28-Mar-2006 16:25:00

%--------------------------------------------------------------------------------
function	[ss,p]=detab(cstr,varargin)

% default parameters/options
		magic='DETAB';
		ver='28-Mar-2006 16:25:00';
		ss=[];
		p=[];
		fnam='CELL';

% - default options
		deftlen=8;
		deftchar=' ';

% - option template
		otmpl={
%		opt	ival	narg	defval		desc
%		----------------------------------------------
		'-t'	true	1	deftlen		'tab length in char'
		'-c'	true	1	deftchar	'tab end marker'
		'-l'	false	0	[]		'show listbox'
		'-lp'	false	1	{}		'listbox parameters'
		};

	if	nargin < 1
		help(mfilename);
		return;
	end
		[opt,par]=get_par(otmpl,varargin{:});

	if	ischar(cstr)
		fnam=which(cstr);
	if	~exist(cstr,'file')
		disp(sprintf('DETAB> file not found <%s>',fnam));
		return;
	end
		[fp,msg]=fopen(fnam,'rb');
	if	fp < 0
		disp(sprintf('DETAB> cannot open file <%s>',fnam));
		disp(sprintf('       %s',msg));
		return;
	end
		cstr=textscan(fp,'%s',...
			'delimiter','\n',...
			'whitespace','');
		fclose(fp);
		cstr=cstr{:};
	elseif	~iscell(cstr)
		disp('DETAB> input must be a file name or a cell');
		return;
	end

		tab=sprintf('\t');
% read argument

		p.magic=magic;
		p.ver=ver;
		p.mver=version;
		p.rundate=datestr(clock);
		p.runtime=clock;
		p.par=par;
		p.opt=opt;
		p.input=fnam;
		p.cs=size(cstr);
		p.ns=numel(cstr);
		p.nc=0;
		p.nl=0;
		p.nt=0;

% convert string cells only
		cstr=cstr(:);
		ix=cellfun('isclass',cstr,'char');
		p.nc=sum(ix);
	if	~p.nc
		ss=cstr;
		return;
	end
		ss=cstr(ix);

		tmax=max(cellfun('length',ss));
		tlen=p.opt.t.val;
		tt=tlen:tlen:tmax*tlen;
		p.par.tab=repmat(['.......',p.par.tc],1,ceil(tmax/tlen));
		ttb=sprintf('TAB=%-1d',tlen);
		p.par.tab(1:length(ttb))=ttb;

		p.runtime=clock;
% reconstruct absolute position based on cumulative TABs
	for	i=1:p.nc
		s=ss{i};
		tp=strfind(s,tab);
	if	~isempty(tp)
		nt=numel(tp);
		p.nl=p.nl+1;
		p.nt=p.nt+nt;
		tn=1:nt;
		tm=tt(tn);
		tx=tm-tp+tn;
		tx(end)=[];
		tx=[0,tx]+tp-tn;
		tx=tm-tx;
		tx=mod(tx-1,tlen)+1;
		tx=p.par.t(tx);
		ss{i,1}=regexprep(s,'\t',tx,'once');
	end
	end
		p.runtime=etime(clock,p.runtime);
		cstr(ix)=ss;
		ss=reshape(cstr,p.cs);
		
% show contents in listbox
	if	p.opt.l.flg
		blim=.005;
		clf;
		shg;
		p.par.uh=uicontrol('units','norm',...
			'position',[blim,blim,1-2*blim,1-2*blim],...
			'style','listbox',...
			'max',2,...
			'fontname','courier new',...
			'backgroundcolor',1*[.75 1 1],...
			'foregroundcolor',[0 0 1],...
			'tag',p.magic,...
			p.opt.lp.val{:});
% - fastes listbox fill mode (pcode!)
		sh=char([{p.par.tab};ss(ix)]);
		set(p.par.uh,'string',sh);
	end
		return;
%--------------------------------------------------------------------------------
function	[opt,par]=get_par(otmpl,varargin)
% option parser

		par.t=[];
		par.tab=[];

		narg=nargin-1;
	for	i=1:size(otmpl,1)
		[oflg,val,arg,dval]=otmpl{i,1:4};
		flg=oflg(2:end);
		opt.(flg).flg=val;
		opt.(flg).val=dval;
		ix=strcmp(oflg,varargin);
		ix=find(ix,1,'last');
	if	ix
		opt.(flg).flg=true;
	if	arg
	if	narg >= ix+arg
		opt.(flg).val=varargin{ix+1:ix+arg};
	else
		opt.(flg).flg=val;
	end
	end
	end
	end

% create TAB replacement templates
		tlen=opt.t.val;
		par.t=cell(tlen,1);
	for	i=1:tlen
		par.t{i,1}=sprintf('%*s',i,opt.c.val);
	end

% - tabulator marker
	if	~isempty(opt.c.val)	&&...
		~isspace(opt.c.val)
		par.tc=opt.c.val;
	else
		par.tc=char(166);	% <¦>
	end
		par.uh=[];
		return;
%--------------------------------------------------------------------------------
