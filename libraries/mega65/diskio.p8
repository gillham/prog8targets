%import shared_cbm_diskio
%import diskio_mega65

diskio {
    %option no_symbol_prefixing, ignore_unused

    ; No override here; everything is taken from the shared module.
    ; diskio_mega65 has a fix for rename()
}
