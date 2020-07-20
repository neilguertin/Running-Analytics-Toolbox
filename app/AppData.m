classdef AppData < handle
    properties
        DataDir (1,1) string
        Locations (:,1) categorical
        Shoes (:,1) categorical
    end
    
    methods
        function obj = AppData(DataDir)
            arguments
                DataDir (1,1) string
            end
            obj.DataDir = DataDir;
        end
        
        function readLocations(obj)
            filename = fullfile(obj.DataDir,'locations.txt');
            obj.Locations = categorical(splitlines(string(fileread(filename))));
        end
        
        function readShoes(obj)
            filename = fullfile(obj.DataDir,'shoes.txt');
            obj.Shoes = categorical(splitlines(string(fileread(filename))));
        end
        
        function createActivityRegistry(obj)
            activities = ActivityRegistry;
            activities.readActivities(fullfile(obj.DataDir,'activities'));
            
            filename = fullfile(obj.DataDir,'activities.mat');
            save(filename,'activities')
            evalin('caller',sprintf("load('%s','activities')",filename))
        end
        
        function loadActivityRegistry(obj)
            filename = fullfile(obj.DataDir,'activities.mat');
            if ~isfile(filename)
                disp('Creating Activity Registry')
                obj.createActivityRegistry;
            end
            evalin('caller',sprintf("load('%s','activities')",filename))
        end
        
        function updateActivityRegistry(obj)
            filename = fullfile(obj.DataDir,'activities.mat');
            if ~isfile(filename)
                disp('Creating Activity Registry')
                activities = ActivityRegistry;
                activities.readActivities(fullfile(obj.DataDir,'activities'));
                save(filename,'activities')
            else
                disp('Updating Activity Registry')
                load(filename,'activities');
                activities.readActivities(fullfile(obj.DataDir,'activities'));
                save(filename,'activities')
            end
            evalin('caller',sprintf("load('%s','activities')",filename))
        end
    end
    
end
