classdef Run < Activity
    properties
        RunType (1,1) RunType
        EasyRunType EasyRunType
        WorkoutType WorkoutType
        WorkoutDistances uint16
        WorkoutTimes duration
        RaceType RaceType
        RaceDistance RaceDistance
        RaceTime duration
        
        Shoes (1,1) categorical
        Locations categorical 
        Surface (1,1) Surface
    end
    
    methods
        function obj = Run(filename)
            obj.Fit = readfit(filename);
        end
    end
end