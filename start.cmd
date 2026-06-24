@echo off
TITLE InCore II Running Minecraft: Pocket Edition
goto :main

:extract_bin
where tar >nul 2>nul
if errorlevel 1 (
	echo "[ERROR] Couldn't find tar.exe to extract bin.tar.gz."
	pause
	exit /b 1
)

if "%~1"=="replace" (
	rmdir /s /q "bin"
	if errorlevel 1 (
		echo "[ERROR] Failed to remove the old bin folder."
		pause
		exit /b 1
	)
)

tar -xzf "bin.tar.gz"
if errorlevel 1 (
	echo "[ERROR] Failed to extract bin.tar.gz."
	pause
	exit /b 1
)
if not exist "bin\" (
	echo "[ERROR] bin.tar.gz did not contain a bin folder."
	pause
	exit /b 1
)
exit /b 0

:missing_bin_archive
cls
echo "[ERROR] Current runtime is missing bin.tar.gz."
echo "[ERROR] Download bin.tar.gz from:"
echo "[ERROR] %BIN_DOWNLOAD_URL%"
echo "[ERROR] Password: 61td"
echo.
echo "[INFO] Please place bin.tar.gz in the same directory as this script."
echo "[INFO] Waiting for bin.tar.gz to appear..."
timeout /t 3 /nobreak >nul 2>nul
goto :missing_bin_archive

:main
cd /d %~dp0
set "BIN_DOWNLOAD_URL=https://khar.lanzouu.com/iJHtw3ruwjah"

if not exist "bin\" (
	if exist "bin.tar.gz" (
		echo "[INFO] bin folder not found. Extracting bin.tar.gz..."
		call :extract_bin
		if errorlevel 1 exit /b 1
		if not exist "bin\php\ext\ixed.*.win" (
			echo "[ERROR] bin.tar.gz did not contain the Windows SourceGuardian extension."
			pause
			exit /b 1
		)
	) else (
		goto :missing_bin_archive
	)
) else (
	if not exist "bin\php\ext\ixed.*.win" (
		echo "[WARN] Windows SourceGuardian extension not found in bin\php\ext."
		if exist "bin.tar.gz" (
			echo "[INFO] Replacing bin folder with bin.tar.gz..."
			call :extract_bin replace
			if errorlevel 1 exit /b 1
			if not exist "bin\php\ext\ixed.*.win" (
				echo "[ERROR] bin.tar.gz did not contain the Windows SourceGuardian extension."
				pause
				exit /b 1
			)
		) else (
			goto :missing_bin_archive
		)
	)
)

if exist bin\php\php.exe (
	set PHPRC=""
	set PHP_BINARY=bin\php\php.exe
) else (
	set PHP_BINARY=php
)

if exist Genisys*.phar (
	set POCKETMINE_FILE=Genisys*.phar
) else (
	if exist PocketMine-MP.phar (
		set POCKETMINE_FILE=PocketMine-MP.phar
	) else (
	    if exist src\pocketmine\PocketMine.php (
	        set POCKETMINE_FILE=src\pocketmine\PocketMine.php
		) else (
			if exist Genisys.phar (
				set POCKETMINE_FILE=Genisys.phar
			) else (
		        echo "[ERROR] Couldn't find a valid Genisys installation."
		        pause
		        exit 8
		    )
	    )
	)
)

if exist bin\mintty.exe (
	start "" bin\mintty.exe -o Columns=88 -o Rows=32 -o AllowBlinking=0 -o FontQuality=3 -o Font="Consolas" -o FontHeight=10 -o CursorType=0 -o CursorBlinks=1 -h error -t "Genisys" -w max %PHP_BINARY% %POCKETMINE_FILE% --enable-ansi %*
) else (
	%PHP_BINARY% -c bin\php %POCKETMINE_FILE% %*
)
