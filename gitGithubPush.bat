@echo off
chcp 65001 >nul

rem git alias: pg = push -u origin main (Gitea) / ph = push -u github main (GitHub) / gp = pull --ff-only origin main

rem Chinese text lives in gitGithubPush.msg.txt (UTF-8), not in this .bat.
rem cmd reads a .bat in 1024-byte blocks; if a block boundary lands inside a multi-byte
rem character, the line is cut in half and cmd reports "not recognized".
rem Keeping this file ASCII-only avoids it, and the messages are loaded into M_* variables.
set "MSG=%~dp0gitGithubPush.msg.txt"
for /f "usebackq tokens=1,* delims==" %%k in ("%MSG%") do set "M_%%k=%%l"

rem order matters: push the three submodules first, so the parent repo records the right commit pointer
call :PUSH_REPO "D:\goodwaymis9527\LucaWebVercel" "luca-web (submodule)" "%M_C_WEB%"
if errorlevel 1 goto FAIL

call :PUSH_REPO "D:\goodwaymis9527\LucaAWS" "luca-aws (submodule)" "%M_C_AWS%"
if errorlevel 1 goto FAIL

call :PUSH_REPO "D:\goodwaymis9527\LucaPython" "luca-python (submodule)" "%M_C_PY%"
if errorlevel 1 goto FAIL

call :PUSH_REPO "D:\goodwaymis9527" "GitHub Pages" "%M_C_ROOT%"
if errorlevel 1 goto FAIL

echo.
rem the root index.html is a meta refresh page; the site itself is in wwwHttps/
echo %M_SITE%
echo %M_L_WEB%
echo %M_L_AWS%
echo %M_L_PY%
echo.
echo %M_DONE%
echo ---
echo.

pause
exit /b

:PUSH_REPO
rem %~1 = folder   %~2 = display name   %~3 = commit message
echo.
echo.
echo [Push] %~2
echo %M_FOLDER%: %~1
echo ---
echo %M_WAIT%
echo.

cd /d %~1 || (
    echo %M_BAD% %M_FAIL_CD%
    exit /b 1
)
echo.

rem step 0: working tree must have no merge conflict markers
git grep -nE "^(<<<<<<< |>>>>>>> )"
if not errorlevel 1 (
    echo %M_BAD% %M_FAIL_CONFLICT%
    exit /b 1
)
echo %M_NOCONFLICT%
echo.

rem step 1: stage everything
echo git add .
echo ---
git add .
if errorlevel 1 (
    echo %M_BAD% %M_FAIL_ADD%
    exit /b 1
)
echo.

rem step 2: scan conflict markers again after staging
git grep --cached -nE "^(<<<<<<< |>>>>>>> )"
if not errorlevel 1 (
    echo %M_BAD% %M_FAIL_CACHED%
    exit /b 1
)
echo %M_NOCACHED%
echo.

rem step 3: commit only when there is something staged
git diff --cached --quiet
if not errorlevel 1 goto NOCHANGE

echo %M_COMMITTING%
git commit -m "%~3"
if errorlevel 1 (
    echo %M_BAD% %M_FAIL_COMMIT%
    exit /b 1
)
goto AFTERCOMMIT

:NOCHANGE
echo %M_NOCHANGE%

:AFTERCOMMIT
echo.

rem step 4: push (alias ph = push -u github main)
echo git ph
echo ---
git ph
if errorlevel 1 (
    echo %M_BAD% %M_FAIL_PUSH%
    exit /b 1
)
echo %M_OK% %~2 %M_PSHED%
exit /b 0

:FAIL
echo.
echo %M_BAD% %M_FAIL_ABORT%
echo ---
echo.
pause
exit /b 1
