classdef Activity < handle
    properties
        ID string %aYYYYMMDDNN
        Title string
        Sport
        Stress
        Tags

        WeatherReport
        InjuryReport
        FitnessReport
        PersonalReport
    end
    
    properties(Access=protected)
        Fit FitFile
    end
    
    methods
        function obj = Activity(filename)
            obj.Fit = readfit(filename);
        end
        
        function tf = isRun(obj)
            tf = (obj.Sport == "Run");
        end
        
        function fitfile = getFitFilename(obj)
            fitfile = obj.Fit.Filename;
        end
        
        function date = getDate(obj)
            date = obj.Fit.StartTime;
        end
        
        function setID(obj,id)
            obj.ID = id;
        end
    end
end

