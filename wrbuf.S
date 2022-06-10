//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.0 05/27/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified
    
    // import constants
    #include "encrypter.h"

    .section .rodata
.Lmsg: .string "wrbuf: Write failed on output\n"
.Lmsg2: .string "wrbuf: Buffer size error\n"

    .text

    ///////////////////////////////////////////////////
    // int wrbuf(char *IOBUF, int cnt, FILE *FPOUT); //
    // return cnt on success EXIT_FAIL otherwise     //
    ///////////////////////////////////////////////////
    .type   wrbuf, %function
    .global wrbuf
    .equ    FP_OFF, 12
 
wrbuf:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    // Registers from arguments:
    // r0 -> IOBUF
    // r1 -> cnt
    // r2 -> FPOUT

    // 1) if cnt <= 0, print error (with .Lmsg2) and exit
    cmp     r1, 0                       // if cnt > 0, continue
    bgt     .Lwrio

    ldr     r0, =.Lmsg2                 // otherwise, print errmsg (.Lmsg2)
    bl      errmsg

    mov     r0, EXIT_FAIL               // exit with EXIT_FAIL
    b       .Lexit

.Lwrio:
    // 2) call fwrite(IOBUF, 1, cnt, FPOUT)
    mov     r5, r1                      // save cnt to r5
    mov     r3, r2                      // pass FPOUT to r3     (arg4)
    mov     r2, r1                      // pass cnt to r2       (arg3)
    mov     r1, 1                       // pass 1 to r1         (arg2)
                                        // IOBUF already in r0  (arg1)
    bl      fwrite                      // call fwrite

    mov     r4, r0                      // swap cnt into r0, ret into r4
    mov     r0, r5

    cmp     r4, r0                      // if ret == cnt, return with cnt
    beq     .Lexit

    ldr     r0, =.Lmsg                  // otherwise, print errmsg (.Lmsg)
    bl      errmsg

    mov     r0, EXIT_FAIL               // exit with EXIT_FAIL


.Lexit:
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size   wrbuf, (. - wrbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif
