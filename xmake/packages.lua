--- packages

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
add_requires('sqlite3       3.54.0+100')
add_requires('sqlitecpp     3.4.0')
