diskio {
    %option no_symbol_prefixing, ignore_unused
    %option merge

    ; One override here

    sub rename(str oldfileptr, str newfileptr) {
        ; -- rename a file on the drive
        list_filename[0] = 'r'
        list_filename[1] = '0'
        list_filename[2] = ':'
        ubyte flen_new = strings.copy(newfileptr, &list_filename+3)
        list_filename[flen_new+3] = '='
        list_filename[flen_new+4] = '0'
        list_filename[flen_new+5] = ':'
        ubyte flen_old = strings.copy(oldfileptr, &list_filename+6+flen_new)
        cbm.SETNAM(6+flen_new+flen_old, list_filename)
        cbm.SETLFS(1, drivenumber, 15)
        void cbm.OPEN()
        cbm.CLRCHN()
        cbm.CLOSE(1)
    }
}
