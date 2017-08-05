
SDL_FLAGS = `sdl-config --cflags` `sdl-config --libs`
LIBTCODDIR=src/libtcod-1.5.2
CFLAGS=-Isrc/brogue -Isrc/platform -Wall -Wno-parentheses ${DEFINES}
RELEASENAME=brogue-1.7.4
LASTTARGET := $(shell ./brogue --target)
CC ?= gcc

ifeq (${LASTTARGET},both)
all : both
else ifeq (${LASTTARGET},curses)
all : curses
else ifeq (${LASTTARGET},tcod)
all : tcod
else
all : both
endif

%.o : %.c Makefile src/brogue/Rogue.h src/brogue/IncludeGlobals.h
	$(CC) $(CFLAGS) -g -o $@ -c $<

BROGUEFILES=src/brogue/Architect.o \
	src/brogue/Combat.o \
	src/brogue/Dijkstra.o \
	src/brogue/Globals.o \
	src/brogue/IO.o \
	src/brogue/Items.o \
	src/brogue/Light.o \
	src/brogue/Monsters.o \
	src/brogue/Buttons.o \
	src/brogue/Movement.o \
	src/brogue/Recordings.o \
	src/brogue/RogueMain.o \
	src/brogue/Random.o \
	src/brogue/MainMenu.o \
	src/brogue/Grid.o \
	src/brogue/Time.o \
	src/platform/main.o \
	src/platform/platformdependent.o \
	src/platform/curses-platform.o \
	src/platform/tcod-platform.o \
	src/platform/javascript-platform.o \
	src/platform/term.o

TCOD_DEF = -DBROGUE_TCOD -I$(LIBTCODDIR)/include
TCOD_DEP = ${LIBTCODDIR}
TCOD_LIB = -L. -L${LIBTCODDIR} ${SDL_FLAGS} -ltcod -Wl,-rpath,.

CURSES_DEF = -DBROGUE_CURSES
CURSES_LIB = -lncurses -lm

tcod : DEPENDENCIES += ${TCOD_DEP}
tcod : DEFINES += ${TCOD_DEF}
tcod : LIBRARIES += ${TCOD_LIB}

curses : DEFINES = ${CURSES_DEF}
curses : LIBRARIES = ${CURSES_LIB}

both : DEPENDENCIES += ${TCOD_DEP}
both : DEFINES += ${TCOD_DEF} ${CURSES_DEF}
both : LIBRARIES += ${TCOD_LIB} ${CURSES_LIB}

ifeq (${LASTTARGET},both)
both : bin/brogue
tcod : clean bin/brogue
curses : clean bin/brogue
else ifeq (${LASTTARGET},curses)
curses : bin/brogue
tcod : clean bin/brogue
both : clean bin/brogue
else ifeq (${LASTTARGET},tcod)
tcod : bin/brogue
curses : clean bin/brogue
both : clean bin/brogue
else
both : bin/brogue
curses : bin/brogue
tcod : bin/brogue
endif

javascript : clean bin/brogue

.PHONY : clean both curses tcod tar javascript

