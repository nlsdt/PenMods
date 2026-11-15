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
[0mchecking for cmake ... [38;2;0;255;0;1m/usr/bin/cmake[0m
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_ce21a1241215b5cec438e9f6bb838b75.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the linker (ld) ... [38;2;0;255;0;1mc++[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> c++ "-fPIC" "-target" "aarch64-linux-gnu.2.27" "-target" "aarch64-linux-gnu.2.27"[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_ce21a1241215b5cec438e9f6bb838b75.b /tmp/.xmake1000/261027/_ce21a1241215b5cec438e9f6bb838b75.o -target aarch64-linux-gnu.2.27 -llibffi[0m
error: unable to find dynamic system library "libffi" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(libffi)[0m
[0m[2m> checking for c snippet(find_package/libffi)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_ce21a1241215b5cec438e9f6bb838b75.b /tmp/.xmake1000/261027/_ce21a1241215b5cec438e9f6bb838b75.o -target aarch64-linux-gnu.2.27 -llibffi) failed(1)
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -o /tmp/.xmake1000/261027/_e12354adb3e059f5d59c331bd83b803b.o /tmp/.xmake1000/261027/_b4e120d90042ade80c9e2b93b1e38c3b.c[0m
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_e12354adb3e059f5d59c331bd83b803b.b /tmp/.xmake1000/261027/_e12354adb3e059f5d59c331bd83b803b.o -lz[0m
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -o /tmp/.xmake1000/261027/_e889a2f85099cf077f567c820373c063.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_e889a2f85099cf077f567c820373c063.b /tmp/.xmake1000/261027/_e889a2f85099cf077f567c820373c063.o -lopenssl[0m
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
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_e889a2f85099cf077f567c820373c063.b /tmp/.xmake1000/261027/_e889a2f85099cf077f567c820373c063.o -lopenssl) failed(1)
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_2c4f2b8349476d81f1295c29e28343ef.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the linker (ld) ... [38;2;0;255;0;1mc++[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_2c4f2b8349476d81f1295c29e28343ef.b /tmp/.xmake1000/261027/_2c4f2b8349476d81f1295c29e28343ef.o -target aarch64-linux-gnu.2.27 -lmarisa[0m
error: unable to find dynamic system library "marisa" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(marisa)[0m
[0m[2m> checking for c snippet(find_package/marisa)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_2c4f2b8349476d81f1295c29e28343ef.b /tmp/.xmake1000/261027/_2c4f2b8349476d81f1295c29e28343ef.o -target aarch64-linux-gnu.2.27 -lmarisa) failed(1)
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_77409700ec902270f491387ebb0c22d5.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_77409700ec902270f491387ebb0c22d5.b /tmp/.xmake1000/261027/_77409700ec902270f491387ebb0c22d5.o -target aarch64-linux-gnu.2.27 -lrapidjson[0m
error: unable to find dynamic system library "rapidjson" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(rapidjson)[0m
[0m[2m> checking for c snippet(find_package/rapidjson)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_77409700ec902270f491387ebb0c22d5.b /tmp/.xmake1000/261027/_77409700ec902270f491387ebb0c22d5.o -target aarch64-linux-gnu.2.27 -lrapidjson) failed(1)
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_765afa9202fac79443758ad7bc91d4ed.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_765afa9202fac79443758ad7bc91d4ed.b /tmp/.xmake1000/261027/_765afa9202fac79443758ad7bc91d4ed.o -target aarch64-linux-gnu.2.27 -ltclap[0m
error: unable to find dynamic system library "tclap" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(tclap)[0m
[0m[2m> checking for c snippet(find_package/tclap)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_765afa9202fac79443758ad7bc91d4ed.b /tmp/.xmake1000/261027/_765afa9202fac79443758ad7bc91d4ed.o -target aarch64-linux-gnu.2.27 -ltclap) failed(1)
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
[0m[2m> /tmp/.xmake1000/261027/zigcc/cc -c -target aarch64-linux-gnu.2.27 -o /tmp/.xmake1000/261027/_2b43b558092f1e9386e7c59b01547f62.o /tmp/.xmake1000/261027/_5c2289377258fd5de3785c74a50568f0.c[0m
[0m[2m> /tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_2b43b558092f1e9386e7c59b01547f62.b /tmp/.xmake1000/261027/_2b43b558092f1e9386e7c59b01547f62.o -target aarch64-linux-gnu.2.27 -ldarts[0m
error: unable to find dynamic system library "darts" using strategy paths_first. searched paths: none
[0m[2m> checking for c links(darts)[0m
[0m[2m> checking for c snippet(find_package/darts)[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m ...gramdir/core/sandbox/modules/import/core/tool/linker.lua:75: @programdir/core/sandbox/modules/os.lua:378: execv(/tmp/.xmake1000/261027/zigcc/c++ -o /tmp/.xmake1000/261027/_2b43b558092f1e9386e7c59b01547f62.b /tmp/.xmake1000/261027/_2b43b558092f1e9386e7c59b01547f62.o -target aarch64-linux-gnu.2.27 -ldarts) failed(1)
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
[0mchecking for xmake::opencc ... [38;2;255;0;0;1mno[0m
finding opencc from vcpkg ..
finding opencc from conan ..
[0mchecking for opencc ... [38;2;255;0;0;1mno[0m
finding yaml-cpp from xmake ..
[0mchecking for xmake::yaml-cpp ... [38;2;255;0;0;1mno[0m
finding yaml-cpp from vcpkg ..
finding yaml-cpp from conan ..
[0mchecking for yaml-cpp ... [38;2;255;0;0;1mno[0m
finding librime from xmake ..
[0mchecking for xmake::librime ... [38;2;255;0;0;1mno[0m
finding librime from vcpkg ..
finding librime from conan ..
[0mchecking for librime ... [38;2;255;0;0;1mno[0m
[0mchecking for curl ... [38;2;0;255;0;1m/usr/bin/curl[0m
pinging the host(github.com) ... 281 ms
/usr/bin/tar -xf /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/opencc-1.1.9.tar.gz -C source.tmp
[0mchecking for ninja ... [38;2;0;255;0;1m/usr/bin/ninja[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the c++ compiler (cxx) ... [38;2;0;255;0;1mc++[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/cc ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the assember (as) ... [38;2;0;255;0;1mcc[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/ar ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the static library archiver (ar) ... [38;2;0;255;0;1mar[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/ranlib ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the archive index generator (ranlib) ... [38;2;0;255;0;1mranlib[0m
[0mchecking for cmake ... [38;2;0;255;0;1m/usr/bin/cmake[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> c++ "-fPIC" "-target" "aarch64-linux-gnu.2.27"[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;255;0;0;1mno[0m
[0m[2m> cc "-fPIC" "-target" "aarch64-linux-gnu.2.27"[0m
[0m[38;2;255;255;0;1mcheckinfo:[0;2m @programdir/core/sandbox/modules/os.lua:273: zig: warning: /tmp/.xmake1000/261027/_2a7e76d59053356cf2af8607292efff3.s: 'assembler' input unused [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-fno-PIE' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-fPIC' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-gdwarf-4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-gdwarf32' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-cpu' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas generic' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -a320' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -addr-lsl-slow-14' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -aes' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -aggressive-fma' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -aggressive-interleaving' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -alternate-sextload-cvt-f32-pattern' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -altnzcv' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -alu-lsl-fast' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -am' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -amvs' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -arith-bcc-fusion' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -arith-cbz-fusion' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ascend-store-address' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -avoid-ldapur' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -balance-fp-ops' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -bf16' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -brbe' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -bti' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -btie' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x10' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x11' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x12' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x13' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x14' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x15' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x18' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x8' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -call-saved-x9' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ccdp' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ccidx' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ccpp' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -chk' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -clrbhb' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -cmh' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -cmp-bcc-fusion' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -cmpbr' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -complxnum' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -CONTEXTIDREL2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -cpa' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -crc' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -crypto' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -cssc' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -d128' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -disable-fast-inc-vl' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -disable-latency-sched-heuristic' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -disable-ldp' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -disable-maximize-scalable-bandwidth' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -disable-stp' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -disable-unpredicated-ld-st-lower' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -dit' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -dotprod' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ecv' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -el2vmsa' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -el3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +enable-select-opt' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +ete' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -execute-only' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -exynos-cheap-as-move' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f16f32dot' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f16f32mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f16mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f32mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f64mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f8f16mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -f8f32mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -faminmax' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fgt' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fix-cortex-a53-835769' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -flagm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fmv' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -force-32bit-jump-tables' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fp16fml' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fp8' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fp8dot2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fp8dot4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fp8fma' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +fp-armv8' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fpac' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fprcvt' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fptoint' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fujitsu-monaka' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fullfp16' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-address' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-addsub-2reg-const1' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +fuse-adrp-add' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +fuse-aes' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-arith-logic' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-crypto-eor' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-csel' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-cset' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -fuse-literals' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -gcie' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -gcs' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -harden-sls-blr' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -harden-sls-nocomdat' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -harden-sls-retbr' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -hbc' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -hcx' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -i8mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ite' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -jsconv' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ldp-aligned-only' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lor' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ls64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lscp' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lse' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lse128' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lse2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lsfe' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lsui' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -lut' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -max-interleave-factor-4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mec' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mops' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mops-go' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mpam' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mpamv2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mte' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -mtetc' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +neon' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -nmi' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -no-bti-at-return-twice' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -no-neg-immediates' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -no-sve-fp-ld1r' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -no-zcz-fpr64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -nv' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -occmo' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -olympus' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -outline-atomics' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -pan' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -pan-rwv' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -pauth' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -pauth-lr' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -pcdphint' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -perfmon' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -poe2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -pops' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -predictable-select-expensive' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -predres' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -prfm-slc-target' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rand' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ras' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rasv2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rcpc' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rcpc3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rcpc-immo' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rdm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-lr-for-ra' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x1' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x10' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x11' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x12' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x13' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x14' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x15' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x18' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x20' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x21' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x22' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x23' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x24' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x25' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x26' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x27' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x28' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x5' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x6' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x7' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -reserve-x9' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -rme' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sb' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sel2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sha2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sha3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -slow-misaligned-128store' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -slow-paired-128' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -slow-strqro-store' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sm4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme2p1' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme2p2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme2p3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-b16b16' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-f16f16' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-f64f64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-f8f16' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-f8f32' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-fa64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-i16i64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-lutv2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-mop4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sme-tmop' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -spe' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -spe-eef' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -specres2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -specrestrict' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssbs' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssve-aes' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssve-bitperm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssve-fexpa' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssve-fp8dot2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssve-fp8dot4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -ssve-fp8fma' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -store-pair-suppress' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -stp-aligned-only' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -strict-align' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2-aes' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2-bitperm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2-sha3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2-sm4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2p1' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2p2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve2p3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-aes' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-aes2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-b16b16' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-b16mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-bfscale' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-bitperm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-f16f32mm' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-sha3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -sve-sm4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tagged-globals' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tev' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -the' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tlb-rmi' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tlbid' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tlbiw' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tpidr-el1' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tpidr-el2' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tpidr-el3' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tpidrro-el0' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -tracev8.4' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +trbe' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -uaops' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -use-experimental-zeroing-pseudos' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -use-fixed-over-scalable-if-equal-cost' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas +use-postra-scheduler' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -use-reciprocal-square-root' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -use-wzr-to-vec-move' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.1a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.2a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.3a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.4a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.5a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.6a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.7a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.8a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8.9a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v8r' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.1a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.2a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.3a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.4a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.5a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.6a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9.7a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -v9a' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -vh' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -wfxt' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -xs' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcm-fpr128' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcm-fpr32' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcm-fpr64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcm-gpr32' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcm-gpr64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcz-fp-workaround' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcz-fpr128' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcz-gpr32' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -target-feature' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-Xclangas -zcz-gpr64' [-Wunused-command-line-argument]
zig: warning: argument unused during compilation: '-c' [-Wunused-command-line-argument]
/tmp/.xmake1000/261027/_2a7e76d59053356cf2af8607292efff3.s:1:1: error: failed to rename 'tmp/cffcb59abb650d5a-_2a7e76d59053356cf2af8607292efff3.s' into '/home/youran/Documents/git/PenMods/.toolchain/zig-cache//o/e77b23ab17f7aff6b3321c5b25f0c054/_2a7e76d59053356cf2af8607292efff3.s': FileNotFound

stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:273]: in function 'runv'
    [@programdir/modules/core/tools/gcc/has_flags.lua:43]:[0m
[0mchecking for /tmp/.xmake1000/261027/zigcc/c++ ... [38;2;0;255;0;1mok[0m
[0m[2mchecking for the shared library linker (sh) ... [38;2;0;255;0;1mc++[0m
[0m[2mchecking for flags ([0m-fPIC[0m[2m) ... [38;2;0;255;0;1mok[0m
[0m[2m> c++ "-fPIC" "-shared" "-target" "aarch64-linux-gnu.2.27" "-target" "aarch64-linux-gnu.2.27"[0m
/usr/bin/cmake -DBUILD_DOCUMENTATION=OFF -DENABLE_GTEST=OFF -DENABLE_BENCHMARK=OFF -DBUILD_PYTHON=OFF -DUSE_SYSTEM_DARTS=ON -DUSE_SYSTEM_RAPIDJSON=ON -DUSE_SYSTEM_TCLAP=ON -DUSE_SYSTEM_MARISA=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DENABLE_DARTS=ON -DCMAKE_INSTALL_PREFIX=/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb -DCMAKE_INSTALL_LIBDIR:PATH=lib -G Ninja -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja -DCMAKE_C_LINKER_DEPFILE_SUPPORTED=FALSE -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_LINKER_DEPFILE_SUPPORTED=FALSE -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH -DHAVE_FLAG_SEARCH_PATHS_FIRST=0 -DCMAKE_SYSTEM_PROCESSOR=arm64-v8a -DCMAKE_AR=/tmp/.xmake1000/261027/zigcc/ar -DCMAKE_FIND_USE_INSTALL_PREFIX=0 -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_CXX_COMPILER=/tmp/.xmake1000/261027/zigcc/c++ -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=0 -DCMAKE_C_COMPILER=/tmp/.xmake1000/261027/zigcc/cc -DCMAKE_ASM_COMPILER=/tmp/.xmake1000/261027/zigcc/cc -DCMAKE_RANLIB=/tmp/.xmake1000/261027/zigcc/ranlib -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_OSX_SYSROOT= -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_STATIC_LINKER_FLAGS_RELEASE= "-DCMAKE_SHARED_LINKER_FLAGS= -target aarch64-linux-gnu.2.27" "-DCMAKE_CXX_FLAGS= -target aarch64-linux-gnu.2.27" "-DCMAKE_MODULE_LINKER_FLAGS=  -target aarch64-linux-gnu.2.27" -DCMAKE_SHARED_LINKER_FLAGS_RELEASE= -DCMAKE_STATIC_LINKER_FLAGS= "-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DNDEBUG" "-DCMAKE_ASM_FLAGS=  -target aarch64-linux-gnu.2.27" "-DCMAKE_C_FLAGS_RELEASE=-O3 -DNDEBUG" "-DCMAKE_EXE_LINKER_FLAGS=  -target aarch64-linux-gnu.2.27" -DCMAKE_EXE_LINKER_FLAGS_RELEASE= "-DCMAKE_C_FLAGS= -target aarch64-linux-gnu.2.27" /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source
CMake Warning (deprecated) at CMakeLists.txt:20 (cmake_minimum_required):
  Compatibility with CMake < 3.10 will be removed from a future version of
  CMake.

  Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
  to tell CMake that the project requires at least <min> but has been updated
  to work with policies introduced by <max> or earlier.
This warning is for project developers.  Use -Wno-author or -Wno-deprecated
to suppress it.

-- The CXX compiler identification is Clang 22.1.8
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /tmp/.xmake1000/261027/zigcc/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- libmarisa found: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/libmarisa.a
-- Performing Test COMPILER_HAS_HIDDEN_VISIBILITY
-- Performing Test COMPILER_HAS_HIDDEN_VISIBILITY - Success
-- Performing Test COMPILER_HAS_HIDDEN_INLINE_VISIBILITY
-- Performing Test COMPILER_HAS_HIDDEN_INLINE_VISIBILITY - Success
-- Performing Test COMPILER_HAS_DEPRECATED_ATTR
-- Performing Test COMPILER_HAS_DEPRECATED_ATTR - Success
-- Found PkgConfig: /usr/bin/pkg-config (found version "3.0.10")
-- Checking for one of the modules 'marisa'
-- Checking for one of the modules 'tclap'
-- Checking for one of the modules 'darts'
CMake Warning (policy) at data/CMakeLists.txt:1 (find_package):
  Policy CMP0148 is not set: The FindPythonInterp and FindPythonLibs modules
  are removed.  Run "cmake --help-policy CMP0148" for policy details.  Use
  the cmake_policy command to set the policy and suppress this warning.
This warning is for project developers.  Use -Wno-author or -Wno-policy to
suppress it.

-- Found PythonInterp: /usr/bin/python (found version "3.14.8")
-- Configuring done (1.5s)
-- Generating done (0.0s)
CMake Warning (unused-cli):
  Manually-specified variables were not used by the project:

    CMAKE_ASM_COMPILER
    CMAKE_ASM_FLAGS
    CMAKE_C_COMPILER
    CMAKE_C_FLAGS
    CMAKE_C_FLAGS_RELEASE
    CMAKE_C_LINKER_DEPFILE_SUPPORTED
    CMAKE_INSTALL_LIBDIR
    HAVE_FLAG_SEARCH_PATHS_FIRST


-- Build files have been written to: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b
/usr/bin/ninja install -C /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b -v -j 30
ninja: Entering directory `/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b'
[1/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/Segmentation.cpp.o -MF src/CMakeFiles/libopencc.dir/Segmentation.cpp.o.d -o src/CMakeFiles/libopencc.dir/Segmentation.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/Segmentation.cpp
[2/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/UTF8StringSlice.cpp.o -MF src/CMakeFiles/libopencc.dir/UTF8StringSlice.cpp.o.d -o src/CMakeFiles/libopencc.dir/UTF8StringSlice.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/UTF8StringSlice.cpp
[3/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/SimpleConverter.cpp.o -MF src/CMakeFiles/libopencc.dir/SimpleConverter.cpp.o.d -o src/CMakeFiles/libopencc.dir/SimpleConverter.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/SimpleConverter.cpp
[4/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/UTF8Util.cpp.o -MF src/CMakeFiles/libopencc.dir/UTF8Util.cpp.o.d -o src/CMakeFiles/libopencc.dir/UTF8Util.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/UTF8Util.cpp
[5/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/DictConverter.cpp.o -MF src/CMakeFiles/libopencc.dir/DictConverter.cpp.o.d -o src/CMakeFiles/libopencc.dir/DictConverter.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/DictConverter.cpp
[6/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/TextDict.cpp.o -MF src/CMakeFiles/libopencc.dir/TextDict.cpp.o.d -o src/CMakeFiles/libopencc.dir/TextDict.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/TextDict.cpp
[7/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/Converter.cpp.o -MF src/CMakeFiles/libopencc.dir/Converter.cpp.o.d -o src/CMakeFiles/libopencc.dir/Converter.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/Converter.cpp
[8/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/ConversionChain.cpp.o -MF src/CMakeFiles/libopencc.dir/ConversionChain.cpp.o.d -o src/CMakeFiles/libopencc.dir/ConversionChain.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/ConversionChain.cpp
[9/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/Conversion.cpp.o -MF src/CMakeFiles/libopencc.dir/Conversion.cpp.o.d -o src/CMakeFiles/libopencc.dir/Conversion.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/Conversion.cpp
[10/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/DictEntry.cpp.o -MF src/CMakeFiles/libopencc.dir/DictEntry.cpp.o.d -o src/CMakeFiles/libopencc.dir/DictEntry.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/DictEntry.cpp
[11/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/Dict.cpp.o -MF src/CMakeFiles/libopencc.dir/Dict.cpp.o.d -o src/CMakeFiles/libopencc.dir/Dict.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/Dict.cpp
[12/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/SerializedValues.cpp.o -MF src/CMakeFiles/libopencc.dir/SerializedValues.cpp.o.d -o src/CMakeFiles/libopencc.dir/SerializedValues.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/SerializedValues.cpp
[13/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/MaxMatchSegmentation.cpp.o -MF src/CMakeFiles/libopencc.dir/MaxMatchSegmentation.cpp.o.d -o src/CMakeFiles/libopencc.dir/MaxMatchSegmentation.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/MaxMatchSegmentation.cpp
[14/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/DartsDict.cpp.o -MF src/CMakeFiles/libopencc.dir/DartsDict.cpp.o.d -o src/CMakeFiles/libopencc.dir/DartsDict.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/DartsDict.cpp
[15/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/BinaryDict.cpp.o -MF src/CMakeFiles/libopencc.dir/BinaryDict.cpp.o.d -o src/CMakeFiles/libopencc.dir/BinaryDict.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/BinaryDict.cpp
[16/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/DictGroup.cpp.o -MF src/CMakeFiles/libopencc.dir/DictGroup.cpp.o.d -o src/CMakeFiles/libopencc.dir/DictGroup.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/DictGroup.cpp
[17/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/Lexicon.cpp.o -MF src/CMakeFiles/libopencc.dir/Lexicon.cpp.o.d -o src/CMakeFiles/libopencc.dir/Lexicon.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/Lexicon.cpp
[18/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/MarisaDict.cpp.o -MF src/CMakeFiles/libopencc.dir/MarisaDict.cpp.o.d -o src/CMakeFiles/libopencc.dir/MarisaDict.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/MarisaDict.cpp
[19/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/Config.cpp.o -MF src/CMakeFiles/libopencc.dir/Config.cpp.o.d -o src/CMakeFiles/libopencc.dir/Config.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/Config.cpp
[20/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIE   -std=c++14 -Wall -MD -MT src/tools/CMakeFiles/opencc_dict.dir/DictConverter.cpp.o -MF src/tools/CMakeFiles/opencc_dict.dir/DictConverter.cpp.o.d -o src/tools/CMakeFiles/opencc_dict.dir/DictConverter.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/tools/DictConverter.cpp
[21/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIE   -std=c++14 -Wall -MD -MT src/tools/CMakeFiles/opencc_phrase_extract.dir/PhraseExtract.cpp.o -MF src/tools/CMakeFiles/opencc_phrase_extract.dir/PhraseExtract.cpp.o.d -o src/tools/CMakeFiles/opencc_phrase_extract.dir/PhraseExtract.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/tools/PhraseExtract.cpp
[22/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIC   -std=c++14 -Wall -MD -MT src/CMakeFiles/libopencc.dir/PhraseExtract.cpp.o -MF src/CMakeFiles/libopencc.dir/PhraseExtract.cpp.o.d -o src/CMakeFiles/libopencc.dir/PhraseExtract.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/PhraseExtract.cpp
[23/49] /tmp/.xmake1000/261027/zigcc/c++ -DENABLE_DARTS -DLOCALEDIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/locale\" -DOpencc_BUILT_AS_STATIC -DPACKAGE_NAME=\"opencc\" -DPKGDATADIR=\"/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/b15088751bcd43858fb6192a2b9243eb/share/opencc\" -DVERSION=\"1.1.9\" -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src -I/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/r/rapidjson/2025.02.05/59c77fe766a44d67a76085164aacb14e/include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/t/tclap/v1.2.5/c3f05bd668194efdbe94f792cd856119/lib/pkgconfig/../../include -isystem /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/pkgconfig/../../include -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -fPIE   -std=c++14 -Wall -MD -MT src/tools/CMakeFiles/opencc.dir/CommandLine.cpp.o -MF src/tools/CMakeFiles/opencc.dir/CommandLine.cpp.o.d -o src/tools/CMakeFiles/opencc.dir/CommandLine.cpp.o -c /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/src/tools/CommandLine.cpp
[24/49] : && /usr/bin/cmake -E rm -f src/libopencc.a && /tmp/.xmake1000/261027/zigcc/ar qc src/libopencc.a  src/CMakeFiles/libopencc.dir/Config.cpp.o src/CMakeFiles/libopencc.dir/Conversion.cpp.o src/CMakeFiles/libopencc.dir/ConversionChain.cpp.o src/CMakeFiles/libopencc.dir/Converter.cpp.o src/CMakeFiles/libopencc.dir/Dict.cpp.o src/CMakeFiles/libopencc.dir/DictConverter.cpp.o src/CMakeFiles/libopencc.dir/DictEntry.cpp.o src/CMakeFiles/libopencc.dir/DictGroup.cpp.o src/CMakeFiles/libopencc.dir/Lexicon.cpp.o src/CMakeFiles/libopencc.dir/MarisaDict.cpp.o src/CMakeFiles/libopencc.dir/MaxMatchSegmentation.cpp.o src/CMakeFiles/libopencc.dir/PhraseExtract.cpp.o src/CMakeFiles/libopencc.dir/SerializedValues.cpp.o src/CMakeFiles/libopencc.dir/SimpleConverter.cpp.o src/CMakeFiles/libopencc.dir/Segmentation.cpp.o src/CMakeFiles/libopencc.dir/TextDict.cpp.o src/CMakeFiles/libopencc.dir/UTF8StringSlice.cpp.o src/CMakeFiles/libopencc.dir/UTF8Util.cpp.o src/CMakeFiles/libopencc.dir/BinaryDict.cpp.o src/CMakeFiles/libopencc.dir/DartsDict.cpp.o && /tmp/.xmake1000/261027/zigcc/ranlib src/libopencc.a && :
[25/49] : && /tmp/.xmake1000/261027/zigcc/c++ -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -target aarch64-linux-gnu.2.27 src/tools/CMakeFiles/opencc_phrase_extract.dir/PhraseExtract.cpp.o -o src/tools/opencc_phrase_extract  src/libopencc.a  /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/libmarisa.a  /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/libdarts.a && :
[26/49] : && /tmp/.xmake1000/261027/zigcc/c++ -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -target aarch64-linux-gnu.2.27 src/tools/CMakeFiles/opencc_dict.dir/DictConverter.cpp.o -o src/tools/opencc_dict  src/libopencc.a  /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/libmarisa.a  /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/libdarts.a && :
[27/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/HKVariantsRevPhrases.txt --output HKVariantsRevPhrases.ocd2 --from text --to ocd2
FAILED: [code=127] data/HKVariantsRevPhrases.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/HKVariantsRevPhrases.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/HKVariantsRevPhrases.txt --output HKVariantsRevPhrases.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[28/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPShinjitaiCharacters.txt --output JPShinjitaiCharacters.ocd2 --from text --to ocd2
FAILED: [code=127] data/JPShinjitaiCharacters.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/JPShinjitaiCharacters.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPShinjitaiCharacters.txt --output JPShinjitaiCharacters.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[29/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/HKVariants.txt --output HKVariants.ocd2 --from text --to ocd2
FAILED: [code=127] data/HKVariants.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/HKVariants.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/HKVariants.txt --output HKVariants.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[30/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPShinjitaiPhrases.txt --output JPShinjitaiPhrases.ocd2 --from text --to ocd2
FAILED: [code=127] data/JPShinjitaiPhrases.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/JPShinjitaiPhrases.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPShinjitaiPhrases.txt --output JPShinjitaiPhrases.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[31/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/STCharacters.txt --output STCharacters.ocd2 --from text --to ocd2
FAILED: [code=127] data/STCharacters.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/STCharacters.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/STCharacters.txt --output STCharacters.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[32/49] : && /tmp/.xmake1000/261027/zigcc/c++ -target aarch64-linux-gnu.2.27 -O3 -DNDEBUG -target aarch64-linux-gnu.2.27 src/tools/CMakeFiles/opencc.dir/CommandLine.cpp.o -o src/tools/opencc  src/libopencc.a  /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/m/marisa/v0.2.6/c9241852672542f48e1c681889a28ff2/lib/libmarisa.a  /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/d/darts/0.32/9a050790f5e94e358bc335f094f46a45/lib/libdarts.a && :
[33/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/STPhrases.txt --output STPhrases.ocd2 --from text --to ocd2
FAILED: [code=127] data/STPhrases.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/STPhrases.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/STPhrases.txt --output STPhrases.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[34/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPVariants.txt --output JPVariants.ocd2 --from text --to ocd2
FAILED: [code=127] data/JPVariants.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/JPVariants.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPVariants.txt --output JPVariants.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[35/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TSCharacters.txt --output TSCharacters.ocd2 --from text --to ocd2
FAILED: [code=127] data/TSCharacters.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/TSCharacters.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TSCharacters.txt --output TSCharacters.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[36/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TSPhrases.txt --output TSPhrases.ocd2 --from text --to ocd2
FAILED: [code=127] data/TSPhrases.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/TSPhrases.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TSPhrases.txt --output TSPhrases.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[37/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWVariants.txt --output TWVariants.ocd2 --from text --to ocd2
FAILED: [code=127] data/TWVariants.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/TWVariants.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWVariants.txt --output TWVariants.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[38/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWVariantsRevPhrases.txt --output TWVariantsRevPhrases.ocd2 --from text --to ocd2
FAILED: [code=127] data/TWVariantsRevPhrases.ocd2 /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data/TWVariantsRevPhrases.ocd2 
cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict --input /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWVariantsRevPhrases.txt --output TWVariantsRevPhrases.ocd2 --from text --to ocd2
/bin/sh: 行 1: /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/packages/o/opencc/1.1.9/0e972f5418874935af31c2aa272ae28b/bin/opencc_dict: 没有那个文件或目录
[39/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /usr/bin/python /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/scripts/reverse.py /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWVariants.txt TWVariantsRev.txt
[40/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /usr/bin/python /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/scripts/reverse.py /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/HKVariants.txt HKVariantsRev.txt
[41/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /usr/bin/python /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/scripts/reverse.py /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/JPVariants.txt JPVariantsRev.txt
[42/49] cd /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b/data && /usr/bin/python /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/scripts/merge.py /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWPhrasesIT.txt /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWPhrasesName.txt /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/dictionary/TWPhrasesOther.txt TWPhrases.txt
/home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/data/scripts/merge.py:16: DeprecationWarning: codecs.open() is deprecated. Use open() instead.
  input_file = codecs.open(sys.argv[i], "r", encoding="utf-8")
ninja: build stopped: subcommand failed.
[0m[2;38;2;255;0;0;1merror: [0m@programdir/core/sandbox/modules/os.lua:378: execv(/usr/bin/ninja install -C /home/youran/Documents/git/PenMods/.toolchain/xmake-home/.xmake/cache/packages/2610/o/opencc/1.1.9/source/build_6f22c69b -v -j 30) failed(127)
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [@programdir/core/sandbox/modules/os.lua:378]:
    [@programdir/core/sandbox/modules/os.lua:291]: in function 'vrunv'
    [@programdir/modules/package/tools/ninja.lua:67]: in function 'install'
    [@programdir/modules/package/tools/cmake.lua:1167]: in function '_install_for_ninja'
    [@programdir/modules/package/tools/cmake.lua:1371]: in function 'install'
    [...make/repositories/xmake-repo/packages/o/opencc/xmake.lua:89]: in function 'script'
    [...dir/modules/private/action/require/impl/utils/filter.lua:114]: in function 'call'
    [.../modules/private/action/require/impl/actions/install.lua:472]:
[0m
[0m[38;2;255;255;0m  => [0minstall opencc 1.1.9 .. [38;2;255;0;0;1mfailed[0m
[0m[1;38;2;255;0;0;1merror: [0m@programdir/core/main.lua:272: @programdir/modules/async/runjobs.lua:390: .../modules/private/action/require/impl/actions/install.lua:581: install failed!
stack traceback:
    [C]: in function 'error'
    [@programdir/core/base/os.lua:1093]:
    [.../modules/private/action/require/impl/actions/install.lua:581]: in function 'catch'
    [@programdir/core/sandbox/modules/try.lua:123]: in function 'try'
    [.../modules/private/action/require/impl/actions/install.lua:439]:
    [...modules/private/action/require/impl/install_packages.lua:510]: in function 'job_func'
    [@programdir/modules/async/runjobs.lua:206]:

stack traceback:
	[C]: in function 'error'
	@programdir/core/base/os.lua:1093: in function 'os.raiselevel'
	(...tail calls...)
	@programdir/core/main.lua:272: in upvalue 'cotask'
	@programdir/core/base/scheduler.lua:514: in function <@programdir/core/base/scheduler.lua:507>[0m
