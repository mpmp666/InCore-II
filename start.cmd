@echo off
TITLE Genisys server software for Minecraft: Pocket Edition
cd /d %~dp0

if not exist "bin\" (
	if exist "bin.tar.gz" (
		echo "[INFO] bin folder not found. Extracting bin.tar.gz..."
		where tar >nul 2>nul
		if errorlevel 1 (
			echo "[ERROR] Couldn't find tar.exe to extract bin.tar.gz."
			pause
			exit /b 1
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
