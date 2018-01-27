@echo off
REM delayedexpansion enabled for !errorlevel!, !iris!, !irs!, !profiles:~%%A,1!, !profiles_next:~%%A,1!, !prof! and !prof_next!
REM to disable it, each relevant code has to be moved to its own subroutine changing ! by %
SETLOCAL enabledelayedexpansion

set iris=
set irs=
set ch2=
set A=
set mode=
set choicearg=
set prof=
set prof_next=

REM automated variables
set timer=6
set profiles=D N R
set profiles_next=N R D
REM letter's sequence is dependent of choice's errorlevel configuration
set keys=%profiles% L S
REM convert all spaces " " with empty commas "," (:" "=","%)
set keysshow=%keys: =,%
REM convert all spaces " " with empty strings "" (:" "=""%)
set keyschoice=%keys: =%

REM first screen
echo ____                      _____________________________________
echo     \  Profile  SWitcher  \
echo      \  for  Iris  micro   \    by bdamasceno at hotmail.com.br
echo ______\   v0.8  2018.01.07  \__________________________________
echo.
echo Use this Profile SWitcher to control Iris micro on Windows 7
echo Use psw.cmd [%keysshow%] to run it in cmdline mode (e.g. psw s)
echo.
echo.

REM input validation
for %%A IN (%keys%) do (
			ECHO "%~1"| FIND /I """%%A""" >nul
			set iris=!errorlevel!
			if !iris! EQU 0 (goto input_val)
			)
:input_val
if %iris% EQU 1 (
		set mode=menu
		set choicearg=/T %timer% /D s
		)
if %iris% EQU 0 (
		set mode=cmdline
		REM tried to add nul redirection to choicearg (so the default option isn´t echoed to console) but it didn´t work
		set choicearg=/T 0 /D %1 /N
		echo cmdline running mode
		)
goto %mode%

:menu
echo _______________________________
echo                           \Menu\_______________________________
echo.
echo  __switch mode  [S] cycles the profiles (default)
echo  __last switch  [L] repeats the last profile from switch mode
echo.
echo  _____profiles  [D] day profile
echo  _____________  [N] night profile
echo  _____________  [R] reset profile
echo.
echo.

:cmdline
CHOICE /C %keyschoice% %choicearg%
set iris=%errorlevel%
if %iris% GTR 4 (goto switch_mode)
if %iris% EQU 4 (goto last_switch)
if %iris% EQU 3 (set ch2=R)
if %iris% EQU 2 (set ch2=N)
if %iris% EQU 1 (set ch2=D)


:run_iris
if %ch2%==D (iris-micro 5000 100 >nul)
if %ch2%==N (iris-micro 3900 80 >nul)
if %ch2%==R (iris-micro 6500 100 >nul)

echo _________________________________
echo                           \Thanks\_____________________________
echo.
echo @ Daniel Georgiev (https://iristech.co/iris-micro/)
echo.
echo @ Rob van der Woude's Scripting Pages (www.robvanderwoude.com)
echo.
choice /C yn /T %timer% /D y /N >nul

ENDLOCAL
goto:EOF


:test
REM reset %irs% because it can be called twice from :switch_mode
set irs=0
REM searches and counts the number of valid predefined .irs files
for %%A IN (%keys%) do (
			if exist %%A.irs (set /a irs+=1)
			)
goto:EOF


:switch_mode
REM the profile switcher memory is based on an set of empty predefined .irs files
echo using Switch Mode
call :test
REM if result is false it ereases all .irs for safety and creates a default one (empty R.irs) to solve a few (not all) corner cases
if not %irs%==1 (
		del *.irs
		call :error
		echo creating default .irs file
		cd.> R.irs
		REM second pass test (can change %irs% value)
		call :test
		REM if the second pass couldn´t solve the problem it gives up
		if not !irs!==1 (goto error)
		)

REM detects last .irs file and sets the next one on ch2 (change to)
for %%A IN (0 2 4) do (
			REM get one letter at time from %profiles% and %profiles_next%
			set prof=!profiles:~%%A,1!
			set prof_next=!profiles_next:~%%A,1!
			if exist !prof!.irs (set ch2=!prof_next!)
			)

echo switching to [%ch2%]
echo updating .irs file

REM tries to rename the last .irs file to the next one (D to N to R to D)
ren ?.irs %ch2%.irs
goto run_iris


:last_switch
echo searching the last .irs file from switch mode
call :test
if not %irs%==1 (goto error)

REM detects last .irs file and sets it on ch2 (change to)
for %%A IN (%profiles%) do (
			if exist %%A.irs (set ch2=%%A)
			)

echo last profile was [%ch2%]
goto run_iris


:error
echo psw error: valid .irs file search has failed
goto :EOF


some references

stackoverflow.com/questions/24078870/batch-file-not-setting-variable
www.robvanderwoude.com/variableexpansion.php and
www.robvanderwoude.com/battech.php
www.robvanderwoude.com/battech_inputvalidation_commandline.php
www.robvanderwoude.com/battech_redirection.php
www.robvanderwoude.com/batchcommands.php
www.robvanderwoude.com/ntset.php#SubStr
www.dostips.com/DtTipsStringManipulation.php


changelog

v0.8 20180107	added support for cmdline arguments
		added several variables for easy code maintenance
		choice command shared by both menu and cmdline modes
		changed switch_mode and last_switch to use new variables
		changed :error from label to subroutine so it can be called by switch_mode on 1st pass test
		simplified console output
		excluded timer subroutine
		timeout command replaced by choice and moved just before ENDLOCAL (less disk access)
		better execution info
		added changelog and references
		updated comments

v0.7 20171220	simpler iris-micro execution with 1 additional variable and 2 less subroutines
		better switcher mechanism with 1 additional variable and a test subroutine
		enabled delayed expansion
		adopted some best pratices (SETLOCAL, variable initialization and comments)
		better execution info

v0.6 20171216	changed menu description
		simpler execution info for last mode

v0.5 20171215	changed menu description
		centralized switcher mechanism

v0.4 20171211	changed menu description

v0.3 20171209	added last mode and direct access to profiles
		changed the switcher to use empty .irs files
		added a simple timer subroutine to pause console output
		added menu, execution info and thanks note

v0.2 20171120	initial swither version