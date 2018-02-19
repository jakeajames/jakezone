#!/bin/bash

IS_FAT() {
    target=$1
    unset ARCH
    isfat=$( (jtool -h $target | grep "Fat binary") 2>&1 ); 

    if [[ "$isfat" == *"Fat binary"* ]]; then
        echo  -n "YES"
    else
        echo -n "NO"
    fi
}

IS_SIGNED() {
    target=$1
    unset ARCH
    issign=$( (jtool --sig $target) 2>&1 ); 

    if [[ "$issign" == *"No Code Signing blob"* ]]; then
        echo  -n "NO"
    else
        echo -n "YES"
    fi
}


IS_MACHO() {
    target=$1
    export ARCH=arm64
    ismacho=$( (jtool -h $target | grep "Mach-O") 2>&1 ); 

    if [[ "$ismacho" == *"Mach-O"* ]]; then
        echo  -n "YES"
    else
        echo -n "NO"
    fi
}

THIN() {
    target=$1
    jtool -e arch -arch arm64 $target > /dev/null 2>&1
    mv "$target.arch_arm64" $target
}

HAS_ENTS() {
    target=$1
    ents=$( (jtool --ent $target) 2>&1)
    if [[ "$ents" == *"dict"* ]]; then
        if [[ "$ents" == *"platform-application"* ]]; then
             if [[ "$ents" == *"com.apple.private.skip-library-validation"* ]]; then
                 echo -n "PLATFORM-SKIP"
                 return 0
             else
                 echo -n "PLATFORM"
                 return 0
             fi
        fi
        if [[ "$ents" == *"com.apple.private.skip-library-validation"* ]]; then
            echo -n "SKIP"
        else
            echo -n "YES"
        fi
    else
        echo -n "NO"
    fi
}

APP_HAS_ENTS() {
    target=$1
    ents=$( (jtool --ent $target) 2>&1)
    if [[ "$ents" == *"dict"* ]]; then
        if [[ "$ents" == *"com.apple.private.security.no-container"* ]]; then
             if [[ "$ents" == *"com.apple.private.skip-library-validation"* ]]; then
                 if [[ "$ents" == *"platform-application"* ]]; then
                     echo -n "NO-C-SKIP-PLATFORM"
                     return 0
                 else
                     echo -n "NO-C-SKIP"
                     return 0
                 fi
             else
                 if [[ "$ents" == *"platform-application"* ]]; then
                     echo -n "NO-C-PLATFORM"
                     return 0
                 else
                     echo -n "NO-C"
                     return 0
                 fi
             fi
        fi
        if [[ "$ents" == *"com.apple.private.skip-library-validation"* ]]; then
            if [[ "$ents" == *"platform-application"* ]]; then
                echo -n "SKIP-PLATFORM"
                return 0
            else
                echo -n "SKIP"
                return 0
            fi
        fi
        if [[ "$ents" == *"platform-application"* ]]; then
             echo -n "PLATFORM"
        else
            echo -n "YES"
        fi
    else
        echo -n "NO"
    fi
}

UNSTASH() {
    target=$(find $1 -not -type d -type l -cmin -5 | grep -v "include" | grep -v "standalone" | grep -v "/Applications$")
    for bin in $target
    do
        if [[ "$(realpath $bin)" == "/var"* ]] || [[ "$(realpath $bin)" == "/private/var"* ]]; then #only stuff in /var needs unstashing
            REALPATH=$(realpath $bin)
            #unstashing symlinks doesn't make sense does it? 
            if [ ! -L $REALPATH ] && [ "$(IS_MACHO $REALPATH)" == "YES" ]; then #also make sure we're unstashing machos
               echo "[*] Unstasher: Unstashing $bin from $(realpath $bin)"
               #swap symlink with actual bin
               mv $REALPATH $bin
               ln -sf $bin $REALPATH
            fi
        fi
    done
}

