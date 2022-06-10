//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.1 05/27/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // function import
    .extern encrypt
    .extern decrypt
    .extern setup
    .extern rdbuf
    .extern cleanup
    .extern wrbuf

    // global constants
    #include "encrypter.h"

    .text

    //////////////////////////////////////////////////////
    // int main(int argc, char **argv)                  //
    // encrypter [-d | -e] -b bookfile encryption_file  //
    //////////////////////////////////////////////////////

    // set up stack frame offsets
    .global main
    .type   main, %function
    .equ    BUFSZ,      1024            // buffer size
    .equ    FP_OFF,     28              // fp offset in main stack frame
    .equ    FPBOOK,     4 + FP_OFF      // FILE * to book file
    .equ    FPIN,       4 + FPBOOK      // FILE * to input file
    .equ    FPOUT,      4 + FPIN        // FILE * to output file
    .equ    MODE,       4 + FPOUT       // decrypt or encrypt mode
    .equ    IOBUF,      BUFSZ + MODE    // buffer for input file
    .equ    BOOKBUF,    BUFSZ + IOBUF   // buffer for book file
    .equ    PAD,        8 + BOOKBUF     // Stack frame PAD 
    .equ    OARG6,      4 + PAD         // output arg6
    .equ    OARG5,      4 + OARG6       // output arg5 must be at bottom
    .equ    FRAMESZ,    OARG5 - FP_OFF  // total space for frame
    ////////////////////////////////////////////////////////////////
    // make sure that FRAMESZ + FP_OFF + 4 divides by 8 EVENLY!
    ////////////////////////////////////////////////////////////////
 
    //////////////////////////////////////////////////////
    // preserved register use                           //
    // r4  pointer to input/output buffer  (IOBUF)      //
    // r5  pointer to book buffer          (BOOKBUF)    //
    // r6  mode flag                       (MODE)       //
    // r7  input FILE *                    (FPIN)       //
    // r8  book FILE *                     (FPBOOK)     //
    // r9  output FILE *                   (FPOUT)      //
    //////////////////////////////////////////////////////

main:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF          // set frame pointer to frame base
    ldr     r3, =FRAMESZ            // frame size is big, use pseudo ldr
    sub     sp, sp, r3              // allocate space for locals and passed args 
     
    // call setup(argc, argv, *MODE, *FPBOOK, *FPIN, *FPOUT)
    add     r2, fp, -MODE           // pass &MODE       (arg3)
    add     r3, fp, -FPBOOK         // pass &FPBOOK     (arg4)
    add     r4, fp, -FPIN           // pass &FPIN       (arg5)
    str     r4, [fp, -OARG5]
    add     r5, fp, -FPOUT          // pass &FPOUT      (arg6)
    str     r5, [fp, -OARG6]
    bl      setup                   // call setup

    cmp     r0, EXIT_FAIL           // if setup failed, exit
    beq     .Lexit


    // set up preserve registers (r4-r9) for main loop
    ldr     r0, =IOBUF              // load IOBUF to r4
    sub     r4, fp, r0
    ldr     r0, =BOOKBUF            // load BOOKBUF to r5
    sub     r5, fp, r0
    ldr     r6, [fp, -MODE]         // load MODE to r6
    ldr     r7, [fp, -FPIN]         // load FPIN to r7
    ldr     r8, [fp, -FPBOOK]       // load FPBOOK to r8
    ldr     r9, [fp, -FPOUT]        // load FPOUT to r9

.Lloop:
    // call rdbuf(IOBUF, BOOKBUF, FPIN, FPBOOK, BUFSZ)
    ldr     r0, =BUFSZ              // store BUFSZ in OARG5 (arg5) 
    str     r0, [fp, -OARG5]
    mov     r3, r8                  // move FPBOOK to r3    (arg4)
    mov     r2, r7                  // move FPIN to r2      (arg3)
    mov     r1, r5                  // move BOOKBUF to r1   (arg2)
    mov     r0, r4                  // move IOBUF to r0     (arg1)
    bl      rdbuf                   // call rdbuf

    cmp     r0, 0           // if cnt > 0, continue
    bgt     .Lprocinput

    b       .Ldone          // otherwise, exit

    
.Lprocinput:
    // setup args for call to XXcrypt(IOBUF, BOOKBUF, cnt)
    mov     r2, r0                  // move cnt to r2       (arg3)
    mov     r1, r5                  // move BOOKBUF to r1   (arg2)
    mov     r0, r4                  // move IOBUF to r0     (arg1)

    cmp     r6, ENCRYPT_MODE        // if MODE is not ENCRYPT_MODE, go decrypt
    bne     .Ldecrypt

    // otherwise, call encrypt and write out
    bl      encrypt                 // call encrypt
    b       .Lwriteout              // go to write out

.Ldecrypt: 
    // decrypt the input and write out
    bl      decrypt                 // call decrypt

    // fall through to write out

.Lwriteout:
    cmp     r0, EXIT_FAIL           // if cnt is EXIT_FAIL, go cleanup
    beq     .Ldone

    // call wrbuf(IOBUF, cnt, FPOUT)
    mov     r2, r9                  // move FPOUT to r2     (arg3)
    mov     r1, r0                  // move cnt to r1       (arg2)
    mov     r0, r4                  // move IOBUF to r0     (arg1)
    bl      wrbuf                   // call wrbuf

    cmp     r0, EXIT_FAIL           // if ret != EXIT_FAIL, continue loop
    bne     .Lloop

.Ldone:
    // call cleanup(status)
    bl      cleanup

.Lexit:
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size   main, (. - main)
    .section .note.GNU-stack,"",%progbits
.end
#endif
