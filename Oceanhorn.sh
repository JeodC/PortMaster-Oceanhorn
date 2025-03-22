#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/windows/oceanhorn"
EXEC="Oceanhorn.exe"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Display loading splash
$ESUDO $GAMEDIR/splash "splash.png" 30000 & 

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export WINEDEBUG=-all

# Determine architecture
if file "$GAMEDIR/data/$EXEC" | grep -q "PE32" && ! file "$GAMEDIR/data/$EXEC" | grep -q "PE32+"; then
    export WINEARCH=win32
    export WINEPREFIX=~/.wine32
elif file "$GAMEDIR/data/$EXEC" | grep -q "PE32+"; then
    export WINEPREFIX=~/.wine64
else
    echo "Unknown file format"
fi

# Run the game
$GPTOKEYB "$EXEC" -c "$GAMEDIR/oceanhorn.gptk" &
box64 wine "$GAMEDIR/data/$EXEC"

# Kill processes
wineserver -k
pm_finish