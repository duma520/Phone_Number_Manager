@echo off
chcp 65001 >nul
title 电话号码管理系统 Nuitka 编译脚本
echo ========================================
echo   电话号码管理系统 Nuitka 编译脚本
echo ========================================
echo.

:: 设置 Python 路径（如果使用虚拟环境，请取消注释并修改路径）
:: set PYTHONPATH=C:\path\to\your\venv\Scripts\python.exe

:: 清理之前的构建文件
echo [1/6] 清理之前的构建文件...
if exist "PhoneNumberManager.dist" rmdir /s /q "PhoneNumberManager.dist"
if exist "PhoneNumberManager.build" rmdir /s /q "PhoneNumberManager.build"
if exist "PhoneNumberManager.exe" del /f /q "PhoneNumberManager.exe"
if exist "PhoneNumberManager.onefile" rmdir /s /q "PhoneNumberManager.onefile"
echo 清理完成！
echo.

:: 检查必要文件
echo [2/6] 检查必要文件...
if not exist "PhoneNumberManager.py" (
    echo 错误: PhoneNumberManager.py 不存在！
    pause
    exit /b 1
)
if not exist "icon.ico" (
    echo 警告: icon.ico 不存在，将使用默认图标
)
if not exist "config.json" (
    echo 创建默认 config.json 文件...
    echo {} > config.json
)
echo 文件检查完成！
echo.

:: 创建临时目录存放资源文件
echo [3/6] 准备资源文件...
if not exist "resources" mkdir resources
if exist "icon.ico" copy /y "icon.ico" "resources\" >nul
if exist "config.json" copy /y "config.json" "resources\" >nul
if exist "phone_numbers.db" copy /y "phone_numbers.db" "resources\" >nul
echo 资源文件准备完成！
echo.

:: 开始 Nuitka 编译
echo [4/6] 开始 Nuitka 编译（这可能需要几分钟）...
echo.

nuitka ^
    --standalone ^
    --mingw64 ^
    --windows-console-mode=disable ^
    --windows-icon-from-ico=icon.ico ^
    --output-dir=build ^
    --enable-plugin=pyside6 ^
    --include-package=PySide6 ^
    --include-package=phonenumbers ^
    --include-package=folium ^
    --include-package=requests ^
    --include-package=phone ^
    --include-package=phone_iso3166 ^
    --include-module=PySide6.QtCharts ^
    --include-module=phonenumbers.carrier ^
    --include-module=phonenumbers.geocoder ^
    --include-module=phonenumbers.timezone ^
    --include-data-dir=resources=resources ^
    --include-data-file=icon.ico=icon.ico ^
    --include-data-file=config.json=config.json ^
    --include-data-file=phone_numbers.db=phone_numbers.db ^
    --jobs=%NUMBER_OF_PROCESSORS% ^
    --output-file=PhoneNumberManager.exe ^
    PhoneNumberManager.py

if %errorlevel% neq 0 (
    echo.
    echo 编译失败！错误代码: %errorlevel%
    pause
    exit /b %errorlevel%
)

echo.
echo [5/6] 编译成功！
echo.

:: 复制资源文件到输出目录
echo [6/6] 复制资源文件到输出目录...
if not exist "PhoneNumberManager.dist" mkdir "PhoneNumberManager.dist"
if exist "resources\icon.ico" copy /y "resources\icon.ico" "PhoneNumberManager.dist\" >nul
if exist "resources\config.json" copy /y "resources\config.json" "PhoneNumberManager.dist\" >nul
if exist "resources\phone_numbers.db" copy /y "resources\phone_numbers.db" "PhoneNumberManager.dist\" >nul

:: 复制 PySide6 需要的额外 DLL
echo 复制 PySide6 运行时文件...
if exist "C:\msys64\mingw64\bin\libwinpthread-1.dll" (
    copy /y "C:\msys64\mingw64\bin\libwinpthread-1.dll" "PhoneNumberManager.dist\" >nul 2>&1
)
if exist "C:\msys64\mingw64\bin\libgcc_s_seh-1.dll" (
    copy /y "C:\msys64\mingw64\bin\libgcc_s_seh-1.dll" "PhoneNumberManager.dist\" >nul 2>&1
)
if exist "C:\msys64\mingw64\bin\libstdc++-6.dll" (
    copy /y "C:\msys64\mingw64\bin\libstdc++-6.dll" "PhoneNumberManager.dist\" >nul 2>&1
)

:: 复制 Qt 平台插件
echo 复制 Qt 平台插件...
if exist "%CONDA_PREFIX%\Library\plugins\platforms" (
    xcopy /E /I /Y "%CONDA_PREFIX%\Library\plugins\platforms" "PhoneNumberManager.dist\platforms\" >nul
) else if exist "%VIRTUAL_ENV%\Lib\site-packages\PySide6\plugins\platforms" (
    xcopy /E /I /Y "%VIRTUAL_ENV%\Lib\site-packages\PySide6\plugins\platforms" "PhoneNumberManager.dist\platforms\" >nul
) else if exist "C:\Python311\Lib\site-packages\PySide6\plugins\platforms" (
    xcopy /E /I /Y "C:\Python311\Lib\site-packages\PySide6\plugins\platforms" "PhoneNumberManager.dist\platforms\" >nul
) else (
    echo 警告: 找不到 Qt 平台插件，可能需要手动复制
)

:: 复制 PySide6 的 Qt 库文件
echo 复制 PySide6 Qt 库文件...
if exist "%CONDA_PREFIX%\Library\bin" (
    copy /y "%CONDA_PREFIX%\Library\bin\Qt6Core.dll" "PhoneNumberManager.dist\" >nul 2>&1
    copy /y "%CONDA_PREFIX%\Library\bin\Qt6Gui.dll" "PhoneNumberManager.dist\" >nul 2>&1
    copy /y "%CONDA_PREFIX%\Library\bin\Qt6Widgets.dll" "PhoneNumberManager.dist\" >nul 2>&1
    copy /y "%CONDA_PREFIX%\Library\bin\Qt6Charts.dll" "PhoneNumberManager.dist\" >nul 2>&1
)

:: 创建启动脚本
echo @echo off > "PhoneNumberManager.dist\启动程序.bat"
echo start PhoneNumberManager.exe >> "PhoneNumberManager.dist\启动程序.bat"
echo echo 程序已启动，如果遇到问题请尝试以管理员身份运行 >> "PhoneNumberManager.dist\启动程序.bat"
echo pause >> "PhoneNumberManager.dist\启动程序.bat"

echo 资源文件复制完成！
echo.

:: 显示编译结果
echo ========================================
echo           编译完成！
echo ========================================
echo.
echo 输出目录: %CD%\PhoneNumberManager.dist
echo 可执行文件: PhoneNumberManager.exe
echo.
echo 文件列表:
dir "PhoneNumberManager.dist" /b
echo.
echo 总大小:
powershell -command "$s=Get-ChildItem -Recurse 'PhoneNumberManager.dist' | Measure-Object -Property Length -Sum; if ($s.Sum) {[math]::Round($s.Sum/1MB,2)} else {0}" | findstr /v "^$" && echo MB || echo 0 MB
echo.
echo 按任意键打开输出目录...
pause >nul

:: 打开输出目录
start "" "PhoneNumberManager.dist"