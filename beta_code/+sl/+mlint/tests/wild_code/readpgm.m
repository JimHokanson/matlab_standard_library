function [ img, map ,error] = readpgm( filename )
%READCON       reads an image in pgm format
% syntax:
%     [ img, map,error ] = readpgm( filename )
%
% readpgm reads an image stored in file filename.pgm to matrix img and
% creates appropriate colormap map.
% if succesful error=0, 1 otherwise.

%     Copyright (c) P. Turcaj, R. Turcajova, J. Kautsky, 
%     Flinders University of South Australia.
%     Use of this software without permission of authors is prohibited.

%     Some modifications by Radim Halir, UTIA, 7.12.1993

error=0;
fid = fopen([filename,'.pgm']);
if fid==-1
   dispg(['readcon: can not open file ' filename '.pgm']);
   error=1;
   return;
end;

lab = fgetl(fid);
if lab~='P5'
   dispg('readcon: sorry, can not read this format');
   error=1;
   fclose(fid);
   return;
end;

while(1),
  string = fgets(fid);
  if string(1) ~= '#'
    break
  end
end

size = sscanf(string,'%d', 2);
m = size(1);
n = size(2);
c = fscanf(fid, '%d\n', 1);

map=gray(c+1);
%bits=32;
bits = ceil(log(c)/log(2));
prec = ['uint',int2str(bits)];
%prec = ['uchar'];

[img,count] = fread(fid,[m,n],prec);

img = img';

fclose(fid);
