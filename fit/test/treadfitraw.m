classdef treadfitraw < matlab.unittest.TestCase
    methods(TestClassSetup)
        function setupPath(testcase)
            testcase.applyFixture(matlab.unittest.fixtures.PathFixture('..'));
        end
    end
    methods(Test)
        function readFitFiles(testcase)
            load expectedFitRaw.mat expm1 expd1 expm2 expd2 expm3 expd3
            
            % Example activity provided in FitSDK
            [actm1, actd1] = readfitraw('Activity.fit');
            testcase.verifyEqual(actm1,expm1);
            testcase.verifyEqual(actd1,expd1);
            
            % Activity created on Timex GPS watch
            [actm2, actd2] = readfitraw('2586364857.fit');
            testcase.verifyEqual(actm2,expm2);
            testcase.verifyEqual(actd2,expd2);
            
            % Activity created on Garmin Forerunner 935 with Stryd
            [actm3, actd3] = readfitraw('3622644364.fit');
            testcase.verifyEqual(actm3,expm3);
            testcase.verifyEqual(actd3,expd3);
        end
    end
end
        