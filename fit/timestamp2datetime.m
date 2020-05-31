function dt = timestamp2datetime(timestamp)
% Simple utility for converting time from .fit files (expressed as seconds
% since Dec 31 1989 00:00:00) to MATLAB datetimes.
dt = datetime(timestamp,'convertfrom','epochtime','epoch',datetime(1989,12,31,0,0,0),'TimeZone','UTC');
dt = datetime(dt,'TimeZone','America/New_York');
end