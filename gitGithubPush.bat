@echo off
chcp 65001 >nul
rem git 別名：pg = push -u origin main (Gitea) / ph = push -u github main (GitHub) / gp = pull --ff-only origin main

rem ── 順序很重要：先 push 三個 submodule，外層 repo 才會記錄正確的 commit 指針 ──
call :PUSH_REPO "D:\goodwaymis9527\LucaWebVercel" "luca-web (submodule)" "from Goodway 更新 LucaWebVercel"
if errorlevel 1 goto FAIL

call :PUSH_REPO "D:\goodwaymis9527\LucaAWS" "luca-aws (submodule)" "from Goodway 更新 LucaAWS"
if errorlevel 1 goto FAIL

call :PUSH_REPO "D:\goodwaymis9527\LucaPython" "luca-python (submodule)" "from Goodway 更新 LucaPython"
if errorlevel 1 goto FAIL

call :PUSH_REPO "D:\goodwaymis9527" "GitHub Pages" "from Goodway 更新 goodwaymis9527"
if errorlevel 1 goto FAIL

echo.
rem 根目錄的 index.html 是 meta refresh 轉送頁，網站本體在 wwwHttps/ 子資料夾
echo ✔ GitHub 上線約 1 分鐘：https://goodwaymis9527.github.io/wwwHttps/  （根頁轉送到 /wwwHttps/）
echo ✔ luca-web（動態網頁 / Vercel）：https://github.com/goodwaymis9527/luca-web
echo ✔ luca-aws（正式區 / ECS Fargate）：https://github.com/goodwaymis9527/LucaAWS
echo ✔ luca-python（Python 版 / FastAPI + Docker）：https://github.com/goodwaymis9527/LucaPython
echo.
echo ✅ 全部完成！
echo ---
echo.

pause
exit /b

:PUSH_REPO
rem %~1 = 資料夾   %~2 = 顯示名稱   %~3 = commit 訊息
echo.
echo.
echo [Push] %~2
echo 資料夾：%~1
echo ---
echo 請稍候 ...
echo.

cd /d %~1 || (
    echo ❌ 進入資料夾失敗
    exit /b 1
)
echo.

rem ── 步驟 0：確認工作目錄無 merge 衝突標記 ──
git grep -nE "^(<<<<<<< |>>>>>>> )"
if not errorlevel 1 (
    echo ❌ 工作目錄偵測到 merge 衝突標記，請先解決再 push
    exit /b 1
)
echo ✔ 工作目錄無衝突標記
echo.

rem ── 步驟 1：暫存所有變更 ──
echo git add .
echo ---
git add .
if errorlevel 1 (
    echo ❌ git add 失敗
    exit /b 1
)
echo.

rem ── 步驟 2：暫存後再次掃描衝突標記 ──
git grep --cached -nE "^(<<<<<<< |>>>>>>> )"
if not errorlevel 1 (
    echo ❌ 偵測到 merge 衝突標記，請先解決再 push
    exit /b 1
)
echo ✔ 無衝突標記
echo.

rem ── 步驟 3：有變更才 commit ──
git diff --cached --quiet
if not errorlevel 1 goto NOCHANGE

echo 開始 commit ...
git commit -m "%~3"
if errorlevel 1 (
    echo ❌ commit 失敗
    exit /b 1
)
goto AFTERCOMMIT

:NOCHANGE
echo ⚠️ 沒有變更，不需要 commit

:AFTERCOMMIT
echo.

rem ── 步驟 4：push（別名 ph = push -u github main）──
echo git ph
echo ---
git ph
if errorlevel 1 (
    echo ❌ push 失敗（GitHub 需要 Personal Access Token；可能需要先 pull）
    exit /b 1
)
echo ✔ %~2 已 push
exit /b 0

:FAIL
echo.
echo ❌ 流程中止
echo ---
echo.
pause
exit /b 1
