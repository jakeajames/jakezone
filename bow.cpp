#include <iostream>
using namespace std;

int main() 
{
   int dd,mm,yy,cc,mo,ce,jave;
   cout<<"Vendos Daten"<<endl;
   cin>>dd;
   if (dd>31) cout<<"Kjo date nuk ekziston";
   else cout<<"Vendos nr. e muajit"<<endl;
   cin>>mm;
   if (mm>12) cout<<"Ky muaj nuk ekziston";
   else cout<<"Vendos vitin (me hapesire ne mes ..20 16..20 17..)"<<endl;
   cin>>cc>>yy;
   if (mm==3) mo=3;
   if (mm==4) mo=6;
   if (mm==5) mo=1;
   if (mm==6) mo=4;
   if (mm==7) mo=6;
   if (mm==8) mo=2;
   if (mm==9) mo=5;
   if (mm==10) mo=0;
   if (mm==11) mo=3;
   if (mm==12) mo=5;
   
     if (cc%4==0) ce=6;
    if (cc%4==1) ce=4;
    if (cc%4==2) ce=2;
    if (cc%4==3) ce=0;
    
    if (mm==1) {
        if (yy%4==0) mo=6;
        else mo=0;
    }
    if (mm==2) {
        if (yy%4==0) mo=2;
        else mo=3;
    }
    if (yy==00) {
        if (ce==6) jave=(dd+mo+yy+yy/4+ce)%7; 
        else {
           if (mo==6) jave=(dd+1+mo+yy+yy/4+ce)%7; 
           if (mo==2) jave=(dd+1+mo+yy+yy/4+ce)%7;
           if (mo !=6) {
               if (mo !=2) jave=(dd+mo+yy+yy/4+ce)%7;
           }
          }
   }
   else jave=(dd+mo+yy+yy/4+ce)%7; 
      
   if (jave==0) cout<<"E Diele";
   if (jave==1) cout<<"E Hene";
   if (jave==2) cout<<"E Marte";
   if (jave==3) cout<<"E Merkure";
   if (jave==4) cout<<"E Enjte";
   if (jave==5) cout<<"E Premte";
   if (jave==6) cout<<"E Shtune";

  return 0;
}
