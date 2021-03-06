#include <stdio.h>
#include "encrypter.h"

int
wrbuf(char *IOBUF, int cnt, FILE *FPOUT)
{
    if (cnt <= 0) {
        errmsg("wrbuf: Buffer size error\n");
        return EXIT_FAIL;
    }

    int c = 0;
    /*
     * write the processed buffer to the file
     * cnt should be really a size_t but on ARM32 it is an int
     */
    if ((c = (int)fwrite(IOBUF, 1, cnt, FPOUT)) != cnt) {
        errmsg("wrbuf: Write failed on output\n");
        fprintf("wrbuf: chars written: %d\n", c);
        return EXIT_FAIL;
    }
    /*
     * return the number of bytes written
     */ 
    return cnt;
}
