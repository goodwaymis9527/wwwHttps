@echo off
chcp 65001 >nul
rem git 別名：pg = push -u origin main (Gitea) / ph = push -u github main (GitHub) / gp = pull --ff-only origin main

echo.
echo.

echo [1/1] Push D:\goodwaymis9527  (GitHub Pages)
echo ---
echo 請稍候 ...
echo.

cd /d D:\goodwaymis9527 || (
    echo ❌ 進入資料夾失敗
    pause
    exit /b
)
echo.

rem ── 步驟 0：確認工作目錄無 merge 衝突標記 ──
git grep -nE "^(<<<<<<< |>>>>>>> )"
if not errorlevel 1 (
    echo ❌ 工作目錄偵測到 merge 衝突標記，請先解決再 push
    pause
    exit /b
)
echo ✔ 工作目錄無衝突標記
echo.

rem ── 步驟 1：暫存所有變更 ──
echo git add .
echo ---
git add .
if errorlevel 1 (
    echo ❌ git add 失敗
    pause
    exit /b
)
echo.

rem ── 步驟 2：暫存後再次掃描衝突標記 ──
git grep --cached -nE "^(<<<<<<< |>>>>>>> )"
if not errorlevel 1 (
    echo ❌ 偵測到 merge 衝突標記，請先解決再 push
    pause
    exit /b
)
echo ✔ 無衝突標記
echo.

rem ── 步驟 3：有變更才 commit ──
git diff --cached --quiet
if not errorlevel 1 goto NOCHANGE

echo 開始 commit ...
git commit -m "from Goodway 更新 goodwaymis9527"
if errorlevel 1 (
    echo ❌ commit 失敗
    pause
    exit /b
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
    pause
    exit /b
)
echo.
echo ✔ GitHub 上線約 1 分鐘：https://goodwaymis9527.github.io/
echo.

echo ✅ 全部完成！
echo ---
echo.

pause