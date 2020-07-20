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
        
        function readActivities(obj,directory)
            arguments
                obj ActivityRegistry
                directory (1,1) string
            end
            
            d = dir(fullfile(directory,"*.fit"));
            
            numPrevSeen = 0;
            numSuccess = 0;
            numNotRuns = 0;
            
            % read activities
            for i=1:numel(d)
                filename = d(i).name;
                status = readActivity(obj,fullfile(directory,filename));
                switch(status)
                    case 0
                        numPrevSeen = numPrevSeen+1;
                    case 1
                        numSuccess = numSuccess+1;
                    case 2
                        numNotRuns = numNotRuns+1;
                end
            end
            fprintf('Read %d files\n',numel(d))
            fprintf('  %d Previously seen\n',numPrevSeen)
            fprintf('  %d Successfully read\n',numSuccess)
            fprintf('  %d Not runs\n',numNotRuns)
            
        end
        
        function status = readActivity(obj,fullpath)
            % status: 0 Previously seen
            %         1 Successful read
            %         2 Not a run
            arguments
                obj (1,1) ActivityRegistry
                fullpath (1,1) string
            end
            
            [~,name,ext] = fileparts(fullpath);
            filename = name + ext;
            
            if obj.hasSeenActivity(filename)
%                 fprintf("%s: Found activity in registry\n",filename)
                status = 0;
            else
                try
                    activity = Activity(fullpath);
                    fprintf("%s: Created activity\n",filename);
                    obj.registerActivity(filename,activity)
                    status = 1;
                catch e
                    if strcmp(e.identifier,'RAT:NotARun')
                        fprintf("%s: Activity is not a run\n",filename)
                        obj.registerNonRun(filename);
                        status = 2;
                    else
                        rethrow(e)
                    end
                end
            end
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