bin/brogue : ${DEPENDENCIES} ${BROGUEFILES}
	$(CC) -O2 -march=i586 -o bin/brogue.html -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1 -s EMTERPRETIFY_WHITELIST='["_OOSCheck", "_RNGCheck", "_abortAttackAgainstAcidicTarget", "_abortItemsAndMonsters", "_actionMenu", "_activateMachine", "_addMachines", "_addPoison", "_addXPXPToAlly", "_advanceToLocation", "_aggravateMonsters", "_animateFlares", "_apply", "_applyArmorRunicEffect", "_applyGradualTileEffectsToCreature", "_applyInstantTileEffectsToCreature", "_attack", "_autoIdentify", "_autoPlayLevel", "_autoRest", "_beckonMonster", "_becomeAllyWith", "_buildAMachine", "_burnItem", "_buttonInputLoop", "_call", "_checkForDisenchantment", "_checkForMissingKeys", "_checkNutrition", "_chooseTarget", "_clearCursorPath", "_cloneMonster", "_colorFlash", "_combatMessage", "_confirm", "_considerFlushingBufferToFile", "_controlKeyIsDown", "_copyFile", "_crystalize", "_decrementMonsterStatus", "_decrementWeaponAutoIDTimer", "_dequeueEvent", "_describeLocation", "_detonateBolt", "_dialogAlert", "_dialogChooseFile", "_digDungeon", "_discordBlast", "_discover", "_displayAnnotation", "_displayCombatText", "_displayInventory", "_displayLevel", "_displayMessageArchive", "_displayMonsterFlashes", "_displayMoreSign", "_displayRoute", "_drinkPotion", "_drop", "_dropItem", "_dumpScores", "_empowerMonster", "_enableEasyMode", "_equip", "_equipItem", "_executeEvent", "_executeKeystroke", "_executeMouseClick", "_executePlaybackInput", "_explore", "_exploreKey", "_exposeCreatureToFire", "_exposeTileToElectricity", "_exposeTileToFire", "_extinguishFireOnCreature", "_fadeInMonster", "_fclose", "_fileExists", "_fillBufferFromFile", "_fillSpawnMap", "_flashCreatureAlert", "_flashForeground", "_flashMessage", "_flashTemporaryAlert", "_flushBufferToFile", "_forceWeaponHit", "_freeCaptive", "_freeCaptivesEmbeddedAt", "_funkyFade", "_gameLoop", "_gameOver", "_generateItem", "_getAvailableFilePath", "_getCellAppearance", "_getExploreMap", "_getHighScoresList", "_getInputTextString", "_handleHealthAlerts", "_handleWhipAttacks", "_handleXPXP", "_haste", "_heal", "_hiliteCell", "_hilitePath", "_hiliteTrajectory", "_hitMonsterWithProjectileWeapon", "_imbueInvisibility", "_inflictDamage", "_inflictLethalDamage", "_initRecording", "_initScores", "_initializeLevel", "_initializeRogue", "_inscribeItem", "_itemAtLoc", "_javascript_nextKeyOrMouseEvent", "_javascript_pauseForMilliseconds", "_keyOnTileAt", "_killCreature", "_loadKeymap", "_loadNextAnnotation", "_loadSavedGame", "_loadScoreBuffer", "_magicWeaponHit", "_main", "_mainBrogueJunction", "_mainInputLoop", "_makeItemInto", "_makeMonsterDropItem", "_message", "_messageWithColor", "_messageWithoutCaps", "_monstUseBolt", "_monstUseMagic", "_monsterBlinkToPreferenceMap", "_monsterBlinkToSafety", "_monsterCastSpell", "_monsterEntersLevel", "_monsterMillAbout", "_monsterSummons", "_monstersApproachStairs", "_monstersFall", "_monstersTurn", "_moralAttack", "_moveCursor", "_negate", "_negationBlast", "_nextBrogueEvent", "_nextKeyOrMouseEvent", "_nextKeyPress", "_nextTargetAfter", "_numberOfMatchingPackItems", "_openFile", "_pathTowardCreature", "_pauseBrogue", "_pauseForMilliseconds", "_pausePlayback", "_perimeterCoords", "_pickUpItemAt", "_placeItem", "_playbackPanic", "_playerCancelsBlinking", "_polymorph", "_populateCreatureCostMap", "_populateItems", "_populateMonsters", "_printCarriedItemDetails", "_printDiscoveriesScreen", "_printFloorItemDetails", "_printHelpScreen", "_printHighScores", "_printItemInfo", "_printLocationDescription", "_printMonsterDetails", "_printMonsterInfo", "_printPlaybackHelpScreen", "_printSeed", "_printTextBox", "_processButtonInput", "_processIncrementalAutoID", "_promptForItemOfType", "_promptToAdvanceToLocation", "_proposeOrConfirmLocation", "_pullMouseClickDuringPlayback", "_readScroll", "_recallChar", "_recallEvent", "_recallNumber", "_rechargeItems", "_rechargeItemsIncrementally", "_reflectBolt", "_refreshSideBar", "_relabel", "_removeItemFrom", "_rogueMain", "_runAutogenerators", "_saveGame", "_saveHighScore", "_saveRecording", "_saveScoreBuffer", "_scum", "_search", "_slow", "_spawnDungeonFeature", "_spawnHorde", "_spawnMinions", "_spawnPeriodicHorde", "_specialHit", "_splitMonster", "_startFighting", "_startLevel", "_strengthCheck", "_summonGuardian", "_summonMinions", "_swapItemEnchants", "_swapItemToEnchantLevel", "_switchToPlaying", "_teleport", "_temporaryMessage", "_throwCommand", "_throwItem", "_titleMenu", "_toggleMonsterDormancy", "_travel", "_travelMap", "_travelRoute", "_tunnelize", "_unequip", "_unequipItem", "_unpause", "_useCharm", "_useKeyAt", "_useStaffOrWand", "_useStairs", "_victory", "_vomit", "_waitForAcknowledgment", "_waitForKeystrokeOrMouseClick", "_weaken", "_writeHeaderInfo", "_zap"]' ${BROGUEFILES} ${LIBRARIES} -Wl,-rpath,.

clean :
	rm -f src/brogue/*.o src/platform/*.o bin/brogue

${LIBTCODDIR} :
	src/get-libtcod.sh

tar : both
	rm -f ${RELEASENAME}.tar.gz
	tar --transform 's,^,${RELEASENAME}/,' -czf ${RELEASENAME}.tar.gz \
	Makefile \
	brogue \
	$(wildcard *.sh) \
	$(wildcard *.rtf) \
	readme \
	$(wildcard *.txt) \
	bin/brogue \
	bin/keymap \
	bin/icon.bmp \
	bin/brogue-icon.png \
	$(wildcard bin/fonts/*.png) \
	$(wildcard bin/*.so) \
	$(wildcard src/*.sh) \
	$(wildcard src/brogue/*.c) \
	$(wildcard src/brogue/*.h) \
	$(wildcard src/platform/*.c) \
	$(wildcard src/platform/*.h)