PRINT_USAGE() {
    echo "Usage: "
    echo "    autoentitle <argument>"
    echo "Arguments: "
    echo "    - getlist: get list of recently installed binaries. Those will be the ones autoentitle will sign"
    echo "    - fix: entitle list of binaries"
    echo "    - trigger: Trigger automatic patching of binaries installed via Cydia"
    echo "    - untrigger: Disable automatic patching"
    echo "    - unstash <directory>: unstash recently installed binaries in a directory (10.3+; if any)"
    echo " Info: "
    echo "     every patched binary will get platform-application & skip-library-validation"
    echo "     every patched app will get platform-application, skip-library-validation & no-container"
    echo "     no entitlements will be lost"
    echo "     the 'fix' command will automatically unstash stashed binaries for you"
}

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games:/bootstrap/usr/bin:/bootstrap/bin:/bootstrap/usr/sbin:/bootstrap/bin:/bootstrap/usr/local/bin:'
USR=$(find /usr -not -type d -cmin -5 | grep -v "include" | grep -v "standalone")
APPS=$(find /Applications -maxdepth 1 -cmin -5 | head -n 2 | grep -v "/Applications$")
    

if [ "$#" -eq 0 ] || ([ ! "$1" == "getlist" ] && [ ! "$1" == "fix" ] && [ ! "$1" == "trigger" ] && [ ! "$1" == "untrigger" ] && [ ! "$1" == "unstash" ] && [ ! "$1" == "triggered" ]); then
    PRINT_USAGE
    exit 0
fi

if [ "$1" == "getlist" ]; then
   for usr in $USR 
    do
        echo "$usr"
    done

    for app in $APPS 
    do
        echo "$app"
    done
fi

if [ "$1" == "trigger" ]; then
    touch /var/mobile/Library/Preferences/autoentitle.enabled
fi

if [ "$1" == "untrigger" ]; then
    rm /var/mobile/Library/Preferences/autoentitle.enabled
fi

if [ "$1" == "triggered" ]; then
    if [ -f "/var/mobile/Library/Preferences/autoentitle.enabled" ]; then
        enable="YES"
    else
        enable="NO"
    fi
else 
    enable="NO"
fi

if [ "$1" == "unstash" ]; then
    if [ ! "$#" -eq 2 ]; then
         PRINT_USAGE
         exit 0
    fi
    UNSTASH $2
fi

