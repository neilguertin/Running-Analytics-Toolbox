The FitSDK source may not be distributed under the terms of its license.
The FitSDK source is available from the ANT+ website.
https://www.thisisant.com/developer/ant/ant-fs-and-fit1
https://www.thisisant.com/resources/fit-sdk/
https://www.thisisant.com/assets/resources/FIT/FitSDKRelease_21.30.00.zip

Place FitSDKRelease_21.30.00\cpp\ from the download
at FitSDK\src\ in this directory.
Delete the unneeded examples, MacStaticLib, and plugins directories.
(You may want to keep the decode.cpp example)

Boost is also required but not included.
https://www.boost.org/users/download/

>> mex readfitmex.cpp FitSDK\src\*.cpp -IFitSDK\src\ -Iboost_1_62_0\;
OR
compile object files and then:
>> mex readfitmex.cpp FitSDK\lib\*.o -IFitSDK\src\ -Iboost_1_62_0\;
