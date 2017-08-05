#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "term.h"
#include <sys/timeb.h>
#include <stdint.h>
#include <signal.h>
#include "platform.h"
#include <stdio.h>
#include <unistd.h>

extern playerCharacter rogue;

static void gameLoop() {
	//register a JS handler to queue mouse & keyboard input
	EM_ASM(
		var origin = window.location.origin;
		window.keyOrMouseEvents = [];
		window.addEventListener('message', function(e){
			if(origin!==e.origin) return;
			window.keyOrMouseEvents.push(e.data);
		}, false);
	);
	rogueMain();
}

static void javascript_plotChar(uchar ch,
			  short xLoc, short yLoc,
			  short foreRed, short foreGreen, short foreBlue,
			  short backRed, short backGreen, short backBlue) {
    EM_ASM_({
	  if(!window.plotChars){
		  setTimeout(function(){
			  window.parent.postMessage(Object.values(window.plotChars), '*');
			  window.plotChars = null;
		  },0);
		  window.plotChars = {};
	  }
	  window.plotChars[($1<<8)+$2] = ([$0,$1,$2,$3,$4,$5,$6,$7,$8]);
    }, ch, xLoc, yLoc, foreRed, foreGreen, foreBlue, backRed, backGreen, backBlue);
}

static boolean javascript_pauseForMilliseconds(short milliseconds) {
    emscripten_sleep(milliseconds);
	return EM_ASM_INT({
		return Math.min(window.keyOrMouseEvents.length, 1);
	}, 0);
}

//Passing structs from JS is tricky. Instead of doing that JS simply calls the function below with the nextKeyOrMouseEvent
rogueEvent javascript_nextRogueEvent;
static void EMSCRIPTEN_KEEPALIVE javascript_receiveNextKeyOrMouseEvent(enum eventTypes eventType, signed long param1, signed long param2, boolean controlKey, boolean shiftKey) {
	if(eventType != NUMBER_OF_EVENT_TYPES){
		EM_ASM_({console.log($0,$1,$2,$3,$4);},eventType,param1,param2,controlKey,shiftKey);
	}
	javascript_nextRogueEvent.eventType = eventType;
	javascript_nextRogueEvent.param1 = param1;
	javascript_nextRogueEvent.param2 = param2;
	javascript_nextRogueEvent.controlKey = controlKey;
	javascript_nextRogueEvent.shiftKey = shiftKey;
}
static void javascript_nextKeyOrMouseEvent(rogueEvent *returnEvent, boolean textInput, boolean colorsDance) {
	if (noMenu && rogue.nextGame == NG_NOTHING) rogue.nextGame = NG_NEW_GAME;
	for (;;) {
		if (colorsDance) {
			shuffleTerrainColors(3, true);
			commitDraws();
		}
		EM_ASM_({
			var nxt = window.keyOrMouseEvents.shift();
			if(nxt){
				_javascript_receiveNextKeyOrMouseEvent.apply(null, nxt);
			} else {
				_javascript_receiveNextKeyOrMouseEvent($0, 0, 0, 0, 0);
			}
		}, NUMBER_OF_EVENT_TYPES);
		if(javascript_nextRogueEvent.eventType != NUMBER_OF_EVENT_TYPES){
			returnEvent->eventType = javascript_nextRogueEvent.eventType;
			returnEvent->param1 = javascript_nextRogueEvent.param1;
			returnEvent->param2 = javascript_nextRogueEvent.param2;
			returnEvent->controlKey = javascript_nextRogueEvent.controlKey;
			returnEvent->shiftKey = javascript_nextRogueEvent.shiftKey;
			return;
		}
		emscripten_sleep(50);
	}
}

static void javascript_remap(const char *input_name, const char *output_name) {

}

static boolean modifier_held(int modifier) {
	return 0;
}

struct brogueConsole javascriptConsole = {
	gameLoop,
	javascript_pauseForMilliseconds,
	javascript_nextKeyOrMouseEvent,
	javascript_plotChar,
	javascript_remap,
	modifier_held
};
#endif

