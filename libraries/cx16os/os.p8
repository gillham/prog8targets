%option ignore_unused

os {
    ; cx16os functions.
    extsub $9d00 = getc() clobbers(X, Y) -> ubyte @ A
    extsub $9d03 = chrout(ubyte character @ A)
    ; probably needs a wrapper
    extsub $9d06 = exec(uword strargs @AX, ubyte argcount @Y) -> ubyte @A, ubyte @X
    extsub $9d09 = print_str(str arg0 @AX)
    extsub $9db4 = get_console_info()
    extsub $9db7 = set_console_mode()
    extsub $9dba = set_stdin_read_mode()
    ; probably needs a wrapper
    extsub $9d0c = get_process_info(ubyte proc @A, ubyte instance @X) -> ubyte @A, ubyte @X, ubyte @Y
    extsub $9d0f = get_args() -> uword @AX, ubyte @Y
    extsub $9d12 = get_process_name(uword buffer @AX, ubyte pid @Y, ubyte count @R0) -> uword @AX, ubyte @Y
    extsub $9da5 = active_table_lookup()
    extsub $9d15 = parse_num(uword numptr @AX) -> uword @AX, ubyte @Y
    extsub $9d99 = bin_to_bcd16()
    extsub $9d18 = hex_num_to_string(ubyte arg0 @A) -> ubyte @X, ubyte @A

    extsub $9d1b = kill_process(ubyte pid @A) -> ubyte @X, ubyte @A
    extsub $9d1e = open_file(uword filename @AX, ubyte mode @Y) -> ubyte @A, ubyte @X
    extsub $9d21 = close_file(ubyte fd @A)
    extsub $9d24 = read_file(ubyte fd @A, uword offset @R0, uword count @R1, ubyte bank @R2) -> uword @AX, ubyte @Y
    extsub $9d27 = write_file(ubyte fd @A, uword ptr @R0, uword count @R1) -> uword @AX, ubyte @Y
    extsub $9d2a = load_dir_listing_extmem(ubyte bank @A) -> uword @AX
    extsub $9d2d = get_pwd(uword buffer @R0, uword count @R1)
    extsub $9d30 = chdir(uword path @AX) -> ubyte @A
    extsub $9d9c = move_fd()
    extsub $9da8 = copy_fd()
    extsub $9dbd = pipe()
    extsub $9dc0 = seek_file(ubyte fd @A, uword offsetl @R0, uword offseth @R1)
    extsub $9dc3 = tell_file(ubyte fd @A) -> ubyte @A, uword @R0, uword @R1, uword @R2, uword @R3

    ; extmem routines
    extsub $9d33 = res_extmem_bank()
    extsub $9d42 = free_extmem_bank()
    extsub $9d4b = share_extmem_bank()

    extsub $9d57 = set_extmem_wbank()
    extsub $9d36 = set_extmem_rbank()
    extsub $9d39 = set_extmem_rptr()
    extsub $9d3c = set_extmem_wptr()

    extsub $9d3f = readf_byte_extmem_y()
    extsub $9d48 = writef_byte_extmem_y()

    extsub $9d45 = vread_byte_extmem_y()
    extsub $9d4e = vwrite_byte_extmem_y()

    extsub $9dae = pread_extmem_xy()
    extsub $9db1 = pwrite_extmem_xy()

    extsub $9d51 = memmove_extmem()
    extsub $9d54 = fill_extmem()

    ; More system routines

    extsub $9d5d = wait_process(ubyte pid @A) -> ubyte @A, ubyte @X
    extsub $9d60 = fgetc(ubyte fd @X) -> ubyte @A, ubyte @X
    extsub $9d63 = fputc(ubyte fd @X, ubyte data @A) -> ubyte @Y
    extsub $9d66 = unlink(uword filename @AX) -> ubyte @A
    extsub $9d69 = rename(uword source @R1, uword target @R0) -> ubyte @A
    extsub $9d6c = copy_file(uword source @R1, uword target @R0) -> ubyte @A
    extsub $9d6f = mkdir(uword path @AX) -> ubyte @A
    extsub $9d72 = rmdir(uword path @AX) -> ubyte @A

    ; needs wrapper
    extsub $9d9f = get_time() -> uword @R0, uword @R1, uword @R2, uword @R3
    extsub $9dab = get_sys_info() -> ubyte @X, byte @Y, uword @R0, uword @R1, uword @R2

    extsub $9d75 = setup_chrout_hook()
    extsub $9d78 = release_chrout_hook()
    extsub $9d87 = send_byte_chrout_hook()
    
    extsub $9d93 = lock_vera_regs()
    extsub $9d96 = unlock_vera_regs()

    extsub $9d7b = setup_general_hook()
    extsub $9d7e = release_general_hook()
    extsub $9d81 = get_general_hook_info()
    extsub $9d84 = send_message_general_hook()
    extsub $9d90 = mark_last_hook_message_received()

    extsub $9d8a = set_own_priority()
    extsub $9d8d = surrender_process_time()
    extsub $9da2 = detach_self()
}
