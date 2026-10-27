set_project('PenMods')
set_version('2.5.1')
set_license('GPL-3.0-only')
set_allowedarchs('linux|arm64-v8a')

add_rules('mode.release', 'mode.debug')

-- The libstdc++ that shipped with DictPen only supports c++14,
-- but we need more new language features.
-- The standard library combination used by PenMods:
--
--    (dynamic) glibc 2.27 + (static) libc++
--
-- !IMPORTANT! Please refer to the build guide to use the Zig toolchain
--             and specify correct triples to configure PenMods.
set_languages('cxx23', 'c11')

set_warnings('all')
set_exceptions('cxx')

set_configdir('$(builddir)/config')
add_configfiles('src/mod/Version.h.in')

includes('xmake/options.lua')
includes('xmake/packages.lua')

if is_mode('debug') or get_config('force-debug-log') then
    add_defines('PL_DEBUG')
end

if is_mode('release') then
    set_policy('build.optimization.lto', true)
end

includes('xmake/targets.lua')

-- 内嵌 FFmpeg 播放器插件（Haikure/ffmpeg-player，vendored 在 external/ffmpeg-player/）
-- 独立 target，产物 qml/FFmpegPlayer/{libffmpegplayerplugin.so,qmldir} 需单独部署：
--   scripts/deploy_ffmpeg_player.sh
includes('external/ffmpeg-player')
