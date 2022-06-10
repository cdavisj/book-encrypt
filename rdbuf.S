//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.1 05/22/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // global constants
    #include "encrypter.h"

    .section .rodata
.Lmsg:  .string "rdbuf: Bookfile is too short for message\n"
.Lmsg2: .string "rdbuf: Buffer size error\n"
    .text

    //////////////////////////////////////////////////////
    // int rdbuf(char *IOBUF, char *BOOKBUF, FILE *FPIN
    //              FILE *FPBOOK, int BUFSZ);
    // returns number of bytes read EXIT_FAIL otherwise
    //////////////////////////////////////////////////////

    .type   rdbuf, %function
    .global rdbuf
    .equ    IARG5,  4 
    .equ    FP_OFF, 12
 
    ////////////////////////////////////////
    // preserved register use             //
    // r4 pointer to book buffer          //
    // r5 FILE *FPBOOK  & cnt read saved  //
    ////////////////////////////////////////

rdbuf:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF


    // Registers from arguments:
    // r0 -> IOBUF
    // r1 -> BOOKBUF
    // r2 -> FPIN
    // r3 -> FPBOOK

    // Preserve registers:
    // r4 -> BOOKBUF
    // r5 -> FPBOOK or cnt

    mov     r4, r1                      // move BOOKBUF to r4
    mov     r5, r3                      // move FPBOOK to r5

    // 1) if bufsz <= 0, print error (with .Lmsg2) and exit
    ldr     r1, [fp, IARG5]             // get bufsz and store in r1

    cmp     r1, 0                       // if bufsz > 0, continue
    bgt     .Lrdio

    ldr     r0, =.Lmsg2                 // otherwise, print errmsg (.Lmsg2)
    bl      errmsg

    mov     r0, EXIT_FAIL               // exit with EXIT_FAIL
    b       .Lexit

.Lrdio:
    // 2) call fread(IOBUF, 1, bufsz, FPIN)
    mov     r3, r2                      // pass FPIN to r3      (arg4)
    mov     r2, r1                      // pass BUFSZ to r2     (arg3)
    mov     r1, 1                       // pass 1 to r1         (arg2)
                                        // IOBUF already in r0  (arg1)
    bl      fread                       // call fread

    cmp     r0, 0                       // if cnt != 0, continue to read BOOKBUF
    bne     .Lrdbook

    b       .Lexit                      // otherwise, return cnt

.Lrdbook:
    // 3) call fread(BOOKBUF, 1, cnt, FPBOOK)
    mov     r3, r5                      // pass FPBOOK to r3    (arg4)
    mov     r5, r0                      // save cnt to r5
    mov     r2, r0                      // pass cnt to r2       (arg3)
    mov     r1, 1                       // pass 1 to r1         (arg2)
    mov     r0, r4                      // pass BOOKBUF to r0   (arg1)
    bl      fread                       // call fread

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

    .size   rdbuf, (. - rdbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif
