#include <iostream>
using namespace std;

int main() 
{
   int dd,mm,yy,cc,mo,ce,week,year;
  cout<<"Input a Day (1-31)"<<endl;
   cin>>dd;
   if (dd>31) cout<<"Invalid day";
   else cout<<"Input Month"<<endl;
   cin>>mm;
   if (mm>12) cout<<"Invalid Month";
   else 
      
       cout << "Input Year(1000-9999)"<<endl;
       cin>>year;
       cc = year / 100;
       yy = year % 100;
   
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
        if (ce==6) week=(dd+mo+yy+yy/4+ce)%7; 
        else {
           if (mo==6) week=(dd+1+mo+yy+yy/4+ce)%7; 
           if (mo==2) week=(dd+1+mo+yy+yy/4+ce)%7;
           if (mo !=6) {
               if (mo !=2) jave=(dd+mo+yy+yy/4+ce)%7;
           }
          }
   }
   else jave=(dd+mo+yy+yy/4+ce)%7; 
      
   if (jave==0) cout<<"Sunday";
   if (jave==1) cout<<"Monday";
   if (jave==2) cout<<"Tuesday";
   if (jave==3) cout<<"Wednesday";
   if (jave==4) cout<<"Thursday";
   if (jave==5) cout<<"Friday";
   if (jave==6) cout<<"Saturday";
int tt;
cout<<"";
cin>>ts;

  return 0;
}
