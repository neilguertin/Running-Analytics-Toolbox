classdef treadfit < matlab.unittest.TestCase
    methods(TestClassSetup)
        function setupPath(testcase)
            testcase.applyFixture(matlab.unittest.fixtures.PathFixture('..'));
        end
    end
    
    methods(Test)
        function readTimexFile(testcase)
            % Activity created on Timex GPS watch
            F = readfit('Timex.fit');
        end
        
        function readGarminFile(testcase)
            % Activity created on Timex GPS watch
            F = readfit('Garmin.fit');
        end
    end
end
