#!/bin/bash

# start.sh file for Genisys #
#
# Please input ./start.sh to start server #

# Variable define

DIR="$(cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "$DIR"

BIN_DOWNLOAD_URL="https://khar.lanzouu.com/iJHtw3ruwjah"

has_linux_sg_extension() {
	if [ ! -d ./bin/php7/lib/php/extensions ]; then
		return 1
	fi

	test -n "$(find ./bin/php7/lib/php/extensions -type f -name 'ixed.*.lin' -print -quit 2>/dev/null)"
}

print_missing_bin_archive() {
	echo "[ERROR] Current runtime is missing bin.tar.gz."
	echo "[ERROR] Download bin.tar.gz from:"
	echo "[ERROR] $BIN_DOWNLOAD_URL"
	echo "[ERROR] Password: 61td"
}

extract_bin_archive() {
	if ! command -v tar >/dev/null 2>&1; then
		echo "[ERROR] Couldn't find tar to extract bin.tar.gz."
		exit 1
	fi

	if [ "$1" = "replace" ]; then
		if ! rm -rf ./bin; then
			echo "[ERROR] Failed to remove the old bin folder."
			exit 1
		fi
	fi

	if ! tar -xzf ./bin.tar.gz; then
		echo "[ERROR] Failed to extract bin.tar.gz."
		exit 1
	fi

	if [ ! -d ./bin ]; then
		echo "[ERROR] bin.tar.gz did not contain a bin folder."
		exit 1
	fi
}

if [ ! -d ./bin ]; then
	if [ -f ./bin.tar.gz ]; then
		echo "[INFO] bin folder not found. Extracting bin.tar.gz..."
		extract_bin_archive
		if ! has_linux_sg_extension; then
			echo "[ERROR] bin.tar.gz did not contain the Linux SourceGuardian extension."
			exit 1
		fi
	fi
elif ! has_linux_sg_extension; then
	echo "[WARN] Linux SourceGuardian extension not found in ./bin/php7/lib/php/extensions."
	if [ -f ./bin.tar.gz ]; then
		echo "[INFO] Replacing bin folder with bin.tar.gz..."
		extract_bin_archive replace
		if ! has_linux_sg_extension; then
			echo "[ERROR] bin.tar.gz did not contain the Linux SourceGuardian extension."
			exit 1
		fi
	else
		print_missing_bin_archive
		exit 1
	fi
fi

if [ -f ./bin/php7/bin/php.ini ]; then
	PHP7_EXTENSION_DIR="$DIR/bin/php7/lib/php/extensions/no-debug-zts-20200930"
	if [ -d "$PHP7_EXTENSION_DIR" ]; then
		sed -i "s|^extension_dir=.*|extension_dir=$PHP7_EXTENSION_DIR|" ./bin/php7/bin/php.ini
	fi
fi

# Loop starting
# Do not edit without knowing what are you doing!

DO_LOOP="no"

###########################################
# DO NOT EDIT ANY THING BEHIND THIS LINE! #
###########################################

while getopts "p:f:l" OPTION 2> /dev/null; do
	case ${OPTION} in
		p)
			PHP_BINARY="$OPTARG"
			;;
		f)
			POCKETMINE_FILE="$OPTARG"
			;;
		l)
			DO_LOOP="yes"
			;;
		\?)
			break
			;;
	esac
done

if [ "$PHP_BINARY" == "" ]; then
	if [ -f ./bin/php7/bin/php ]; then
		export PHPRC=""
		PHP_BINARY="./bin/php7/bin/php"
	elif [ type php 2>/dev/null ]; then
		PHP_BINARY=$(type -p php)
	else
		echo "Couldn't find a working PHP binary, please use the installer."
		exit 1
	fi
fi

if [ "$POCKETMINE_FILE" == "" ]; then
	if [ -f ./PocketMine-iTX.phar ]; then
		POCKETMINE_FILE="./PocketMine-iTX.phar"
	elif [ -f ./InCore*.phar ]; then
	    POCKETMINE_FILE="./InCore*.phar"
	elif [ -f ./Genisys*.phar ]; then
	    POCKETMINE_FILE="./Genisys*.phar"
	elif [ -f ./PocketMine-MP.phar ]; then
		POCKETMINE_FILE="./PocketMine-MP.phar"
	elif [ -f ./src/pocketmine/PocketMine.php ]; then
		POCKETMINE_FILE="./src/pocketmine/PocketMine.php"
	else
		echo "Couldn't find a valid InCore installation"
		exit 1
	fi
fi

LOOPS=0

set +e
while [ "$LOOPS" -eq 0 ] || [ "$DO_LOOP" == "yes" ]; do
	if [ "$DO_LOOP" == "yes" ]; then
		"$PHP_BINARY" "$POCKETMINE_FILE" $@
	else
		exec "$PHP_BINARY" "$POCKETMINE_FILE" $@
	fi
	((LOOPS++))
done

if [ ${LOOPS} -gt 1 ]; then
	echo "Restarted $LOOPS times"
fi
