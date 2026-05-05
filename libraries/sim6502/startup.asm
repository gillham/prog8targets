; --- Sim6502 startup ---
            ;cld
            ;sei
            ldx  #$ff
            txs
            jsr  p8_sys_startup.init_system
            jsr  p8_sys_startup.init_system_phase2
            jsr  p8b_main.p8s_start
            jmp  p8_sys_startup.cleanup_at_exit

