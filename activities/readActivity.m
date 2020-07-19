function readActivity(registry,fullpath)
arguments
    registry (1,1) ActivityRegistry
    fullpath (1,1) string
end

[~,name,ext] = fileparts(fullpath);
filename = name + ext;

if registry.hasSeenActivity(filename)
    fprintf("%s: Found activity in registry\n",filename)
else
    try
        activity = Activity(fullpath);
        fprintf("%s: Created activity\n",filename);
        registry.registerActivity(filename,activity)
    catch e
        if strcmp(e.identifier,'RAT:NotARun')
            fprintf("%s: Activity is not a run\n",filename)
            registry.registerNonRun(filename);
        else
            rethrow(e)
        end
    end
end
end