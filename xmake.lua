add_rules('mode.release', 'mode.debug')

add_requires('spdlog        1.15.3')
add_requires('elfio         3.12')
add_requires('nlohmann_json 3.12.0')
add_requires('dobby         2023.4.14')
add_requires('lame          3.100', {
    -- DictPen's buildroot exists lame v3.100,
    -- so we use it as a shared library.
    configs = {shared = true}
})
add_requires('libxcrypt     4.4.38', {
    configs = {shared = true}
})
add_requires("libwebp       1.3.0")
add_requires('librime       1.15.0')
package("ffmpeg")
    set_homepage("https://www.ffmpeg.org")
    set_description("FFmpeg 3.4.8 - Final version with cross-strip fix.")
    set_license("GPL-3.0")

    add_urls("https://ffmpeg.org/releases/ffmpeg-$(version).tar.bz2", {alias = "home"})
    -- 使用正确的 Hash
    add_versions("home:3.4.8", "904ddc5276ab605dd430c2981da55a2ceb67087eb186ce1bf47336a1a42719b4")

    add_links("avfilter", "avdevice", "avformat", "avcodec", "swscale", "swresample", "avutil")
    if is_plat("linux") then add_syslinks("dl", "pthread", "m") end

    on_install("linux", "macosx", "android", "iphoneos", function (package)
        import("package.tools.autoconf")
        local envs = autoconf.buildenvs(package)
        
        -- 1. 修复现代 glibc 缺失 sys/sysctl.h 问题
        if os.isfile("libavutil/cpu.c") then
            io.replace("libavutil/cpu.c", "#include <sys/sysctl.h>", "// #include <sys/sysctl.h>", {plain = true})
        end

        -- 2. 编译器环境准备 (Zig/AArch64)
        local cc = package:build_envs().CC or package:tool("cc")
        local cxx = package:build_envs().CXX or package:tool("cxx")
        local target_str = ""
        if cc:match("zig") then
            local arch = package:arch()
            if arch:match("arm64") or arch:match("aarch64") then
                target_str = "aarch64-linux-gnu.2.27"
            else
                target_str = arch .. "-linux-gnu"
            end
        end

        -- 3. 构建配置参数
        local configs = {
            "--prefix=" .. package:installdir(),
            "--enable-version3",
            "--disable-doc",
            "--disable-programs",
            "--disable-everything",
            "--enable-shared",
            "--disable-static",
            "--enable-gpl",
            "--disable-symver",
            
            -------------------------------------------------------------------
            -- 核心修正：指定正确的 Strip 工具
            -------------------------------------------------------------------
            "--strip=aarch64-linux-gnu-strip", 
            -- 或者也可以用 "--disable-stripping" 来彻底禁用它
            -------------------------------------------------------------------

            -- 解码器/格式支持 (全能版)
            "--enable-decoder=h264,hevc,vp8,vp9,mpeg4,mpeg2video,mjpeg,aac,mp3,opus,flac",
            "--enable-demuxer=mov,matroska,flv,mpegts,avi,mp3,ogg,wav,image2",
            "--enable-muxer=mp4,mov,matroska,flv,mpegts,mp3,ogg,wav",
            "--enable-parser=h264,hevc,vp8,vp9,mpeg4video,mpegaudio,aac,opus",
            "--enable-protocol=file,http,https,tcp,udp,rtp,pipe",
            "--enable-filter=scale,overlay,pad,crop",
        }

        -- 4. 编译器路径注入
        if target_str ~= "" then
            table.insert(configs, "--cc=" .. cc .. " -target " .. target_str)
            table.insert(configs, "--cxx=" .. cxx .. " -target " .. target_str)
        else
            table.insert(configs, "--cc=" .. cc)
            table.insert(configs, "--cxx=" .. cxx)
        end

        -- 5. 注入容错参数
        local cflags = "-Wno-incompatible-function-pointer-types"
        local ldflags = "-Wl,--undefined-version"
        if target_str ~= "" then
            cflags = cflags .. " -target " .. target_str
            ldflags = ldflags .. " -target " .. target_str
        end
        table.insert(configs, "--extra-cflags=" .. cflags)
        table.insert(configs, "--extra-ldflags=" .. ldflags)

        -- 6. 交叉编译处理
        if package:is_cross() then
            table.insert(configs, "--enable-cross-compile")
            local arch = package:targetarch()
            if arch:match("arm64") or arch:match("aarch64") then arch = "aarch64" end
            table.insert(configs, "--arch=" .. arch)
            table.insert(configs, "--target-os=linux")
        end

        -- 7. 执行安装
        os.vrunv("./configure", configs, {envs = envs})
        os.vrunv("make", {"-j" .. os.default_njob()})
        os.vrunv("make", {"install"})
    end)
package_end()
add_requires('ffmpeg        3.4.8', {
    configs = {shared = true}
})

--- options

option('qemu')
    set_default(false)
    set_showmenu(true)
    set_description('Enable build for QEMU.')
    add_defines('PL_QEMU')
option_end()

option('build-platform')
    set_default('YDP02X')
    set_showmenu(true)
    set_description('Enable build for specific devices.')
    set_values('YDP02X', 'YDPG3', 'YDP03X')
option_end()

option('target-channel')
    set_default('dev')
    set_showmenu(true)
    set_description('Tweak the compilation results in release.')
    set_values('dev', 'canary', 'beta', 'stable')
option_end()

--- global configs

set_license('GPL-3.0-only')

set_version('2.0.0')

set_allowedarchs('linux|arm64-v8a')

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

if is_mode('debug') then
    add_defines('PL_DEBUG')
end

if is_mode('release') then
    set_policy('build.optimization.lto', true)
end

--- targets

target('PenMods')
    add_rules('qt.shared')
    add_files('src/**.cpp')
    add_files('src/**.h')
    add_frameworks(
        'QtNetwork',
        'QtQuick',
        'QtQml',
        'QtGui',
        'QtMultimedia',
        'QtWebSockets',
        'QtSql')
    add_packages(
        'spdlog',
        'elfio',
        'nlohmann_json',
        'dobby',
        'lame',
        -- crypt, src/helper/ServiceManager.cpp
        'libxcrypt',
        'libwebp',
        'librime',
        'ffmpeg')
    set_pcxxheader('src/base/Base.h')
    add_includedirs(
        'src',
        'src/base',
        '$(builddir)/config')
    add_links(
        -- dladdr, src/common/util/System.cpp
        'dl')
    
    on_config(function (target) 
        target:add('defines', 'PL_BUILD_' .. get_config('build-platform'))
        target:add('defines', 'PL_' .. get_config('target-channel'):upper() .. '_CHANNEL')
    end)

    on_run(function(target)
        os.exec(('$(projectdir)/scripts/install.sh %s %s'):format(
            get_config('mode'),
            get_config('build-platform'))
        )
    end)

-- Externalized resource library target
target('PenModsResources')
    set_kind('shared')
    add_files('resource/externalize/**.cpp')
    add_includedirs('resource/models/YDP02X')

target('QrcExporter')
    add_rules('qt.shared')
    add_files('resource/exporter/**.cpp')
    add_packages(
        'spdlog',
        'dobby')
