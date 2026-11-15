ffmpeg-player: skipped (set PENMODS_WITH_PLAYER=1 to build the embedded player plugin)
[0mchecking for platform ... [38;2;0;255;0;1mlinux[0m
[0mchecking for zig ... [38;2;0;255;0;1m/usr/bin/zig[0m
[0mchecking for git ... [38;2;0;255;0;1m/usr/bin/git[0m
[0mchecking for gzip ... [38;2;0;255;0;1m/usr/bin/gzip[0m
[0mchecking for tar ... [38;2;0;255;0;1m/usr/bin/tar[0m
/usr/bin/git rev-parse HEAD
[0m[38;2;255;255;0;1mcheckinfo: [0;2mcannot runv(nim --version), No such file or directory[0m
[0mchecking for nim ... [38;2;255;0;0;1mno[0m
[0mchecking for zig ... [38;2;0;255;0;1m/usr/bin/zig[0m
finding spdlog from xmake ..
[0mchecking for xmake::spdlog ... [38;2;0;255;0;1mspdlog v1.15.3[0m
[0mchecking for ninja ... [38;2;255;0;0;1mno[0m
[0mchecking for ninja ... [38;2;0;255;0;1m/usr/bin/ninja[0m
[0mchecking for cmake ... [38;2;255;0;0;1mno[0m
finding elfio from xmake ..
[0mchecking for xmake::elfio ... [38;2;0;255;0;1melfio 3.12[0m
finding nlohmann_json from xmake ..
[0mchecking for xmake::nlohmann_json ... [38;2;0;255;0;1mnlohmann_json v3.12.0[0m
finding dobby from xmake ..
[0mchecking for xmake::dobby ... [38;2;0;255;0;1mdobby 2023.4.14[0m
[0mchecking for nasm ... [38;2;255;0;0;1mno[0m
finding lame from xmake ..
[0mchecking for xmake::lame ... [38;2;0;255;0;1mlame 3.100[0m
finding libxcrypt from xmake ..
[0mchecking for xmake::libxcrypt ... [38;2;0;255;0;1mlibxcrypt 4.4.38[0m
finding libwebp from xmake ..
[0mchecking for xmake::libwebp ... [38;2;0;255;0;1mlibwebp v1.3.0[0m
finding gflags from xmake ..
[0mchecking for xmake::gflags ... [38;2;0;255;0;1mgflags v2.3.1[0m
finding glog from xmake ..
[0mchecking for xmake::glog ... [38;2;0;255;0;1mglog v0.7.1[0m
finding boost from xmake ..
[0mchecking for xmake::boost ... [38;2;0;255;0;1mboost 1.92.0[0m
finding snappy from xmake ..
[0mchecking for xmake::snappy ... [38;2;0;255;0;1msnappy 1.2.2[0m
finding leveldb from xmake ..
[0mchecking for xmake::leveldb ... [38;2;0;255;0;1mleveldb 1.23[0m
finding libffi from xmake ..
[0mchecking for xmake::libffi ... [38;2;255;0;0;1mno[0m
finding libffi-dev from apt ..
[0mchecking for dpkg ... [38;2;0;255;0;1m/usr/bin/dpkg[0m
[0mchecking for apt::libffi-dev ... [38;2;255;0;0;1mno[0m
finding libffi from pacman ..
[0mchecking for pacman ... [38;2;0;255;0;1m/usr/bin/pacman[0m
[0mchecking for pkg-config ... [38;2;0;255;0;1m/usr/bin/pkg-config[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/cc ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the c compiler (cc) ... [38;2;0;255;0;1mcc[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/cc ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> cc "-fPIC" "-target" "aarch64-linux-gnu.2.27"[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_5d86f93ea0a7682343e1d7094272e162.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the linker (ld) ... [38;2;0;255;0;1mc++[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> c++ "-fPIC" "-target" "aarch64-linux-gnu.2.27" "-target" "aarch64-linux-gnu.2.27"[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_5d86f93ea0a7682343e1d7094272e162.b /tmp/.xmake1000/261027/_5d86f93ea0a7682343e1d7094272e162.o -target aarch64-linux-gnu.2.27 -llibffi[0m
error: unable to find dynamic system library "libffi" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(libffi)[0m
[0m[2m> checking for c snippet(find_package/libffi)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_5d86f93ea0a7682343e1d7094272e162.b /tmp/.xmake1000/261027/_5d86f93ea0a7682343e1d7094272e162.o -target aarch64-linux-gnu.2.27 -llibffi) failed(1)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]: in function 'execv'
    [@programdir/modules/core/tools/gcc.lua:960]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]:
    [@programdir/core/tool/linker.lua:234]: in function 'link'
    [...gramdir/core/sandbox/modules/import/core/tool/linker.lua:73]: in function 'link'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:249]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:237]:
    [@programdir/modules/package/manager/system/find_package.lua:73]:
    [...amdir/modules/package/manager/pkgconfig/find_package.lua:50]:
    [@programdir/modules/package/manager/pacman/find_package.lua:202]:
    [@programdir/modules/package/manager/find_package.lua:112]: in function '_find_package'
    [@programdir/modules/package/manager/find_package.lua:196]:
    [@programdir/modules/lib/detect/find_package.lua:86]:
    [@programdir/core/package/package.lua:1963]: in function '_fetch_library'
    [@programdir/core/package/package.lua:2136]: in function 'fetch'
    [...modules/private/action/require/impl/install_packages.lua:354]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/async/runjobs.lua:190]: in function 'cotask'
    [@programdir/core/base/scheduler.lua:514]:
[0m
[0mchecking for pacman::libffi ... [38;2;0;255;0;1mlibffi 3.8.0[0m
finding zlib from xmake ..
[0mchecking for xmake::zlib ... [38;2;255;0;0;1mno[0m
finding z from system ..
[0mchecking for Cuda SDK directory ... [38;2;255;0;0;1mno[0m
[0m[38;2;255;255;0;1mcheckinfo: [0;2mcannot runv(nvc --version), No such file or directory[0m
[0mchecking for nvc ... [38;2;255;0;0;1mno[0m
[0m[2mchecking for the c compiler (cc: [1mnvc[0m) ... [38;2;255;0;0;1mno[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> cc "-fPIC"[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -o /tmp/.xmake1000/261027/_a9a36f92abb8ba7bb9b022a59bb88aab.o /tmp/.xmake1000/261027/_b4e120d90042ade80c9e2b93b1e38c3b.c[0m
[0mchecking for Cuda SDK directory ... [38;2;255;0;0;1mno[0m
[0m[38;2;255;255;0;1mcheckinfo: [0;2mcannot runv(nvc++ --version), No such file or directory[0m
[0mchecking for nvc++ ... [38;2;255;0;0;1mno[0m
[0m[2mchecking for the linker (ld: [1mnvc++[0m) ... [38;2;255;0;0;1mno[0m
[0mchecking for Cuda SDK directory ... [38;2;255;0;0;1mno[0m
[0m[38;2;255;255;0;1mcheckinfo: [0;2mcannot runv(nvc --version), No such file or directory[0m
[0mchecking for nvc ... [38;2;255;0;0;1mno[0m
[0m[2mchecking for the linker (ld: [1mnvc[0m) ... [38;2;255;0;0;1mno[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> c++ "-fPIC"[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_a9a36f92abb8ba7bb9b022a59bb88aab.b /tmp/.xmake1000/261027/_a9a36f92abb8ba7bb9b022a59bb88aab.o -lz[0m
[0m[2m> checking for c includes(zlib.h)[0m
[0m[2m> checking for c links(z)[0m
[0m[2m> checking for c snippet(find_package/z)[0m
[0mchecking for system::z ... [38;2;0;255;0;1mz [0m
[0mchecking for xmake-repo::zlib ... [38;2;0;255;0;1mzlib [0m
finding openssl from xmake ..
[0mchecking for xmake::openssl ... [38;2;255;0;0;1mno[0m
finding openssl from find_openssl ..
[0m[38;2;255;255;0;1mcheckinfo: [0;2mcannot runv(emerge --version), No such file or directory[0m
[0mchecking for emerge ... [38;2;255;0;0;1mno[0m
finding openssl from brew ..
[0mchecking for brew ... [38;2;255;0;0;1mno[0m
finding openssl from vcpkg ..
finding openssl from conan ..
finding openssl from pkgconfig ..
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -o /tmp/.xmake1000/261027/_65fccf09f724bb3ffa2de46f0d6c8db4.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_65fccf09f724bb3ffa2de46f0d6c8db4.b /tmp/.xmake1000/261027/_65fccf09f724bb3ffa2de46f0d6c8db4.o -lopenssl[0m
error: unable to find dynamic system library "openssl" using strategy paths_first. searched paths:
  /usr/local/lib/libopenssl.so
  /usr/local/lib/libopenssl.a
  /lib64/libopenssl.so
  /lib64/libopenssl.a
  /lib/libopenssl.so
  /lib/libopenssl.a
  /usr/lib64/libopenssl.so
  /usr/lib64/libopenssl.a
  /usr/lib/libopenssl.so
  /usr/lib/libopenssl.a
[0m[2m> checking for c links(openssl)[0m
[0m[2m> checking for c snippet(find_package/openssl)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_65fccf09f724bb3ffa2de46f0d6c8db4.b /tmp/.xmake1000/261027/_65fccf09f724bb3ffa2de46f0d6c8db4.o -lopenssl) failed(1)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]: in function 'execv'
    [@programdir/modules/core/tools/gcc.lua:960]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]:
    [@programdir/core/tool/linker.lua:234]: in function 'link'
    [...gramdir/core/sandbox/modules/import/core/tool/linker.lua:73]: in function 'link'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:249]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:237]:
    [@programdir/modules/package/manager/system/find_package.lua:73]:
    [...amdir/modules/package/manager/pkgconfig/find_package.lua:50]:
    [@programdir/modules/package/manager/find_package.lua:86]: in function '_find_package_with_builtin_rule'
    [@programdir/modules/package/manager/find_package.lua:132]: in function '_find_package'
    [@programdir/modules/package/manager/find_package.lua:196]:
    [@programdir/modules/lib/detect/find_package.lua:86]:
    [...ake/repositories/xmake-repo/packages/o/openssl/fetch.lua:37]:
    [@programdir/core/package/package.lua:1909]: in function '_fetch_library'
    [@programdir/core/package/package.lua:2136]: in function 'fetch'
    [...modules/private/action/require/impl/install_packages.lua:354]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/async/runjobs.lua:190]: in function 'cotask'
    [@programdir/core/base/scheduler.lua:514]:
[0m
[0mchecking for openssl ... [38;2;0;255;0;1mpkgconfig::openssl 3.6.5[0m
[0mchecking for xmake-repo::openssl ... [38;2;0;255;0;1mopenssl 3.6.5[0m
finding ca-certificates from xmake ..
[0mchecking for xmake::ca-certificates ... [38;2;255;0;0;1mno[0m
finding ca-certificates from brew ..
finding ca-certificates from vcpkg ..
finding ca-certificates from conan ..
finding ca-certificates from pkgconfig ..
finding ca-certificates from pacman ..
[0mchecking for ca-certificates ... [38;2;0;255;0;1mpacman::ca-certificates 20240618[0m
[0mchecking for python ... [38;2;255;0;0;1mno[0m
[0mchecking for python3 ... [38;2;255;0;0;1mno[0m
[0mchecking for python ... [38;2;255;0;0;1mno[0m
[0mchecking for python2 ... [38;2;255;0;0;1mno[0m
[0mchecking for python ... [38;2;255;0;0;1mno[0m
[0mchecking for python3 ... [38;2;0;255;0;1m/usr/bin/python3[0m
/usr/bin/python3 -c "import pip"
/usr/bin/python3 -c "import setuptools"
/usr/bin/python3 -c "import wheel"
[0mchecking for python ... [38;2;0;255;0;1m/usr/bin/python[0m
[0mchecking for pkg-config ... [38;2;255;0;0;1mno[0m
[0mchecking for pkg-config ... [38;2;0;255;0;1m/usr/bin/pkg-config[0m
finding marisa from xmake ..
[0mchecking for xmake::marisa ... [38;2;0;255;0;1mmarisa v0.2.6[0m
finding rapidjson from xmake ..
[0mchecking for xmake::rapidjson ... [38;2;0;255;0;1mrapidjson 2025.02.05[0m
finding tclap from xmake ..
[0mchecking for xmake::tclap ... [38;2;0;255;0;1mtclap v1.2.5[0m
finding darts from xmake ..
[0mchecking for xmake::darts ... [38;2;0;255;0;1mdarts 0.32[0m
finding marisa from xmake ..
[0mchecking for xmake::marisa ... [38;2;255;0;0;1mno[0m
finding marisa from brew ..
finding marisa from vcpkg ..
finding marisa from conan ..
finding marisa from pkgconfig ..
[0mchecking for /tmp/.xmake1000/261027/zigcc/cc ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the c compiler (cc) ... [38;2;0;255;0;1mcc[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_3229bde832aa8aed02531e62e148be08.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the linker (ld) ... [38;2;0;255;0;1mc++[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_3229bde832aa8aed02531e62e148be08.b /tmp/.xmake1000/261027/_3229bde832aa8aed02531e62e148be08.o -target aarch64-linux-gnu.2.27 -lmarisa[0m
error: unable to find dynamic system library "marisa" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(marisa)[0m
[0m[2m> checking for c snippet(find_package/marisa)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_3229bde832aa8aed02531e62e148be08.b /tmp/.xmake1000/261027/_3229bde832aa8aed02531e62e148be08.o -target aarch64-linux-gnu.2.27 -lmarisa) failed(1)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]: in function 'execv'
    [@programdir/modules/core/tools/gcc.lua:960]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]:
    [@programdir/core/tool/linker.lua:234]: in function 'link'
    [...gramdir/core/sandbox/modules/import/core/tool/linker.lua:73]: in function 'link'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:249]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:237]:
    [@programdir/modules/package/manager/system/find_package.lua:73]:
    [...amdir/modules/package/manager/pkgconfig/find_package.lua:50]:
    [@programdir/modules/package/manager/find_package.lua:86]: in function '_find_package_with_builtin_rule'
    [@programdir/modules/package/manager/find_package.lua:132]: in function '_find_package'
    [@programdir/modules/package/manager/find_package.lua:196]:
    [@programdir/modules/lib/detect/find_package.lua:86]:
    [@programdir/core/package/package.lua:1963]: in function '_fetch_library'
    [@programdir/core/package/package.lua:2136]: in function 'fetch'
    [...modules/private/action/require/impl/install_packages.lua:354]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/async/runjobs.lua:190]: in function 'cotask'
    [@programdir/core/base/scheduler.lua:514]:
[0m
[0mchecking for marisa ... [38;2;255;0;0;1mno[0m
finding rapidjson from xmake ..
[0mchecking for xmake::rapidjson ... [38;2;255;0;0;1mno[0m
finding rapidjson from brew ..
finding rapidjson from vcpkg ..
finding rapidjson from conan ..
finding rapidjson from pkgconfig ..
finding rapidjson from pacman ..
finding rapidjson from system ..
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_acf861ad691f8de62829f8dffb07bc30.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_acf861ad691f8de62829f8dffb07bc30.b /tmp/.xmake1000/261027/_acf861ad691f8de62829f8dffb07bc30.o -target aarch64-linux-gnu.2.27 -lrapidjson[0m
error: unable to find dynamic system library "rapidjson" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(rapidjson)[0m
[0m[2m> checking for c snippet(find_package/rapidjson)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_acf861ad691f8de62829f8dffb07bc30.b /tmp/.xmake1000/261027/_acf861ad691f8de62829f8dffb07bc30.o -target aarch64-linux-gnu.2.27 -lrapidjson) failed(1)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]: in function 'execv'
    [@programdir/modules/core/tools/gcc.lua:960]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]:
    [@programdir/core/tool/linker.lua:234]: in function 'link'
    [...gramdir/core/sandbox/modules/import/core/tool/linker.lua:73]: in function 'link'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:249]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:237]:
    [@programdir/modules/package/manager/system/find_package.lua:73]:
    [@programdir/modules/package/manager/find_package.lua:86]: in function '_find_package_with_builtin_rule'
    [@programdir/modules/package/manager/find_package.lua:132]: in function '_find_package'
    [@programdir/modules/package/manager/find_package.lua:196]:
    [@programdir/modules/lib/detect/find_package.lua:86]:
    [@programdir/core/package/package.lua:1963]: in function '_fetch_library'
    [@programdir/core/package/package.lua:2136]: in function 'fetch'
    [...modules/private/action/require/impl/install_packages.lua:354]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/async/runjobs.lua:190]: in function 'cotask'
    [@programdir/core/base/scheduler.lua:514]:
[0m
[0mchecking for rapidjson ... [38;2;255;0;0;1mno[0m
finding tclap from xmake ..
[0mchecking for xmake::tclap ... [38;2;255;0;0;1mno[0m
finding tclap from brew ..
finding tclap from vcpkg ..
finding tclap from conan ..
finding tclap from pkgconfig ..
finding tclap from pacman ..
finding tclap from system ..
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_b1be45a56b20687dece6e37daaf8463d.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_b1be45a56b20687dece6e37daaf8463d.b /tmp/.xmake1000/261027/_b1be45a56b20687dece6e37daaf8463d.o -target aarch64-linux-gnu.2.27 -ltclap[0m
error: unable to find dynamic system library "tclap" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(tclap)[0m
[0m[2m> checking for c snippet(find_package/tclap)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_b1be45a56b20687dece6e37daaf8463d.b /tmp/.xmake1000/261027/_b1be45a56b20687dece6e37daaf8463d.o -target aarch64-linux-gnu.2.27 -ltclap) failed(1)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]: in function 'execv'
    [@programdir/modules/core/tools/gcc.lua:960]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]:
    [@programdir/core/tool/linker.lua:234]: in function 'link'
    [...gramdir/core/sandbox/modules/import/core/tool/linker.lua:73]: in function 'link'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:249]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:237]:
    [@programdir/modules/package/manager/system/find_package.lua:73]:
    [@programdir/modules/package/manager/find_package.lua:86]: in function '_find_package_with_builtin_rule'
    [@programdir/modules/package/manager/find_package.lua:132]: in function '_find_package'
    [@programdir/modules/package/manager/find_package.lua:196]:
    [@programdir/modules/lib/detect/find_package.lua:86]:
    [@programdir/core/package/package.lua:1963]: in function '_fetch_library'
    [@programdir/core/package/package.lua:2136]: in function 'fetch'
    [...modules/private/action/require/impl/install_packages.lua:354]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/async/runjobs.lua:190]: in function 'cotask'
    [@programdir/core/base/scheduler.lua:514]:
[0m
[0mchecking for tclap ... [38;2;255;0;0;1mno[0m
finding darts from xmake ..
[0mchecking for xmake::darts ... [38;2;255;0;0;1mno[0m
finding darts from brew ..
finding darts from vcpkg ..
finding darts from conan ..
finding darts from pkgconfig ..
finding darts from pacman ..
finding darts from system ..
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_f38ac502ee3d27ea15be207d9d4ae25b.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_f38ac502ee3d27ea15be207d9d4ae25b.b /tmp/.xmake1000/261027/_f38ac502ee3d27ea15be207d9d4ae25b.o -target aarch64-linux-gnu.2.27 -ldarts[0m
error: unable to find dynamic system library "darts" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(darts)[0m
[0m[2m> checking for c snippet(find_package/darts)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_f38ac502ee3d27ea15be207d9d4ae25b.b /tmp/.xmake1000/261027/_f38ac502ee3d27ea15be207d9d4ae25b.o -target aarch64-linux-gnu.2.27 -ldarts) failed(1)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]: in function 'execv'
    [@programdir/modules/core/tools/gcc.lua:960]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]:
    [@programdir/core/tool/linker.lua:234]: in function 'link'
    [...gramdir/core/sandbox/modules/import/core/tool/linker.lua:73]: in function 'link'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:249]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/lib/detect/check_cxsnippets.lua:237]:
    [@programdir/modules/package/manager/system/find_package.lua:73]:
    [@programdir/modules/package/manager/find_package.lua:86]: in function '_find_package_with_builtin_rule'
    [@programdir/modules/package/manager/find_package.lua:132]: in function '_find_package'
    [@programdir/modules/package/manager/find_package.lua:196]:
    [@programdir/modules/lib/detect/find_package.lua:86]:
    [@programdir/core/package/package.lua:1963]: in function '_fetch_library'
    [@programdir/core/package/package.lua:2136]: in function 'fetch'
    [...modules/private/action/require/impl/install_packages.lua:354]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:
    [C]: in function 'xpcall'
    [@programdir/core/base/utils.lua:246]: in function 'trycall'
    [@programdir/core/sandbox/modules/try.lua:117]: in function 'try'
    [@programdir/modules/async/runjobs.lua:190]: in function 'cotask'
    [@programdir/core/base/scheduler.lua:514]:
[0m
[0mchecking for darts ... [38;2;255;0;0;1mno[0m
[0mchecking for opencc ... [38;2;255;0;0;1mno[0m
[0mchecking for opencc ... [38;2;0;255;0;1m/usr/bin/opencc[0m
finding opencc from xmake ..
[0mchecking for xmake::opencc ... [38;2;0;255;0;1mopencc 1.1.9[0m
finding yaml-cpp from xmake ..
[0mchecking for xmake::yaml-cpp ... [38;2;0;255;0;1myaml-cpp 0.8.0[0m
finding librime from xmake ..
[0mchecking for xmake::librime ... [38;2;0;255;0;1mlibrime 1.15.0[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the c++ compiler (cxx) ... [38;2;0;255;0;1mc++[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/ar ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the static library archiver (ar) ... [38;2;0;255;0;1mar[0m
[0mchecking for Qt SDK directory ... [38;2;0;255;0;1m/home/youran/Documents/git/PenMods/.toolchain[0m
[0mchecking for Qt SDK version ... [38;2;0;255;0;1m5.15.2[0m
[0mchecking for Qt SDK directory ... [38;2;0;255;0;1m/home/youran/Documents/git/PenMods/.toolchain[0m
[0mchecking for Qt SDK version ... [38;2;0;255;0;1m5.15.2[0m
[0m[2mgenerating src/mod/Version.h.in to build/config/Version.h ..[0m
  > replace VERSION_MAJOR -> 2
  > replace VERSION_MINOR -> 4
  > replace VERSION_ALTER -> 0
  > replace VERSION_MAJOR -> 2
  > replace VERSION_MINOR -> 4
  > replace VERSION_ALTER -> 0
  > replace MODE -> RELEASE
  > replace GIT_COMMIT -> 92b154b
[0mgenerating src/mod/Version.h.in ... [38;2;0;255;0;1mok[0m
configure
{
    force-debug-log = false
    ccache = true
    qt_sdkver = 5.15.2
    arch = arm64-v8a
    host = linux
    qemu = false
    ndk_stdcxx = true
    kind = static
    plat = linux
    clean = true
    toolchain = zig
    mode = release
    builddir = build
    build-platform = YDP03X
    qt = /home/youran/Documents/git/PenMods/.toolchain
    cross = aarch64-linux-gnu.2.27
    target-channel = dev
}
ffmpeg-player: skipped (set PENMODS_WITH_PLAYER=1 to build the embedded player plugin)
[0m[38;2;0;255;0;1m[  3%]:[0m cache compiling.release src/base/Base.h[0m
[0m[38;2;0;255;0;1m[ 50%]:[0m cache compiling.release src/base/SymDB.cpp[0m
[0m[38;2;0;255;0;1m[ 51%]:[0m cache compiling.release src/base/YPointer.cpp[0m
[0m[38;2;0;255;0;1m[ 51%]:[0m cache compiling.release src/capture/CameraCapture.cpp[0m
[0m[38;2;0;255;0;1m[ 52%]:[0m cache compiling.release src/chatbot/AttachmentManager.cpp[0m
[0m[38;2;0;255;0;1m[ 53%]:[0m cache compiling.release src/chatbot/MarkdownParser.cpp[0m
[0m[38;2;0;255;0;1m[ 54%]:[0m cache compiling.release src/chatbot/Backend.cpp[0m
[0m[38;2;0;255;0;1m[ 55%]:[0m cache compiling.release src/common/Downloader.cpp[0m
[0m[38;2;0;255;0;1m[ 56%]:[0m cache compiling.release src/common/Resource.cpp[0m
[0m[38;2;0;255;0;1m[ 56%]:[0m cache compiling.release src/common/service/Logger.cpp[0m
[0m[38;2;0;255;0;1m[ 57%]:[0m cache compiling.release src/common/util/System.cpp[0m
[0m[38;2;0;255;0;1m[ 58%]:[0m cache compiling.release src/common/Event.cpp[0m
[0m[38;2;0;255;0;1m[ 59%]:[0m cache compiling.release src/common/Utils.cpp[0m
[0m[38;2;0;255;0;1m[ 60%]:[0m cache compiling.release src/filemanager/player/ExternalPlayer.cpp[0m
[0m[38;2;0;255;0;1m[ 60%]:[0m cache compiling.release src/filemanager/player/MusicPlayer.cpp[0m
[0m[38;2;0;255;0;1m[ 61%]:[0m cache compiling.release src/filemanager/player/VideoPlayer.cpp[0m
[0m[38;2;0;255;0;1m[ 62%]:[0m cache compiling.release src/filemanager/reader/TextReader.cpp[0m
[0m[38;2;0;255;0;1m[ 63%]:[0m cache compiling.release src/filemanager/viewer/ImageViewer.cpp[0m
[0m[38;2;0;255;0;1m[ 64%]:[0m cache compiling.release src/filemanager/FileManager.cpp[0m
[0m[38;2;0;255;0;1m[ 64%]:[0m cache compiling.release src/helper/AntiEmbs.cpp[0m
[0m[38;2;0;255;0;1m[ 65%]:[0m cache compiling.release src/helper/DeveloperSettings.cpp[0m
[0m[38;2;0;255;0;1m[ 66%]:[0m cache compiling.release src/helper/NetworkSettings.cpp[0m
[0m[38;2;0;255;0;1m[ 67%]:[0m cache compiling.release src/helper/ServiceManager.cpp[0m
[0m[38;2;0;255;0;1m[ 68%]:[0m cache compiling.release src/hitokoto/Backend.cpp[0m
[0m[38;2;0;255;0;1m[ 69%]:[0m cache compiling.release src/locker/Locker.cpp[0m
[0m[38;2;0;255;0;1m[ 69%]:[0m cache compiling.release src/mod/Config.cpp[0m
[0m[38;2;0;255;0;1m[ 70%]:[0m cache compiling.release src/mod/Engine.cpp[0m
[0m[38;2;0;255;0;1m[ 71%]:[0m cache compiling.release src/mod/Mod.cpp[0m
[0m[38;2;0;255;0;1m[ 72%]:[0m cache compiling.release src/mod/Updater.cpp[0m
[0m[38;2;0;255;0;1m[ 73%]:[0m cache compiling.release src/plugin/QmlPluginWrapper.cpp[0m
[0m[38;2;0;255;0;1m[ 73%]:[0m cache compiling.release src/plugin/PluginManager.cpp[0m
[0m[38;2;0;255;0;1m[ 74%]:[0m cache compiling.release src/recorder/AudioRecorder.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/base/YPointer.cpp:7:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 75%]:[0m cache compiling.release src/rime/RimeWrapper.cpp[0m
[0m[38;2;0;255;0;1m[ 76%]:[0m cache compiling.release src/rime/Backend.cpp[0m
[0m[38;2;0;255;0;1m[ 77%]:[0m cache compiling.release src/shell/ShellExecutor.cpp[0m
[0m[38;2;0;255;0;1m[ 77%]:[0m cache compiling.release src/system/battery/BatteryInfo.cpp[0m
[0m[38;2;0;255;0;1m[ 78%]:[0m cache compiling.release src/system/input/InputDaemon.cpp[0m
[0m[38;2;0;255;0;1m[ 79%]:[0m cache compiling.release src/system/input/ScreenManager.cpp[0m
[0m[38;2;0;255;0;1m[ 80%]:[0m cache compiling.release src/system/sound/ASound.cpp[0m
[0m[38;2;0;255;0;1m[ 81%]:[0m cache compiling.release src/system/sound/AudioDaemon.cpp[0m
[0m[38;2;0;255;0;1m[ 82%]:[0m cache compiling.release src/torch/Torch.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/common/Downloader.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 82%]:[0m cache compiling.release src/tts/TtsWrapper.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/filemanager/player/ExternalPlayer.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 83%]:[0m cache compiling.release src/tweaker/EmulatorTweaks.cpp[0m
[0m[38;2;0;255;0;1m[ 84%]:[0m cache compiling.release src/tweaker/Features.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/common/Event.cpp:8:
In file included from src/system/input/ScreenManager.h:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];[0m
[0m[38;2;0;255;0;1m[ 85%]:[0m cache compiling.release src/tweaker/LoggerMonitor.cpp[0m
[0m[38;2;0;255;0;1m[ 86%]:[0m cache compiling.release src/tweaker/LrcTransMerger.cpp[0m
[0m[38;2;0;255;0;1m[ 86%]:[0m cache compiling.release src/tweaker/QueryTweaks.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/common/Utils.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 87%]:[0m cache compiling.release src/tweaker/ColumnDBLimiter.cpp[0m
[0m[38;2;0;255;0;1m[ 88%]:[0m cache compiling.release src/tweaker/KeyBoard.cpp[0m
[0m[38;2;0;255;0;1m[ 89%]:[0m cache compiling.release src/tweaker/TextBookHelper.cpp[0m
[0m[38;2;0;255;0;1m[ 90%]:[0m cache compiling.release src/tweaker/TouchCalibration.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/helper/AntiEmbs.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 90%]:[0m cache compiling.release src/tweaker/WordBookTweaks.cpp[0m
[0m[38;2;0;255;0;1m[ 91%]:[0m cache compiling.release src/wallpaper/WallpaperManager.cpp[0m
[0m[38;2;0;255;0;1m[ 92%]:[0m cache compiling.release src/dict/CustomDict.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/mod/Engine.cpp:24:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 93%]:[0m cache compiling.release src/media/MediaSession.cpp[0m
[0m[38;2;255;255;0;1mIn file included from src/mod/Mod.cpp:12:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1mIn file included from src/filemanager/player/MusicPlayer.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1msrc/filemanager/FileManager.cpp:664:14: warning: 'start' is deprecated: Use QProcess::start(const QString &program, const QStringList &arguments,OpenMode mode = ReadWrite) instead [-Wdeprecated-declarations]
  664 |     process->start(filePath);
      |              ^
/home/youran/Documents/git/PenMods/.toolchain/include/QtCore/qprocess.h:164:21: note: 'start' has been explicitly marked deprecated here
  164 |     __attribute__ ((__deprecated__("Use QProcess::start(const QString &program, const QStringList &arguments," "OpenMode mode = ReadWrite) instead")))
      |                     ^
1 warning generated.[0m
[0m[38;2;255;255;0;1mIn file included from src/mod/Updater.cpp:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1mIn file included from src/recorder/AudioRecorder.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1msrc/shell/ShellExecutor.cpp:174:24: warning: 'engine' is deprecated [-Wdeprecated-declarations]
  174 |             args << cb.engine()->toScriptValue(result);
      |                        ^
/home/youran/Documents/git/PenMods/.toolchain/include/QtQml/qjsvalue.h:153:21: note: 'engine' has been explicitly marked deprecated here
  153 |     __attribute__ ((__deprecated__)) QJSEngine *engine() const;
      |                     ^
src/shell/ShellExecutor.cpp:236:20: warning: 'engine' is deprecated [-Wdeprecated-declarations]
  236 |         args << cb.engine()->toScriptValue(result);
      |                    ^
/home/youran/Documents/git/PenMods/.toolchain/include/QtQml/qjsvalue.h:153:21: note: 'engine' has been explicitly marked deprecated here
  153 |     __attribute__ ((__deprecated__)) QJSEngine *engine() const;
      |                     ^
2 warnings generated.[0m
[0m[38;2;255;255;0;1mIn file included from src/system/input/InputDaemon.cpp:8:
In file included from src/system/input/ScreenManager.h:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];[0m
[0m[38;2;255;255;0;1mIn file included from src/system/input/ScreenManager.cpp:7:
In file included from src/system/input/ScreenManager.h:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];[0m
[0m[38;2;255;255;0;1mIn file included from src/system/sound/AudioDaemon.cpp:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1mIn file included from src/tts/TtsWrapper.cpp:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1mIn file included from src/tweaker/TextBookHelper.cpp:9:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1mIn file included from src/tweaker/KeyBoard.cpp:12:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;255;255;0;1mIn file included from src/tweaker/WordBookTweaks.cpp:10:
src/base/YPointer.h:47:10: warning: private field 'filler' is not used [-Wunused-private-field]
   47 |     char filler[0x20];
      |          ^
src/base/YPointer.h:51:10: warning: private field 'filler' is not used [-Wunused-private-field]
   51 |     char filler[0x30];
      |          ^
src/base/YPointer.h:55:10: warning: private field 'filler' is not used [-Wunused-private-field]
   55 |     char filler[0x28];
      |          ^
src/base/YPointer.h:59:10: warning: private field 'filler' is not used [-Wunused-private-field]
   59 |     char filler[0x40];
      |          ^
src/base/YPointer.h:63:10: warning: private field 'filler' is not used [-Wunused-private-field]
   63 |     char filler[0x28];
      |          ^[0m
[0m[38;2;0;255;0;1m[ 94%]:[0m [38;2;255;0;255;1mlinking.release libPenMods.so[0m
[0m[38;2;0;255;0;1m[100%]:[0m [38;2;0;255;0;1mbuild ok, spent 73.576s[0m
