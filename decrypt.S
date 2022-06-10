//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.0 05/22/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "encrypter.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int decrypt(char *IOBUF, char *BOOKBUF, int cnt) 
    // decrypts  IOBUF using BOOKBUF; result in IOBUF
    //////////////////////////////////////////////////
    .global decrypt
    .type   decrypt, %function
    .equ    FP_OFF, 12

decrypt:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    // Registers:
    // r0 -> *IOBUF
    // r1 -> *BOOKBUF
    // r2 -> cnt
    // r3 -> loop counter
    // r4 -> current IOBUF byte (x)
    // r5 -> current BOOKBUF byte (y)

    // Algorithm:
    // 1) Store current IOBUF and BOOKBUF bytes (x, y)
    // 2) XOR bytes with each other (stored in x)
    // 3) Swap upper half (4 bits) and lower half (4 bits) of the byte to decrypt
    // 4) Store decrypted byte back into IOBUF overwriting encrypted byte
   

    mov     r3, 0               // pre-loop setup
.Lfor:
    cmp     r3, r2              // pre-test loop gaurd
    bge     .Lendfr


    // 1) Store current IOBUF and BOOKBUF bytes (x, y)
    ldrb    r4, [r0, r3]        // store current IOBUF byte (x)
    ldrb    r5, [r1, r3]        // store current BOOKBUF byte (y)


    // 2) XOR bytes with each other (stored in x)
    eor     r4, r4, r5


    // 3) Swap upper half (4 bits) and lower half (4 bits) of the byte to decrypt
    mov     r5, r4              // copy byte to swap into r5
    lsl     r4, r4, 24          // isolate left 4 bits in r4
    lsr     r4, r4, 28

    lsl     r5, r5, 28          // isolate right 4 bits in r5
    lsr     r5, r5, 28

    lsl     r5, r5, 4           // move right 4 bits to left
    orr     r4, r4, r5          // combine bits back together in r4


    // 4) Store decrypted byte into IOBUF overwriting encrypted byte
    strb    r4, [r0, r3]        // store decrypted byte in IOBUF

    add     r3, r3, 1           // update counter 
    b       .Lfor               // loop back
.Lendfr:
   
   mov      r0, r2              // store cnt in r0 for return
 
.Ldone:
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size decrypt, (. - decrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
