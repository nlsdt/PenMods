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

option('force-debug-log')
    set_default(false)
    set_showmenu(true)
    set_description('Enable PL_DEBUG define even in release builds (force debug logging).')
option_end()
