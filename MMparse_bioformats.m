function dataset = MMparse_bioformats(filename)
%
% First attempt at using BioFormats reader to read Micro-manager files into
% Matlab.

data = bfopen(filename);
ims = data{1};
nims = size(ims,1);

%open first image string and work out number of Channels, Time points, and
%Z-stacks
text = ims{1,2};
tok = regexpi(text, 'C=\d+/(\d+)','tokens');
if ~isempty(tok)
    nchan = str2double(tok{1}{1});
else
    nchan = 1;
end

tok = regexpi(text, 'T=\d+/(\d+)','tokens');
if ~isempty(tok)
    ntime = str2double(tok{1}{1});
else
    ntime = 1;
end

tok = regexpi(text, 'Z=\d+/(\d+)','tokens');
if ~isempty(tok)
    nZ = str2double(tok{1}{1});
else
    nZ = 1;
end

if nZ * ntime * nchan ~= nims
    error('Incorrect number of planes')
end

dataset = zeros([size(ims{1, 1}), nZ, ntime, nchan]);

for n=1:nims
    tok = regexpi(ims{n,2}, 'T=(\d+)/\d+','tokens');
    if ~isempty(tok)
        T = str2double(tok{1}{1});
    else
        T = 1;
    end
    tok = regexpi(ims{n,2}, 'Z=(\d+)/\d+','tokens');
    if ~isempty(tok)
        Z = str2double(tok{1}{1});
    else
        Z = 1;
    end
    tok = regexpi(ims{n,2}, 'C=(\d+)/\d+','tokens');
    if ~isempty(tok)
        C = str2double(tok{1}{1});
    else
        C = 1;
    end
    dataset(:,:,Z,T,C) = ims{n,1};
end
