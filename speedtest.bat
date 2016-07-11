@echo off
CLS
SET heading_line=#######################################################################
SET speedtest_dir=%HOMEPATH%\Desktop\Speedtest

echo %heading_line%
echo Semi-automated Speed Test Logger - for iiNet
echo.
echo License: http://creativecommons.org/licenses/by-sa/4.0/
echo Author:  Justin Swan
echo.
echo Speed Test Instructions: https://iihelp.iinet.net.au/support/node/14495
echo.
echo This script assumes you having Google Chrome installed, and have
echo some basic knowledge on how to use it. Feel free to copy/update/share
echo.
echo This script also assume you are ok, with this script creating a
echo folder here: %speedtest_dir%
echo.
echo %heading_line%
echo.

set /p DUMMY=Press ENTER to continue or CTRL+C to quit
CLS

IF NOT EXIST "%speedtest_dir%" (mkdir %speedtest_dir%)

REM Get Date/Time variables for logging
for /f %%a in ('wmic os get localdatetime ^| find "."') do set dts=%%a
SET Hour=%dts:~8,2%
SET Minute=%dts:~6,2%
SET Time=%Hour%:%Minute%
SET Year=%dts:~0,4%
SET Month=%dts:~4,2%
SET Day=%dts:~6,2%
SET YMD=%Year%-%Month%-%Day%

IF %Hour% LSS 12 (
    SET relative_day=morning
) ELSE IF %Hour% GEQ 18 (
    SET relative_day=evening
) ELSE (
    SET relative_day=afternoon
)

REM Get Mac Address
for /f "usebackq tokens=3 delims=," %%a in (`getmac /fo csv /v ^| find "Local Area Connection"`) do set MAC=%%~a

SET output_basename=%speedtest_dir%\speedtest-%YMD%-%relative_day%-%MAC%
SET output_file=%output_basename%.txt
echo Create speed test file at %output_file%
echo.
echo %heading_line%
echo Test 1 - speedtest.net>%output_file% >&2
echo %heading_line%
@echo Date: %YMD%>>%output_file%
@echo Time: %Time%>>%output_file%

echo.
echo About to open https://www.speedtest.net in Chrome
echo Run test, click 'Share this result', click 'Web', then 
echo Click 'Copy' and paste the result when prompted
echo.
set /p DUMMY=Press ENTER to open https://www.speedtest.net/ in Chrome
start chrome https://www.speedtest.net/
echo.
set /p speedtest_result=Enter speedtest result link (paste):

@echo Result link: %speedtest_result%>>%output_file% 
@echo MAC Address: %MAC%>>%output_file%

REM Get updated time
for /f %%a in ('wmic os get localdatetime ^| find "."') do set dts=%%a
SET Hour=%dts:~8,2%
SET Minute=%dts:~6,2%
SET Time=%Hour%:%Minute%
SET throughput1_file=http://ftp.iinet.net.au/test500MB.dat

@echo --->>%output_file% 
echo.
echo %heading_line%
echo Test 2 - TCP Throughput 1 - Download %throughput1_file% 3 times>>%output_file%>&2
echo %heading_line%
echo About to open %throughput1_file% 3 times
echo 1. Click 'Show all downloads' (bottom right of browser screen after downloads start)
echo 2. Take note of the transfer speeds (they may fluctuate a lot, try and note when they are most steady)
echo.
set /p DUMMY=Press ENTER to open %throughput1_file% in Chrome 3 times
start chrome %throughput1_file%
start chrome %throughput1_file%
start chrome %throughput1_file%
echo.
set /p throughput_result1=Enter transfer rate 1 (numbers only):
set /p throughput_result2=Enter transfer rate 2 (numbers only):
set /p throughput_result3=Enter transfer rate 3 (numbers only):

@echo File 1 Transfer Rate: %throughput_result1%>>%output_file%
@echo File 2 Transfer Rate: %throughput_result2%>>%output_file%
@echo File 3 Transfer Rate: %throughput_result3%>>%output_file%

SET /a transfer_rate_sum = %throughput_result1%+%throughput_result2%+%throughput_result3%
@echo Total File Transfer Rate: %transfer_rate_sum%>>%output_file% >&2
@echo Date: %YMD%>>%output_file%
@echo Time: %Time%>>%output_file%
@echo MAC Address: %MAC%>>%output_file%

echo.
@echo --->>%output_file%

REM Get user to cancel all three download before continuing
set /p DUMMY=Cancel all three download then Press ENTER to continue
echo.

SET throughput2_file=http://speedcheck.cdn.on.net/1000meg.test
echo %heading_line%
echo Test 2 - TCP Throughput 2 - Download %throughput2_file%>>%output_file%>&2
echo %heading_line%
echo About to open %throughput2_file% in Chrome, take note of the transfer speed
set /p DUMMY=Press ENTER to open %throughput2_file% in Chrome
start chrome %throughput2_file%
set /p throughput_result4=Enter transfer rate (numbers only):
echo.
@echo File Transfer Rate: %throughput_result4%>>%output_file%
@echo Date: %YMD%>>%output_file%>>%output_file%
@echo Time: %Time%>>%output_file%>>%output_file%
@echo MAC Address: %MAC%>>%output_file%>>%output_file%

REM Get user to cancel all last download before continuing
set /p DUMMY=Cancel download then Press ENTER to continue

echo.
echo %heading_line%
echo Test 3 - Pings
echo %heading_line%
echo This will take a while, please be patient...
echo.
echo ftp.iinet.net.au
ping -n 100 -w 3000 ftp.iinet.net.au>%output_basename%-pings.txt
echo Done. Result saved.
echo speedcheck.cdn.on.net
ping -n 100 -w 3000 speedcheck.cdn.on.net>>%output_basename%-pings.txt
echo Done. Result saved.
echo speedtest.net
ping -n 100 -w 3000 speedtest.net>>%output_basename%-pings.txt
echo Done. Result saved.
echo.
echo %heading_line%
echo Test 4 - Tracert
echo %heading_line%
echo This will also take a while, please be patient...
echo.
echo ftp.iinet.net.au
tracert ftp.iinet.net.au>%output_basename%-tracerts.txt
echo Done. Result saved.
echo speedcheck.cdn.on.net
tracert speedcheck.cdn.on.net>>%output_basename%-tracerts.txt
echo Done. Result saved.
echo speedtest.net
tracert speedtest.net>>%output_basename%-tracerts.txt
echo Done. Result saved.
echo msn.com
tracert msn.com>>%output_basename%-tracerts.txt
echo Done. Result saved.
echo hotmail.com
tracert hotmail.com>>%output_basename%-tracerts.txt
echo Done. Result saved.
echo.
echo Completed.
