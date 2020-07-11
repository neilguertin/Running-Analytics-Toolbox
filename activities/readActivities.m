function registry = readActivities(registry)
arguments
    registry ActivityRegistry = ActivityRegistry
end

% get directory
basedir = "C:\Users\Neil\Documents\RAT\activities\";
d = dir(fullfile(basedir,"*.fit"));

% read activities
for i=1:numel(d)
    filename = d(i).name;
    readActivity(registry,fullfile(basedir,filename));
end
    
end
