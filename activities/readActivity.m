function readActivity(registry,fullpath)
arguments
    registry (1,1) ActivityRegistry
    fullpath (1,1) string
end

[~,name,ext] = fileparts(fullpath);
filename = name + ext;

fprintf("Getting activity: %s\n",filename)


if registry.hasSeenActivity(filename)
    fprintf("\tFound activity in registry\n")
else
    try
        activity = Activity(fullpath);
        fprintf("\tCreated activity\n");
        registry.registerActivity(filename,activity)
    catch e
        if strcmp(e.identifier,'RAT:NotARun')
            fprintf("\tActivity is not a run\n")
            registry.registerNonRun(filename);
        else
            rethrow(e)
        end
    end
end
end