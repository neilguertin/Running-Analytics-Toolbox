classdef ActivityRegistry < handle
    % Associates activity id, original fit file, and activity obj.
    
    properties
        registry table
        nonruns string
    end
    
    
    methods
        function obj = ActivityRegistry()
            obj.registry = table('Size',[0 3],'VariableTypes',{'string','string','Activity'},'VariableNames',{'ID','Filename','Activity'});
            obj.nonruns = string.empty;
        end
        
        function registerActivity(obj,filename,activityObj)
            % also sets ID
            startTime = activityObj.getDate;
            idStart = sprintf("a%4d%02d%02d",year(startTime),month(startTime),day(startTime));
            idNum = nnz(startsWith(obj.registry.ID,idStart)) + 1;
            id = sprintf(idStart + "%02d",idNum);
            
            activityObj.setID(id);

            obj.registry(end+1,:) = {id,filename,activityObj};
        end
        
        function registerNonRun(obj,filename)
            obj.nonruns(end+1) = filename;
        end
        
        function tf = hasSeenActivity(obj,filename)
            tfruns = any(strcmp(filename,obj.registry.Filename));
            tfnonruns = ismember(filename,obj.nonruns);
            tf = tfruns || tfnonruns;
        end
        
        function activity = getActivity(obj,filename)
            ind = find(strcmp(filename,obj.registry.Filename));
            if numel(ind) == 0
                error('RAT:ActivityNotFound','Could not find activity matching that filename')
            elseif numel(ind) > 1
                error('RAT:MultipleActivities','Filename matched more than one activity')
            else
                activity = obj.registry.Activity(ind);
            end
        end
    end
end