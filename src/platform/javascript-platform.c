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
	rogueMain();
}

static void javascript_plotChar(uchar ch,
			  short xLoc, short yLoc,
			  short foreRed, short foreGreen, short foreBlue,
			  short backRed, short backGreen, short backBlue) {
    EM_ASM_({
      window.parent.postMessage([$0, $1, $2, $3, $4, $5, $6, $7, $8], "*");
    }, ch, xLoc, yLoc, foreRed, foreGreen, foreBlue, backRed, backGreen, backBlue);
}

static boolean javascript_pauseForMilliseconds(short milliseconds) {
    emscripten_sleep(milliseconds);
    return false;  // TODO: return true if we have key/mouse events
}

static void javascript_nextKeyOrMouseEvent(rogueEvent *returnEvent, boolean textInput, boolean colorsDance) {
    return;
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

