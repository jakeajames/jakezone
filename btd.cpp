
// BINARY TO DECIMAL SYSTEM CONVERTER. THIS IS VULNERABLE TO A STACK OVERFLOW. DO WHAT YOU WANT WITH THIS
#include <iostream> 
using namespace std;

char bin[8];
char str[8];
int nr = 0;

int main() {
 printf("Input a binary value\n");
 gets(bin);
 

 for (int i = 7; i >= 0; i--) {

     if (bin[i] != '0' && bin[i] != '1') {
         if (i == 7) str[0] =  '0';
         if (i == 6) str[1] =  '0';
         if (i == 5) str[2] =  '0';
         if (i == 4) str[3] =  '0';
         if (i == 3) str[4] =  '0';
         if (i == 2) str[5] =  '0';
         if (i == 1) str[6] =  '0';
         if (i == 0) str[7] =  '0';
     }
    }
       char fbin[8] = strcat(str, bin);
   
      
       
        for (int i = 7; i >= 0; i--) {
   if (fbin[i] == '1') {
     
       if  (i == 0) {
       nr += 128;
   
       }
       else if (i == 1) {
           nr += 64;
       
       }
        else if (i == 2) {
           nr += 32;
           
       }
        else if (i == 3) {
           nr += 16;
           
       }
        else if (i == 4) {
           nr += 8;
           
       }
        else if (i == 5) {
           nr += 4;
           
       }
        else if (i == 6) {
           nr += 2;
           
       }
        else if (i == 7) {
           nr += 1;
           
       }
   }

 }
 cout << "Decimal value is: " << nr;
}
