classdef tActivityRegistry < matlab.unittest.TestCase
    methods(TestClassSetup)
        function setupPath(testcase)
            testcase.applyFixture(matlab.unittest.fixtures.PathFixture('..'));
        end
    end
    
    methods(Test)
        function testRuns(testcase)
            % registry starts empty
            reg = ActivityRegistry;
            testcase.verifyEqual(height(reg.registry),0);
            
            % read activity, place in registry
            readActivity(reg,fullfile(pwd,'Garmin.fit'));
            testcase.verifyEqual(height(reg.registry),1);
            testcase.verifyEqual(reg.registry.ID(1),"a2020050301")
            
            % reread, should not add to registry.
            readActivity(reg,fullfile(pwd,'Garmin.fit'));
            testcase.verifyEqual(height(reg.registry),1);
            
            % read another activity from same date, should increment id
            readActivity(reg,fullfile(pwd,'GarminCopy.fit'));
            testcase.verifyEqual(height(reg.registry),2);
            testcase.verifyEqual(reg.registry.ID(2),"a2020050302")
        end
        
        function testNonRuns(testcase)
            reg = ActivityRegistry;
            testcase.verifyEqual(numel(reg.nonruns),0);
            
            readActivity(reg,fullfile(pwd,'Bike.fit'));
            testcase.verifyEqual(numel(reg.nonruns),1);
            
            readActivity(reg,fullfile(pwd,'Bike.fit'));
            testcase.verifyEqual(numel(reg.nonruns),1);
        end
            
            
    end
end