@echo off
chcp 65001 >nul
title 修复 Nuitka jinja2 内联副本
echo ========================================
echo     修复 Nuitka jinja2 内联副本
echo ========================================
echo.

:: 获取 Nuitka 路径
for /f "delims=" %%i in ('python -c "import nuitka; import os; print(os.path.dirname(nuitka.__file__))"') do set NUITKA_PATH=%%i
echo Nuitka 路径: %NUITKA_PATH%

:: 获取 jinja2 路径
for /f "delims=" %%i in ('python -c "import jinja2; import os; print(os.path.dirname(jinja2.__file__))"') do set JINJA2_PATH=%%i
echo Jinja2 路径: %JINJA2_PATH%
echo.

:: 进入内联副本目录
set INLINE_COPY=%NUITKA_PATH%\build\inline_copy
if not exist "%INLINE_COPY%" (
    echo 错误: 找不到内联副本目录: %INLINE_COPY%
    pause
    exit /b 1
)

cd /d "%INLINE_COPY%"
echo 当前目录: %CD%
echo.

:: 备份并删除旧的 jinja2
if exist "jinja2" (
    echo 备份旧的 jinja2 到 jinja2_backup...
    if exist "jinja2_backup" rmdir /s /q jinja2_backup
    move jinja2 jinja2_backup
)

:: 创建符号链接
echo 创建符号链接指向系统 jinja2...
mklink /D jinja2 "%JINJA2_PATH%"

if %errorlevel% equ 0 (
    echo.
    echo 修复成功！现在可以重新运行 Nuitka 编译。
) else (
    echo.
    echo 修复失败！请检查是否有管理员权限。
)

echo.
pause