/* PenMods Flutter host: runs a flutter-elinux bundle on the pen.
 *
 * Usage: penmods-flutter <bundle-dir> [width height] [dart args...]
 *
 * 宽高必须显式给出：传 0 0 会走 kFullscreen，在设备上先报 resource context
 * 错误再 segfault。一般在设备上用 800 480（全屏），让应用自己在内容带里排版。
 *
 * 第 4 个参数起原样透传给 Dart 的 main(List<String> args)，用来下发运行时
 * 约定（例如内容带 --band=<top>,<bottom>）。
 */
#include <locale.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <wchar.h>

#include "flutter_elinux.h"

#define PATH_MAX_ 4096

static wchar_t* to_w(const char* s) {
  size_t n = mbstowcs(NULL, s, 0);
  if (n == (size_t)-1) return NULL;
  wchar_t* w = (wchar_t*)calloc(n + 1, sizeof(wchar_t));
  if (w) mbstowcs(w, s, n + 1);
  return w;
}

int main(int argc, char** argv) {
  setlocale(LC_ALL, "");

  const char* bundle = argc > 1 ? argv[1] : ".";
  int width = argc > 3 ? atoi(argv[2]) : 0;
  int height = argc > 3 ? atoi(argv[3]) : 0;

  /* 第 4 个参数起透传给 Dart。指针直接指向 argv，生命周期覆盖整个 main。 */
  int dart_argc = argc > 4 ? argc - 4 : 0;
  const char** dart_argv = dart_argc > 0 ? (const char**)(argv + 4) : NULL;

  char assets[PATH_MAX_], icu[PATH_MAX_], aot[PATH_MAX_];
  snprintf(assets, sizeof assets, "%s/data/flutter_assets", bundle);
  snprintf(icu, sizeof icu, "%s/data/icudtl.dat", bundle);
  snprintf(aot, sizeof aot, "%s/lib/libapp.so", bundle);

  wchar_t* w_assets = to_w(assets);
  wchar_t* w_icu = to_w(icu);
  wchar_t* w_aot = to_w(aot);
  if (!w_assets || !w_icu || !w_aot) {
    fprintf(stderr, "penmods-flutter: path conversion failed\n");
    return 1;
  }

  FlutterDesktopEngineProperties ep;
  memset(&ep, 0, sizeof ep);
  ep.assets_path = w_assets;
  ep.icu_data_path = w_icu;
  ep.aot_library_path = w_aot;
  ep.dart_entrypoint_argc = dart_argc;
  ep.dart_entrypoint_argv = dart_argv;

  FlutterDesktopEngineRef engine = FlutterDesktopEngineCreate(&ep);
  if (!engine) {
    fprintf(stderr, "penmods-flutter: engine create failed (%s)\n", bundle);
    return 1;
  }

  FlutterDesktopViewProperties vp;
  memset(&vp, 0, sizeof vp);
  vp.width = width;
  vp.height = height;
  vp.view_mode = (width > 0 && height > 0) ? kNormalscreen : kFullscreen;
  vp.view_rotation = kRotation_0;
  vp.title = "PenMods App";
  vp.app_id = "penmods.app";
  vp.use_mouse_cursor = false;
  vp.use_onscreen_keyboard = false;
  vp.use_window_decoration = false;
  vp.text_scale_factor = 1.0;
  vp.enable_high_contrast = false;
  vp.force_scale_factor = false;
  vp.scale_factor = 1.0;
  vp.enable_vsync = true;

  FlutterDesktopViewControllerRef controller = FlutterDesktopViewControllerCreate(&vp, engine);
  if (!controller) {
    fprintf(stderr, "penmods-flutter: view controller create failed\n");
    return 1;
  }
  FlutterDesktopEngineRef e = FlutterDesktopViewControllerGetEngine(controller);
  FlutterDesktopViewRef v = FlutterDesktopViewControllerGetView(controller);

  while (FlutterDesktopViewDispatchEvent(v)) {
    uint64_t wait_ns = FlutterDesktopEngineProcessMessages(e);
    /* Never sleep longer than one frame: wayland events are dispatched inside
     * FlutterDesktopViewDispatchEvent(), so a long sleep delays input. */
    if (wait_ns == UINT64_MAX || wait_ns > 16000000ULL) wait_ns = 16000000ULL;
    struct timespec ts;
    ts.tv_sec = (time_t)(wait_ns / 1000000000ULL);
    ts.tv_nsec = (long)(wait_ns % 1000000000ULL);
    nanosleep(&ts, NULL);
  }

  FlutterDesktopViewControllerDestroy(controller);
  free(w_assets); free(w_icu); free(w_aot);
  return 0;
}
