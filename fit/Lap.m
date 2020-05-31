classdef Lap < handle
    properties
        LapNumber double
        StartTime datetime
        StopTime datetime
        TimerTime duration
        ElapsedTime duration
        StartSplit duration
        StopSplit duration
        Distance double
        Trigger LapTrigger
    end
    
    methods
        function disp(obj)
            fprintf('Lap %d: (%s)\n',obj.LapNumber,obj.Trigger)
            fprintf('\t%s -> %s\n',obj.StartTime, obj.StopTime)
            fprintf('\t%s (%s)\n',obj.TimerTime, obj.ElapsedTime)
            fprintf('\t%s -> %s\n',obj.StartSplit, obj.StopSplit)
            fprintf('\t%dm\n',obj.Distance)
        end
    end
end