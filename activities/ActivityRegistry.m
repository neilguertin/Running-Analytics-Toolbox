classdef ActivityRegistry < handle
    % Associates activity id, original fit file, and activity obj.
    
    properties
        registry table
        numruns double
        nonruns string
    end
    
    
    methods
        function obj = ActivityRegistry(preallocate)
            arguments
                preallocate (1,1) double = 0
            end
            obj.registry = table('Size',[preallocate 3],'VariableTypes',{'string','string','Activity'},'VariableNames',{'ID','Filename','Activity'});
            obj.nonruns = string.empty;
            obj.numruns = 0;
        end
        
        function registerActivity(obj,filename,activityObj)
            % also sets ID
            startTime = activityObj.getDate;
            idStart = sprintf("a%4d%02d%02d",year(startTime),month(startTime),day(startTime));
            idNum = nnz(startsWith(obj.registry.ID,idStart)) + 1;
            id = sprintf(idStart + "%02d",idNum);
            
            activityObj.setID(id);

            obj.registry(obj.numruns+1,:) = {id,filename,activityObj};
            obj.numruns = obj.numruns+1;
        end
        
        function registerNonRun(obj,filename)
            obj.nonruns(end+1) = filename;
        end
        
        function tf = hasSeenActivity(obj,filename)
            tfruns = any(strcmp(filename,obj.registry.Filename));
            tfnonruns = ismember(filename,obj.nonruns);
            tf = tfruns || tfnonruns;
        end
        
        function activity = getActivity(obj,filenameORid)
            arguments
                obj ActivityRegistry
                filenameORid (1,1) string
            end
            ind = obj.getRow(filenameORid);
            activity = obj.registry.Activity(ind);
        end
        
        function deleteActivity(obj,filenameORid)
            arguments
                obj ActivityRegistry
                filenameORid (1,1) string
            end
            ind = obj.getRow(filenameORid);
            obj.registry(ind,:) = [];
            obj.numruns = obj.numruns - 1;
        end
            
    end
    
    methods(Access=private)
        function row = getRow(obj,filenameORid)
            arguments
                obj ActivityRegistry
                filenameORid (1,1) string
            end
            
            if regexp(filenameORid,"a\d{10}") % id
                id = filenameORid;
                row = find(strcmp(id,obj.registry.ID));
            elseif regexp(filenameORid,"\d{10}.fit") % filename
                filename = filenameORid;
                row = find(strcmp(filename,obj.registry.Filename));
            else
                error('RAT:BadID','Bad ID or filename: %s',filenameORid)
            end
            
            if numel(row) == 0
                error('RAT:ActivityNotFound','Filename or ID did not match any activity: %s',filenameORid)
            elseif numel(row) > 1
                error('RAT:MultipleActivities','Filename or ID matched more than one activity: %s',filenameORid)
            end
        end
    end

end