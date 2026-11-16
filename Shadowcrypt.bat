@echo off
title Shadow Crypt - Batch RPG
color 0A
setlocal enabledelayedexpansion

:init
set /a hp=100
set /a maxhp=100
set /a gold=20
set /a pots=2
set /a atk=15
set /a floor=1

:menu
cls
echo ==========================================
echo        SHADOW CRYPT - FLOOR %floor%
echo ==========================================
echo  HP: %hp%/%maxhp%   ATK: %atk%   Gold: %gold%   Potions: %pots%
echo ==========================================
echo.
echo  [1] Explore Deeper
echo  [2] Drink Health Potion (+40 HP)
echo  [3] Visit Merchant (Upgrade / Buy)
echo  [4] Quit Game
echo.
choice /c 1234 /n /m "Choose your action: "
if errorlevel 4 exit
if errorlevel 3 goto shop
if errorlevel 2 goto heal
if errorlevel 1 goto explore

:heal
if %pots% LEQ 0 (
    echo You have no potions left!
    pause
    goto menu
)
set /a pots-=1
set /a hp+=40
if %hp% GTR %maxhp% set /a hp=%maxhp%
echo You drank a potion and restored HP!
pause
goto menu

:shop
cls
echo === WANDERING MERCHANT ===
echo Gold: %gold%
echo [1] Health Potion (15 Gold)
echo [2] Sharpen Sword (+5 ATK) (30 Gold)
echo [3] Leave Shop
choice /c 123 /n /m "Buy: "
if errorlevel 3 goto menu
if errorlevel 2 (
    if %gold% GEQ 30 (
        set /a gold-=30
        set /a atk+=5
        echo Attack increased!
    ) else (
        echo Not enough gold!
    )
    pause
    goto shop
)
if errorlevel 1 (
    if %gold% GEQ 15 (
        set /a gold-=15
        set /a pots+=1
        echo Bought 1 Health Potion!
    ) else (
        echo Not enough gold!
    )
    pause
    goto shop
)

:explore
cls
set /a event=%random% %% 10 + 1
if %event% LEQ 6 goto battle
if %event% LEQ 8 goto treasure
goto trap

:treasure
set /a found=%random% %% 25 + 10
set /a gold+=%found%
set /a floor+=1
echo You found an unguarded chest containing %found% Gold!
pause
goto menu

:trap
set /a dmg=%random% %% 12 + 5
set /a hp-=%dmg%
set /a floor+=1
echo A spiked floor trap triggered! You took %dmg% damage.
if %hp% LEQ 0 goto gameover
pause
goto menu

:battle
set /a mhp=%floor% * 12 + 20
set /a matk=%floor% * 3 + 5
set /a mtype=%random% %% 3
if %mtype%==0 set mname=Crypt Skeleton
if %mtype%==1 set mname=Shadow Goblin
if %mtype%==2 set mname=Dungeon Slime

:fightloop
cls
echo === AMBUSHED BY %mname% ===
echo %mname% HP: %mhp%   ^|   Your HP: %hp%/%maxhp%
echo.
echo [1] Attack
echo [2] Use Potion (%pots% left)
echo [3] Flee
choice /c 123 /n /m "Action: "
if errorlevel 3 (
    echo You escaped back to safety!
    pause
    goto menu
)
if errorlevel 2 (
    if %pots% GTR 0 (
        set /a pots-=1
        set /a hp+=40
        if %hp% GTR %maxhp% set /a hp=%maxhp%
        echo Healed 40 HP!
    ) else (
        echo No potions left!
    )
    goto monsterturn
)
if errorlevel 1 (
    set /a dmg=%random% %% 8 + %atk%
    set /a mhp-=%dmg%
    echo You slash the %mname% for %dmg% damage!
)
if %mhp% LEQ 0 (
    set /a loot=%random% %% 20 + 10
    set /a gold+=%loot%
    set /a floor+=1
    echo You defeated the %mname% and found %loot% Gold!
    pause
    goto menu
)

:monsterturn
set /a mdmg=%random% %% 5 + %matk%
set /a hp-=%mdmg%
echo The %mname% hits you for %mdmg% damage!
if %hp% LEQ 0 goto gameover
pause
goto fightloop

:gameover
cls
echo ==========================================
echo               YOU HAVE DIED
echo         Reached Dungeon Floor: %floor%
echo ==========================================
pause
goto init
