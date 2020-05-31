classdef treadfitraw < matlab.unittest.TestCase
    methods(TestClassSetup)
        function setupPath(testcase)
            testcase.applyFixture(matlab.unittest.fixtures.PathFixture('..'));
        end
    end
    
    methods(Test)
        function readSampleFile(testcase)
            % Example activity provided in FitSDK
            load expectedFitRaw.mat expm1 expd1
            [actm1, actd1] = readfitraw('Activity.fit');
            testcase.verifyEqual(actm1,expm1);
            testcase.verifyEqual(actd1,expd1);
        end
        
        function readTimexFile(testcase)
            % Activity created on Timex GPS watch
            load expectedFitRaw.mat expm2 expd2
            [actm2, actd2] = readfitraw('Timex.fit');
            testcase.verifyEqual(actm2,expm2);
            testcase.verifyEqual(actd2,expd2);
        end
        
        function readGarminFile(testcase)
            load expectedFitRaw.mat expm3 expd3
            % Activity created on Garmin Forerunner 935 with Stryd
            [actm3, actd3] = readfitraw('Garmin.fit');
            testcase.verifyEqual(actm3,expm3);
            testcase.verifyEqual(actd3,expd3);
        end
    end
end
