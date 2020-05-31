classdef FitFile < handle
    % Contains all the information worth keeping from a .fit file
    
    % Metadata
    properties
        Filename string
    end
    
    % Summary Data
    properties
        StartTime datetime
        StopTime datetime
        ElapsedTime duration
        TimerTime duration
        Distance double
        NumLaps double
        Laps Lap
    end
    
    % Tabular Data
    properties
        Data timetable
        Units cell
    end
    
    methods
        function printLaps(obj)
            for i=1:obj.NumLaps
                disp(obj.Laps(i))
            end
        end
        
        function validate(obj)
            assert(~isempty(obj.Filename))
            
            assert(~isempty(obj.StartTime))
            assert(~isempty(obj.StopTime))
            assert(~isempty(obj.ElapsedTime))
            assert(~isempty(obj.TimerTime))
            assert(~isempty(obj.Distance))
            assert(~isempty(obj.NumLaps))
            assert(obj.NumLaps == numel(obj.Laps))
            
            assert(~isempty(obj.Data))
            assert(~isempty(obj.Units))
            assert(numel(obj.Units) == size(obj.Data,2))
        end
        
    end
end