
// BINARY TO DECIMAL SYSTEM CONVERTER. THIS IS VULNERABLE TO A STACK OVERFLOW. DO WHAT YOU WANT WITH THIS
#include <iostream> 
using namespace std;

char bin[8];
int nr = 0;

int main() {
 printf("Input a binary value\n");
 gets(bin);
 for (int i = 0; i < 8; i++) {
   if (bin[i] == '1') {
     
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
 cout << "Decimal value is" << nr;
}
