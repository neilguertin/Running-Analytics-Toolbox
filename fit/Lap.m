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
            for i=1:numel(obj)
                fprintf('Lap %d: (%s)\n',obj(i).LapNumber,obj(i).Trigger)
                fprintf('\t%s -> %s\n',obj(i).StartTime, obj(i).StopTime)
                fprintf('\t%s (%s)\n',obj(i).TimerTime, obj(i).ElapsedTime)
                fprintf('\t%s -> %s\n',obj(i).StartSplit, obj(i).StopSplit)
                fprintf('\t%dm\n',obj(i).Distance)
            end
        end
    end
end