if [ "$1" == "fix" ] || [ "$enable" == "YES" ]; then
    echo "[*] AutoEntitle: We got called..."
    UNSTASH /usr
    for bin in $USR
    do
        if [ ! -f $bin ]; then
            exit 0
        fi
        if [ "$bin" == "" ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi
        if [ "$bin" == "/" ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi
        if [ "$bin" == " " ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi

        if [ "$(IS_MACHO $bin)" == "YES" ]; then
            if [[ "$bin" == *"dylib" ]]; then
                if [ "$(IS_SIGNED $bin)" == "NO" ]; then
                    echo "[*] AutoEntitle: Processing $bin..."
                    if [ "$(IS_FAT $bin)" == "YES" ]; then
                        echo "[*] AutoEntitle: FAT binary, thinning..."
                        THIN $bin
                    fi
                    echo "[*] AutoEntitle: Signing..."
                    jtool --sign --inplace $bin > /dev/null 2>&1
                fi
                continue
            fi

            echo "[*] AutoEntitle: Processing $bin..."
            if [ "$(IS_FAT $bin)" == "YES" ]; then
                echo "[*] AutoEntitle: FAT binary, thinning..."
                THIN $bin
            fi
            if [ "$(HAS_ENTS $bin)" == "NO" ]; then
                echo "[*] AutoEntitle: Signing..."
                jtool --ent -arch arm64 /bootstrap/jailbreakd_client > /tmp/ENTS.xml
                sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml

                jtool --sign --inplace --ent /tmp/ENTS.xml $bin > /dev/null 2>&1

            elif [ "$(HAS_ENTS $bin)" == "YES" ]; then
                 echo "[*] AutoEntitle: Saving entitlements & signing...."
                 jtool --ent $bin > /tmp/ENTS.xml

                sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>platform-application<\/key><true\/><key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                jtool --sign --inplace --ent /tmp/ENTS.xml $bin > /dev/null 2>&1

            elif [ "$(HAS_ENTS $bin)" == "PLATFORM" ]; then
                 echo "[*] AutoEntitle: Saving entitlements & signing...."
                 jtool --ent $bin > /tmp/ENTS.xml

                sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                jtool --sign --inplace --ent /tmp/ENTS.xml $bin > /dev/null 2>&1

            elif [ "$(HAS_ENTS $bin)" == "SKIP" ]; then
                 echo "[*] AutoEntitle: Saving entitlements & signing...."
                 jtool --ent $bin > /tmp/ENTS.xml

                 sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>platform-application<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                 jtool --sign --inplace --ent /tmp/ENTS.xml $bin > /dev/null 2>&1

            elif [ "$(HAS_ENTS $bin)" == "PLATFORM-SKIP" ]; then
                 echo "[*] AutoEntitle: Already signed!"
            fi
            if [[ "$(grep setuid $bin)" == *"matches" ]]; then
                chown root $file
                chmod 6777 $file
            fi
        fi
    done

    for app in $APPS
    do

        if [ ! -d $app ]; then
            exit 0
        fi
        if [ "$app" == "" ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi
        if [ "$app" == "/" ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi
        if [ "$app" == " " ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi
        if [ "$app" == "/Applications" ]; then
            echo "[*] AutoEntitle: Not valid... exiting..."
            exit 0;
        fi

        echo "[*] AutoEntitle: Processing app $app"
        UNSTASH $app
        for file in $(find $app/ -cmin -5)
        do
            if [ "$(IS_MACHO $file)" == "YES" ]; then
                if [[ "$file" == *"dylib" ]]; then
                    if [ "$(IS_SIGNED $file)" == "NO" ]; then
                        echo "[*] AutoEntitle: Processing $bin..."
                        if [ "$(IS_FAT $file)" == "YES" ]; then
                            echo "[*] AutoEntitle: FAT binary, thinning..."
                            THIN $bin
                        fi
                    echo "[*] AutoEntitle: Signing..."
                    jtool --sign --inplace $bin > /dev/null 2>&1
                fi
                    continue
                fi
                echo "[*] AutoEntitle: Found app binary $file"
                if [ "$(IS_FAT $file)" == "YES" ]; then
                    echo "[*] AutoEntitle: FAT binary, thinning..."
                    THIN $file
                fi

                if [ "$(APP_HAS_ENTS $file)" == "NO" ]; then
                    echo "[*] AutoEntitle: Signing..."
                    jtool --ent -arch arm64 /Applications/Cydia.app/Cydia > /tmp/ENTS.xml
                    sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "YES" ]; then
                    echo "[*] AutoEntitle: Saving entitlements & signing..."
                    jtool --ent $file > /tmp/ENTS.xml
                    sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>platform-application<\/key><true\/><key>com.apple.private.security.no-container<\/key><true\/><key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "NO-C" ]; then
                    sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>platform-application<\/key><true\/><key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "NO-C-SKIP" ]; then
                    sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>platform-application<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "NO-C-PLATFORM" ]; then
                    sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "SKIP-PLATFORM" ]; then
                    sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>com.apple.private.security.no-container<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "SKIP" ]; then
                     sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>platform-application<\/key><true\/><key>com.apple.private.security.no-container<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "PLATFORM" ]; then
                     sed -i ':a;N;$!ba;s/<\/dict>\n<\/plist>/<key>com.apple.private.security.no-container<\/key><true\/><key>com.apple.private.skip-library-validation<\/key><true\/><\/dict>\n<\/plist>/g' /tmp/ENTS.xml
                    jtool --sign --inplace --ent /tmp/ENTS.xml $file > /dev/null 2>&1

                elif [ "$(APP_HAS_ENTS $file)" == "NO-C-SKIP-PLATFORM" ]; then
                    echo "[*] AutoEntitle: Already signed!"
                fi
                if [[ "$(grep setuid $file)" == *"matches" ]]; then
                    chown root $file
                    chmod 6777 $file
                fi
            fi
        done
    done
fi

rm /tmp/ENTS.xml > /dev/null 2>&1
exit 0
