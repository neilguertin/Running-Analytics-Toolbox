function [metadata, data] = readfitraw(filename)
% This function gets the contents of a .fit file as close as possible to
% the original form. The result is two struct arrays with the following
% fields. One contains the messages of type 'record', the second by second
% data gathered during an activity. The other contains all other messages,
% including metadata about the activity, the device, laps, etc.
%   name - char array - The name of the message
%   fields - cell array of char arrays - A list of names of fields in the message
%   units - cell array of char arrays - A corresponding list of units for each field
%   values - cell array of string or double arrays - A corresponding list of
%            values of each field. Most are scalars but some may be vectors.

arguments
    filename (1,:) char {fileExists}
end

disp(['Reading ' filename])

clear readfitmex
tic;
S = readfitmex(filename);
t = toc;
disp(['File has ' num2str(numel(S)) ' messages'])
disp(['Reading took ' num2str(t) 's'])

tic;
m = struct('name',{},'fields',{},'units',{},'values',{});
d = struct('name',{},'fields',{},'units',{},'values',{});
for i=1:numel(S)
    switch(S(i).name)
        case 'record'
            d(end+1) = S(i);
        otherwise
            m(end+1) = S(i);
    end
end
t = toc;
disp(['Processing took ' num2str(t) 's'])

metadata = m;
data = d;

end

function fileExists(filename)
if exist(filename) ~= 2
    error("File: %s does not exist",filename);
end
end