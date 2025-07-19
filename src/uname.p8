;
; Print system information.
;
%import os
%import strings
%import textio

main {
    ; what to show based on args
    bool arch = false
    bool banks = false
    bool hardware = false
    bool opsys = false
    bool kernal = false
    bool vera = false
    bool smc = false

    ; system information
    ubyte numbanks
    byte kernalver
    ubyte vera_major
    ubyte vera_minor
    ubyte vera_patch
    ubyte smc_major
    ubyte smc_minor
    ubyte smc_patch

     sub start() {
        ubyte argc
        uword argv
        ubyte i

        argv, argc = os.get_args()

        numbanks, kernalver, void, void, void = os.get_sys_info()
        vera_major = cx16.r0L
        vera_minor = cx16.r0H
        vera_patch = cx16.r1L
        smc_major = cx16.r1H
        smc_minor = cx16.r2L
        smc_patch = cx16.r2H

        if argc > 1 {
            repeat argc {
                if argv[0] == '-' {
                    when argv[1] {
                        'a' -> arch = banks = hardware = opsys = kernal = vera = smc = true
                        'b' -> banks = true
                        'i' -> hardware = true
                        'k' -> kernal = true
                        'm' -> arch = true
                        'o' -> opsys = true
                        'p' -> arch = true
                        'r' -> kernal = true
                        's' -> smc = true
                        'v' -> vera = true
                    }
                }
                i = strings.length(argv)
                argv += (i + 1) as uword
            }
        } else {
            opsys = true
        }

        if opsys txt.print("cx16os ")
        if kernal {
            txt.chrout('R')
            txt.print_ub(abs(kernalver))
            if kernalver < 0 {
                txt.print(" (prerelease)")
            }
            txt.spc()
        }
        if hardware {
            if @($9fbe) == '1' and @($9fbf) == '6'
                txt.print("x16emu")
            else
                txt.print("Commander X16")
            txt.spc()
        }
        if vera {
            txt.print("VERA:")
            txt.print_ub(vera_major)
            txt.chrout('.')
            txt.print_ub(vera_minor)
            txt.chrout('.')
            txt.print_ub(vera_patch)
            txt.spc()
        }
        if smc {
            txt.print("SMC:")
            txt.print_ub(smc_major)
            txt.chrout('.')
            txt.print_ub(smc_minor)
            txt.chrout('.')
            txt.print_ub(smc_patch)
            txt.spc()
        }
        if banks {
            txt.print("RAM banks: ")
            txt.print_uw(numbanks as uword + 1)
            txt.spc()
            txt.print_uw((numbanks as uword + 1) * 8)
            txt.print("KB")
            txt.spc()
        }
        if arch {
            if cx16.cpu_is_65816()
                txt.print("65816")
            else
                txt.print("65C02")
            txt.spc()
        }
        txt.nl()
    }
}
