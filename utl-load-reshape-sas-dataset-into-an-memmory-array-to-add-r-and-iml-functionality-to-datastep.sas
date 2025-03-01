%let pgm=utl-load-reshape-sas-dataset-into-an-memmory-array-to-add-r-and-iml-functionality-to-datastep;

Load reshape sas dataset into in memory array to add matrix functionality to the datastep like r and iml;

     THREE SOLUTION  (macro on end)

         1 load  sas dataset into array and reverse rows and elements

            x y z  %utl_numary generates
            1 2 3    rowcol[3,2] ( 1 2 3
            4 5 6                  4 5 6 )

         2  reshape %utl_numary(reshape=[2,3))

            x y z    rowcol[3,2] ( 1 2
            1 2 3                  2 4
            4 5 6                  5 6

         3  reshape %utl_numary(reshape=[6,1))
            This can be useful

            x y z   rowcol[6,1] ( 1 2 3 4 5 6 )
            1 2 3
            4 5 6

         4 utl_numaray macro on end

github
https://tinyurl.com/mwpufhbd
https://github.com/rogerjdeangelis/utl-load-reshape-sas-dataset-into-an-memmory-array-to-add-r-and-iml-functionality-to-datastep

macros
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories

/**************************************************************************************************************************/
/*                  |                                                           |                                         */
/*  INPUT           |       PROCESS                                             |    OUTPUT                               */
/*  =====           |       =======                                             |    ======                               */
/*                  |                                                           |                                         */
/* WORK.HAVE        | 1 REVERSE ROWS AND ELEMENTS                               |                                         */
/*                  | ===========================                               |   WANT (REVERSED)                       */
/*  X  Y  Z         |                                                           |                                         */
/*                  | %put %utl_numary(have);                                   |    X  Y  Z                              */
/*  1  2  3         |                                                           |                                         */
/*  4  5  6         | [2,3] (1,2,3,4,5,6)                                       |    6  5  4                              */
/*                  |                                                           |    3  2  1                              */
/* data have;       |                                                           |                                         */
/*   input x y z;   | data want;                                                |                                         */
/* cards4;          |   array num %utl_numary(have);                            |                                         */
/* 1 2 3            |   array var[*] %utl_varlist(have);                        |                                         */
/* 4 5 6            |   do row=dim(num,1) to 1 by -1;                           |                                         */
/* ;;;;             |    varcol=0;                                              |                                         */
/* run;quit;        |    do col=dim(num,2) to 1 by -1;                          |                                         */
/*                  |     varcol=varcol+1;                                      |                                         */
/*                  |     var[varcol]=num[row,col];                             |                                         */
/*                  |   end;                                                    |                                         */
/*                  |   output;                                                 |                                         */
/*                  | end;                                                      |                                         */
/*                  | keep %utl_varlist(have);                                  |                                         */
/*                  | run;quit;                                                 |                                         */
/*                  |                                                           |                                         */
/*                  |-----------------------------------------------------------------------------------------------------*/
/*                  |                                                           |                                         */
/*                  | 2  RESHAPE %UTL_NUMARY(RESHAPE=[2,3))                     |                                         */
/*                  | =====================================                     |  PIVOT LONG                             */
/*                  |                                                           |                                         */
/*                  | %put %utl_numary(have,reshape=%str([3,2]));               |  Note user needs to                     */
/*                  |                                                           |  decide on new names                    */
/*                  | [3,2] (1,2,3,4,5,6)                                       |                                         */
/*                  |                                                           |  WANT                                   */
/*                  | %utl_nopt;                                                |                                         */
/*                  | data want;                                                |   X    Y                                */
/*                  |   array num %utl_numary(have,reshape=%str([3,2]));        |                                         */
/*                  |   array var[*] %utl_varlist(have);                        |   1    2                                */
/*                  |   do row=1 to dim(num,1);                                 |   3    4                                */
/*                  |    do col=1 to dim(num,2);                                |   5    6                                */
/*                  |    var[col]=num[row,col];                                 |                                         */
/*                  |   end;                                                    |                                         */
/*                  |   output;                                                 |                                         */
/*                  | end;                                                      |                                         */
/*                  | drop num: row col %scan(%utl_varlist(have),3);            |                                         */
/*                  | run;quit;                                                 |                                         */
/*                  |                                                           |                                         */
/*                  |-----------------------------------------------------------------------------------------------------*/
/*                  |                                                           |                                         */
/*                  | 3  RESHAPE %UTL_NUMARY(RESHAPE=[6,1))                     |  ONE DIMENSIONAL                        */
/*                  | ======================================                    |                                         */
/*                  |                                                           |                                         */
/*                  | %put %utl_numary(have,reshape=%str([6,1]));               |  Note user needs to                     */
/*                  |                                                           |  decide on new names                    */
/*                  | [6,1] (1,2,3,4,5,6)                                       |                                         */
/*                  |                                                           |                                         */
/*                  | data want;                                                |  X1 X2 X3 X4 X5 X6                      */
/*                  |   array x %utl_numary(have,reshape=%str([6,1]));          |                                         */
/*                  | run;quit;                                                 |   1  2  3  4  5  6                      */
/*                  |                                                           |                                         */
/********************************************************************************|*****************************************/


/*  _
| || |    _ __ ___   __ _  ___ _ __ ___
| || |_  | `_ ` _ \ / _` |/ __| `__/ _ \
|__   _| | | | | | | (_| | (__| | | (_) |
   |_|   |_| |_| |_|\__,_|\___|_|  \___/

*/


%symdel rowcol reshape / nowarn;
* Note macro arguments are automatically local within the macro;
* however it does not hurt to remove from global scope to minimize confusion;

filename ft15f001 "c:/oto/utl_numary.sas";
parmcards4;
%macro utl_numary(_inp,drop=,reshape=0)
   /des="load all character data into a in memory array or drop some vars and then load";
/*
 %let _inp=sd1.have;
 %let drop=i j;
*/
 %local rolcol;
 %symdel _array / nowarn;
 %dosubl(%nrstr(
 %put xxxxxxxx &=reshape xxxxxxxxxxxx;
 filename clp clipbrd lrecl=64000;
 data _null_;
 file clp;
 set &_inp(drop=_character_ &drop) nobs=rows;
 array ns _numeric_;
 call symputx('rowcol',catx(',',rows,dim(ns)));
 put (_numeric_) ($) @@;
 run;quit;
 %put &=rowcol;
 data _null_;
 length res $32756;
 infile clp;
 input;
 if "&reshape"="0" then do;
   res=cats("[&rowcol] (",translate(_infile_,',',' '),')');
   call symputx('_array',res);
 end;
 else do;
   res=cats("&reshape (",translate(_infile_,',',' '),')');
   call symputx('_array',res);
 end;
 run;quit;
 ))
 &_array
%mend utl_numary;
;;;;
run;quit;

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/


















































       INPUT                  PROCESS                                                 OUTPUT
       =====                  =======                                                 ======

      WORK.HAVE         1 REVERSE ROWS AND ELEMENTS
                        ===========================                                  WANT
       X  Y  Z
                        %put %utl_numary(have);                                       X  Y  Z
       1  2  3
       4  5  6          [2,3] (1,2,3,4,5,6)                                           6  5  4
                                                                                      3  2  1
      data have;
        input x y z;    data want;
      cards4;             array num %utl_numary(have);
      1 2 3               array var[*] %utl_varlist(have);
      4 5 6               do row=dim(num,1) to 1 by -1;
      ;;;;                 varcol=0;
      run;quit;            do col=dim(num,2) to 1 by -1;
                            varcol=varcol+1;
                            var[varcol]=num[row,col];
                          end;
                          output;
                        end;
                        keep %utl_varlist(have);
                        run;quit;


                        2  RESHAPE %UTL_NUMARY(RESHAPE=[2,3))
                        =====================================

                        %put %utl_numary(have,reshape=%str([3,2]));                 Note user needs to
                                                                                    decide on new names
                        [3,2] (1,2,3,4,5,6)
                                                                                    WANT
                        %utl_nopt;
                        data want;                                                   X    Y
                          array num %utl_numary(have,reshape=%str([3,2]));
                          array var[*] %utl_varlist(have);                           1    2
                          do row=1 to dim(num,1);                                    3    4
                           do col=1 to dim(num,2);                                   5    6
                           var[col]=num[row,col];
                          end;
                          output;
                        end;
                        drop num: row col %scan(%utl_varlist(have),3);
                        run;quit;



                        %put %utl_numary(have,reshape=%str([6,1]));                 Note user needs to
                                                                                    decide on new names
                        [6,1] (1,2,3,4,5,6)

                        data want;                                                  X1 X2 X3 X4 X5 X6
                          array x %utl_numary(have,reshape=%str([6,1]));
                        run;quit;                                                    1  2  3  4  5  6





































%symdel rowcol reshape / nowarn;
* Note macro arguments are automatically local within the macro;
* however it does not hurt to remove from global scope to minimize confusion;

%macro utl_numary(_inp,drop=,reshape=0)
   /des="load all character data into a in memory array or drop some vars and then load";
/*
 %let _inp=sd1.have;
 %let drop=i j;
*/
 %local rolcol;
 %symdel _array / nowarn;
 %dosubl(%nrstr(
 %put xxxxxxxx &=reshape xxxxxxxxxxxx;
 filename clp clipbrd lrecl=64000;
 data _null_;
 file clp;
 set &_inp(drop=_character_ &drop) nobs=rows;
 array ns _numeric_;
 call symputx('rowcol',catx(',',rows,dim(ns)));
 put (_numeric_) ($) @@;
 run;quit;
 %put &=rowcol;
 data _null_;
 length res $32756;
 infile clp;
 input;
 if "&reshape"="0" then do;
   res=cats("[&rowcol] (",translate(_infile_,',',' '),')');
   call symputx('_array',res);
 end;
 else do;
   res=cats("&reshape (",translate(_infile_,',',' '),')');
   call symputx('_array',res);
 end;
 run;quit;
 ))
 &_array
%mend utl_numary;




                       ;;;;%end;%mend;/*'*/ *);*};*];*/;/*"*/;run;quit;%end;end;run;endcomp;%utlfix;





















%let pgm=utl-fast-long-to-wide-for-many-variables-arts-fast-macro;

%stop_submission

Fast long to wide for many variables arts fast macro

   TWO SOLUTIONS

       1 load  sas dataset into array

          x y z  %utl_numary generates
          1 2 3    rowcol[3,2] ( 1 2 3
          4 5 6                  4 5 6 )

                 %utl_numary(reshape=[2,3))

       1 arts transpose macro
       2 common double transpose
         Tom
         https://communities.sas.com/t5/user/viewprofilepage/user-id/159
       3 numary macro


Arts macro was designed to be fast and eliminate the double transpose
AUTHORS: Arthur Tabachneck, Xia Ke Shan, Robert Virgile and Joe Whitehurst

https://communities.sas.com/t5/SAS-Programming/long-to-wide-for-multiple-varaibles/m-p/955070#M372997


https://github.com/rogerjdeangelis/utl-creating-two-dimensional-numeric-array-from-the-rectangular-sas-dataset
https://github.com/rogerjdeangelis/utl-convert-the-numeric-values-in-sas-dataset-to-an-in-memory-two-dimensional-array-multi-language

/**************************************************************************************************************************/
/*                   |                      |                                                                             */
/*     INPUT         |      PROCESS         |                                 OUTPUT                                      */
/*     =====         |      =======         |                                 ======                                      */
/*                   |                      |                                                                             */
/*Data have;         | 1 ARTS TRANSPOSE     |                                                                             */
/*input ID I X W Z R;| ================     |     1st row     2nd row     3rd row     4th row     5th row     6th row     */
/*cards4;            |                      |     ----------- ----------- ----------- ----------- ----------- ----------- */
/*1 1 11 12 13 14    |  %utl_transpose(     |  ID X1 W1 Z1 R1 X2 W2 Z2 R2 X3 W3 Z3 R3 X4 W4 Z4 R4 X5 W5 Z5 R5 X6 W6 Z6 R6 */
/*1 2 15 16 17 18    |    data=have         |     ----------- ----------- ----------- ----------- ----------- ----------- */
/*1 3 19 20 21 22    |   ,out=want          |   1 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 */
/*1 4 23 24 25 26    |   ,by=id             |   2 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 */
/*1 5 27 28 29 30    |   ,var=X W Z R );    |                                                                             */
/*1 6 31 32 33 34    |                      |                                                                             */
/*2 1 35 36 37 38    |                      |                                                                             */
/*2 2 39 40 41 42    |                      |                                                                             */
/*2 3 43 44 45 46    |                      |                                                                             */
/*2 4 47 48 49 50    |                      |                                                                             */
/*2 5 51 52 53 54    |                      |                                                                             */
/*2 6 55 56 57 58    |                      |                                                                             */
/*;;;;               |                      |                                                                             */
/*Run;quit;          |                      |                                                                             */
/*                   |                      |                                                                             */
/*                   |----------------------|                                                                             */
/*                   |                      |                                                                             */
/*                   | 2 DOUBLE TRANSPOSE   |                                                                             */
/*                   | ==================   |                                                                             */
/*                   |                      |                                                                             */
/*                   | proc transpose       |                                                                             */
/*                   |  data=have out=tall; |                                                                             */
/*                   |   by id i;           |                                                                             */
/*                   |   var x -- r ;       |                                                                             */
/*                   | run;                 |                                                                             */
/*                   |                      |                                                                             */
/*                   | proc transpose       |                                                                             */
/*                   |   data=tall          |                                                                             */
/*                   |   out=want(          |                                                                             */
/*                   |     drop=_name_);    |                                                                             */
/*                   |   by id ;            |                                                                             */
/*                   |   id _name_ i;       |                                                                             */
/*                   |   var col1 ;         |                                                                             */
/*                   | run;                 |                                                                             */
/*                   |                      |                                                                             */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/



Data have;
input ID I X W Z R;
cards4;
1 1 11 12 13 14
1 2 15 16 17 18
1 3 19 20 21 22
1 4 23 24 25 26
1 5 27 28 29 30
1 6 31 32 33 34
2 1 35 36 37 38
2 2 39 40 41 42
2 3 43 44 45 46
2 4 47 48 49 50
2 5 51 52 53 54
2 6 55 56 57 58
;;;;
Run;quit;


%array(_vs,values=1-6);
/*
GLOBAL _VS1 1
GLOBAL _VS2 2
GLOBAL _VS3 3
GLOBAL _VS4 4
GLOBAL _VS5 5
GLOBAL _VS6 6

GLOBAL _VSN 6
*/

data want;

  array num %utl_numary(have,drop=id i,reshape=%str([,2]));
  array var[24] %do_over(_vs,Phrase=X? W? Z? R?);

  do grp= 1;
   rc=0;
   do c=1 to 6;
    do r=1 to 4;
     rc=rc+1;
     var[rc]=num[rc,1];
    end;
   output;
   end;
  end;
  keep X: W: Z: R:;
run;quit;


data want;
  length grp 3;
  array num %utl_numary(have,drop=id i);
  array var[24] %do_over(_vs,Phrase=X? W? Z? R?);

  do grp= 1 to 2;
   rc=0;
   select (grp);
      when(1) do; s=1; e=6;  end;
      when(2) do; s=7; e=12; end;
   end; * otherwise not needed;
   do row=s to e;
     do col=1 to 4;
      rc=rc+1;
      var[rc]=num[row,col];
     end;
   end;
  output;
  end;
  drop rc row col num: s e;
run;quit;


data want;

  array num %utl_numary(have,drop=id i);
  array var[24] %do_over(_vs,Phrase=X? W? Z? R?);

  do grp= 1 to 2;
   rc=0;
   if grp=1 then do;
   do r=s to e;
    do c=1 to 4;
     rc=rc+1;
     var[rc]=num[r,c];
    end;
   end;
  end;
  output;



ID X1 W1 Z1 R1 X2 W2 Z2 R2 X3 W3 Z3 R3 X4 W4 Z4 R4 X5 W5 Z5 R5 X6 W6 Z6 R6

 1 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34
 2 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58







  keep X: W: Z: R:;

run;quit;



 %barray(ll[26] $, function = byte(rank("x")+_I_-1), macarray=Y)
  %put _user_;

  do
















data x;
 do x = 11 to 58 by 1;
   put x @@;
 end;
run;quit;

                               ;;;;%end;%mend;/*'*/ *);*};*];*/;/*"*/;run;quit;%end;end;run;endcomp;%utlfix;
%put %utl_numary(have,drop=id i,reshape=0);
%put %utl_numary(have,drop=id i,reshape=%str([24,2]));

%put _user_;

%symdel rowcol reshape / nowarn;
Note macro arguments are automatically local within the macro
however it does not hurt to remove from global to minimize confusion.

%macro utl_numary(_inp,drop=,reshape=0)
   /des="load all character data into a in memory array or drop some vars and then load";
/*
 %let _inp=sd1.have;
 %let drop=i j;
*/
 %local rolcol;
 %symdel _array / nowarn;
 %dosubl(%nrstr(
 %put xxxxxxxx &=reshape xxxxxxxxxxxx;
 filename clp clipbrd lrecl=64000;
 data _null_;
 file clp;
 set &_inp(drop=_character_ &drop) nobs=rows;
 array ns _numeric_;
 call symputx('rowcol',catx(',',rows,dim(ns)));
 put (_numeric_) ($) @@;
 run;quit;
 %put &=rowcol;
 data _null_;
 length res $32756;
 infile clp;
 input;
 if "&reshape"="0" then do;
   res=cats("[&rowcol] (",translate(_infile_,',',' '),')');
   call symputx('_array',res);
 end;
 else do;
   res=cats("&reshape (",translate(_infile_,',',' '),')');
   call symputx('_array',res);
 end;
 run;quit;
 ))
 &_array
%mend utl_numary;




data;
do i=11 to 58 by 4;
 a= i;b=  i+1;c=  i+2;d=  i+3;
 put a b c d;
end;
run;quit;

     ;b=
































































































































































































































































































































































































































































































































































































































































































































































































































































































































data want;

  array num[24,2] (10,11,13,15,17,17,12,10,19,18,12,12,12,12,12,13,16,15,14,18,16,17,17,18,11,11,11,11,12,13,14,11,19,19,18,16,17,17,16,15,16,15,16,16,14,16,14,13);

  array var[24] x1-x6 w1-w6 z1-z6 r1-r6 (24*.);

   do d2=1 to 2;
      do d1=1 to 24;
        var[d1]   = num[d1,d2];
      end;
     output;
   end;
   keep x1-x6 w1-w6 z1-z6 r1-r6 ;

run;quit;










  grp=22;

     var[1]   =  num[7 ,1]  ;
     var[2]   =  num[8 ,1]  ;
     var[3]   =  num[9 ,1]  ;
     var[4]   =  num[10,1]  ;
     var[5]   =  num[11,1]  ;
     var[6]   =  num[12,1]  ;

     var[7]   =  num[7  ,2] ;
     var[8]   =  num[8  ,2] ;
     var[9]   =  num[9  ,2] ;
     var[10]  =  num[10 ,2] ;
     var[11]  =  num[11 ,2] ;
     var[12]  =  num[12 ,2] ;

     var[13]  = num[7  ,3] ;
     var[14]  = num[8  ,3] ;
     var[15]  = num[9  ,3] ;
     var[16]  = num[10 ,3] ;
     var[17]  = num[11 ,3] ;
     var[18]  = num[12 ,3] ;

     var[19]  = num[7  ,4] ;
     var[20]  = num[8  ,4] ;
     var[21]  = num[9  ,4] ;
     var[22]  = num[10 ,4] ;
     var[23]  = num[11 ,4] ;
     var[24]  = num[12 ,4] ;
   output;

   keep x1-x6 w1-w6 z1-z6 r1-r6;

run;quit;


data chk;
  do v=1 to 24;
    x= ifn(mod(v,6)=0,6,mod(v,6));
    put x=;
  end;
run;quit;


data want ;

  array num %utl_numary(have,drop=id i);
  array var[24] x1-x6 w1-w6 z1-z6 r1-r6 (24*.);

   grp=1;

     do v=1 to 24;
        r=ifn(mod(v,6)=0,6,mod(v,6));

     var[1]   = num[r,1];
     var[2]   = num[r,1];
     var[3]   = num[r,1];
     var[4]   = num[r,1];
     var[5]   = num[r,1];
     var[6]   = num[r,1];

     var[7]   =  num[r,2] ;
     var[8]   =  num[r,2] ;
     var[9]   =  num[r,2] ;
     var[10]  =  num[r,2] ;
     var[11]  =  num[r,2] ;
     var[12]  =  num[r,2] ;

     var[13]  =  num[r,3] ;
     var[14]  =  num[r,3] ;
     var[15]  =  num[r,3] ;
     var[16]  =  num[r,3] ;
     var[17]  =  num[r,3] ;
     var[18]  =  num[r,3] ;

     var[19]  =  num[r,4] ;
     var[20]  =  num[r,4] ;
     var[21]  =  num[r,4] ;
     var[22]  =  num[r,4] ;
     var[23]  =  num[r,4] ;
     var[24]  =  num[r,4] ;

  end;
  output;
   keep x1-x6 w1-w6 z1-z6 r1-r6;

run;quit;

  grp=22;

     var[1]   =  num[7 ,1]  ;
     var[2]   =  num[8 ,1]  ;
     var[3]   =  num[9 ,1]  ;
     var[4]   =  num[10,1]  ;
     var[5]   =  num[11,1]  ;
     var[6]   =  num[12,1]  ;

     var[7]   =  num[7  ,2] ;
     var[8]   =  num[8  ,2] ;
     var[9]   =  num[9  ,2] ;
     var[10]  =  num[10 ,2] ;
     var[11]  =  num[11 ,2] ;
     var[12]  =  num[12 ,2] ;

     var[13]  = num[7  ,3] ;
     var[14]  = num[8  ,3] ;
     var[15]  = num[9  ,3] ;
     var[16]  = num[10 ,3] ;
     var[17]  = num[11 ,3] ;
     var[18]  = num[12 ,3] ;

     var[19]  = num[7  ,4] ;
     var[20]  = num[8  ,4] ;
     var[21]  = num[9  ,4] ;
     var[22]  = num[10 ,4] ;
     var[23]  = num[11 ,4] ;
     var[24]  = num[12 ,4] ;
   output;

   keep x1-x6 w1-w6 z1-z6 r1-r6;

run;quit;


  *
  utl_numary(have) generates

  [12,3] (10,11,13,
          17,17,12,
          19,18,12,
          12,12,12,
          16,15,14,
          16,17,17,
          11,11,11,
          12,13,14,
          19,19,18,
          17,17,16,
          16,15,16,
          14,16,14)
  ;









run;quit;







  (111,10,11,13,15,111,17,17,12,10,111,19,18,12,12,111,12,12,12,13,111,16,15,14,18,111,16,17,17,18,222,11,11,11,11,222,12,13,14,11,222,19,19,18,16,222,17,17,16,15,222,16,15,
  16,16,222,14,16,14,13)





run;quit;
























































































































|
Data have;
input ID I X W Z R;   %utl_transpose(      ID X1 W1 Z1 R1 X2 W2 Z2 R2 X3 W3 Z3 R3 X4 W4 Z4 R4 X5 W5 Z5 R5 X6 W6 Z6 R6
cards4;                data=have
111 1 10 11 13 15       ,out=want          111 10 11 13 15 17 17 12 10 19 18 12 12 12 12 12 13 16 15 14 18 16 17 17 18
111 2 17 17 12 10      ,by=id              222 11 11 11 11 12 13 14 11 19 19 18 16 17 17 16 15 16 15 16 16 14 16 14 13
111 3 19 18 12 12      ,var=X W Z R );
111 4 12 12 12 13
111 5 16 15 14 18
111 6 16 17 17 18
222 1 11 11 11 11
222 2 12 13 14 11
222 3 19 19 18 16
222 4 17 17 16 15
222 5 16 15 16 16
222 6 14 16 14 13
;;;;
Run;quit;

%utl_transpose(
  data=have
 ,out=want
 ,by=id
 ,var=X W Z R );


proc transpose
 data=have out=tall;
  by id i;
  var x -- r ;
run;

proc transpose
  data=tall
  out=want(
    drop=_name_);
  by id ;
  id _name_ i;
  var col1 ;
run;




 ID X1 W1 Z1 R1 X2 W2 Z2 R2 X3 W3 Z3 R3 X4 W4 Z4 R4 X5 W5 Z5 R5 X6 W6 Z6 R6

111 10 11 13 15 17 17 12 10 19 18 12 12 12 12 12 13 16 15 14 18 16 17 17 18
222 11 11 11 11 12 13 14 11 19 19 18 16 17 17 16 15 16 15 16 16 14 16 14 13





proc transpose date=have;
by id;
id monindex;
var X W Z R Q Y;
run;quit;

%utl_transpose(







data have;
  informat name $5.;
  format name $5.;
  input year name height weight;
  cards;
2013 Dick 6.1 185
2013 Tom  5.8 163
2013 Harry 6.0 175
2014 Dick 6.1 180
2014 Tom  5.8 160
2014 Harry 6.0 195
;

data order;
  informat name $5.;
  format name $5.;
  input name order;
  cards;
Tom   1
Dick  2
Harry 3
;

%utl_transpose(data=have, out=want, by=year, id=name, guessingrows=1000,
 delimiter=_, var=height weight, var_first=no, preloadfmt=order)




https://communities.sas.com/t5/SAS-Programming/long-to-wide-for-multiple-varaibles/m-p/955070#M372997



Data have;
input CustID YYYYMM monIndex  X W Z R Q Y ;
cards;
111 202401 1 10 11 13 15 19 1
111 202402 2 17 17 12 10 18 0
111 202403 3 19 18 12 12 11 0
111 202404 4 12 12 12 13 14 1
111 202405 5 16 15 14 18 17 1
111 202406 6 16 17 17 18 15 0
222 202401 1 11 11 11 11 11 0
222 202402 2 12 13 14 11 16 0
222 202403 3 19 19 18 16 19 1
222 202404 4 17 17 16 15 18 1
222 202405 5 16 15 16 16 17 0
222 202406 6 14 16 14 13 17 0
;
proc sql noprint;
select distinct catt('have(where=(monIndex=',monIndex,') rename=(X=X',monIndex,' W=W',monIndex,' Z=Z',monIndex,' R=R',monIndex,' Q=Q',monIndex,' Y=Y',monIndex,'))')
 into :merge separated by ' '
 from have ;
quit;
data want;
merge &merge.;
by CustId;
drop YYYYMM monIndex;
run;


Data have;
input ID  X W Z R Q Y ;
cards4;
111 10 11 13 15 19 1
111 17 17 12 10 18 0
111 19 18 12 12 11 0
111 12 12 12 13 14 1
111 16 15 14 18 17 1
111 16 17 17 18 15 0
222 11 11 11 11 11 0
222 12 13 14 11 16 0
222 19 19 18 16 19 1
222 17 17 16 15 18 1
222 16 15 16 16 17 0
222 14 16 14 13 17 0
;;;;
run;quit;

%utl_transpose(data=have, out=want, by=id,  var=X W Z R Q Y);

proc sql noprint;
select distinct catt('have(where=(monIndex=',monIndex,') rename=(X=X',monIndex,' W=W',monIndex,' Z=Z',monIndex,' R=R',monIndex,' Q=Q',monIndex,' Y=Y',monIndex,'))')
 into :merge separated by ' '
 from have ;
quit;
data want;
merge &merge.;
by CustId;
drop YYYYMM monIndex;
run;


CUSTID  X1  W1  Z1  R1  Q1  Y1  X2  W2  Z2  R2  Q2  Y2  X3  W3  Z3  R3  Q3  Y3  X4  W4  Z4  R4  Q4  Y4  X5  W5  Z5  R5  Q5  Y5  X6  W6  Z6  R6  Q6  Y6

  111   10  11  13  15  19   1  17  17  12  10  18   0  19  18  12  12  11   0  12  12  12  13  14   1  16  15  14  18  17   1  16  17  17  18  15   0
  222   11  11  11  11  11   0  12  13  14  11  16   0  19  19  18  16  19   1  17  17  16  15  18   1  16  15  16  16  17   0  14  16  14  13  17   0




Data have;
input CustID YYYYMM monIndex  X W Z R Q Y ;
cards;
111 202401 1 10 11 13 15 19 1
111 202402 2 17 17 12 10 18 0
111 202403 3 19 18 12 12 11 0
111 202404 4 12 12 12 13 14 1
111 202405 5 16 15 14 18 17 1
111 202406 6 16 17 17 18 15 0
222 202401 1 11 11 11 11 11 0
222 202402 2 12 13 14 11 16 0
222 202403 3 19 19 18 16 19 1
222 202404 4 17 17 16 15 18 1
222 202405 5 16 15 16 16 17 0
222 202406 6 14 16 14 13 17 0
;
Run


proc transpose data=have out=tall;
  by custid yyyymm monIndex;
  var x -- y ;
run;

proc transpose data=tall  out=want(drop=_name_);
  by custid ;
  id _name_ monindex;
  var col1 ;
run;























proc transpose data=have out=want prefix=Month_;
by CustID ;
ID monIndex  ;
Var X W Z R Q Y;
Run;


























%let pgm=utl-sas-viya-python-code-works-in-classic-sas;

%stop_submission;

sas viya python code works in classic sas

github
https://tinyurl.com/4v8wp2y6
https://github.com/rogerjdeangelis/utl-sas-viya-python-code-works-in-classic-sas

sas communities
https://tinyurl.com/ybxv49f7
https://communities.sas.com/t5/SAS-Programming/Proc-Python-pandas-error-on-sas-viya-4/m-p/956098#M373358

/***********************************************************************************************************************************/
/*                                                          |                                          |                           */
/*          INPUT                                           |                                          |                           */
/*  INTERNAL TO PYTHON SCRIPT                               | BASE SAS DROPDOWN TO PYTHON              |                           */
/*  =========================                               | ============================             |                           */
/*                                                          |                                          |                           */
/*                                                          |                                          |                           */
/*  want = pd.DataFrame({                                   | proc datasets lib=sd1 nolist nodetails;  | SD1.WANT                  */
/*  "A": 1.0,                                               |  delete pywant;                          |                           */
/*  "B": pd.Timestamp("20130102"),                          | run;quit;                                | A    B     C D   E    F   */
/*  "C": pd.Series(1,index=list(range(4)),dtype="float32"), |                                          |                           */
/*  "D": np.array([3]*4,dtype="int32"),                     | %utl_pybeginx;                           | 1 01/02/13 1 3 test  foo  */
/*  "E": pd.Categorical(["test","train","test","train"]),   | parmcards4;                              | 1 01/02/13 1 3 train foo  */
/*  "F": "foo"                                              | exec(open('c:/oto/fn_python.py').read());| 1 01/02/13 1 3 test  foo  */
/*  })                                                      | import pandas as pd                      | 1 01/02/13 1 3 train foo  */
/*                                                          | import numpy as np                       |                           */
/*                                                          |                                          --------------              */
/*  <class 'pandas.core.frame.DataFrame'>                   | want = pd.DataFrame({                                  |             */
/*  Index: 4 entries, 0 to 3                                | "A": 1.0,                                              |             */
/*  Data columns (total 6 columns):                         | "B": pd.Timestamp("20130102"),                         |             */
/*   #   Column  Non-Null Count  Dtype                      | "C": pd.Series(1,index=list(range(4)),dtype="float32"),|             */
/*  ---  ------  --------------  -----                      | "D": np.array([3]*4,dtype="int32"),                    |             */
/*   0   A       4 non-null      float64                    | "E": pd.Categorical(["test","train","test","train"]),  |             */
/*   1   B       4 non-null      datetime64[s] (series)     | "F": "foo"                                             |             */
/*   2   C       4 non-null      float32                    | })                                                     |             */
/*   3   D       4 non-null      int32                      |                                                        |             */
/*   4   E       4 non-null      category                   | print(want);                                           |             */
/*   5   F       4 non-null      object                     | fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant');     |             */
/*                                                          | ;;;;                                                   |             */
/*   SOAPBOX ON                                             | %utl_pyendx;                                           |             */
/*                                                          |                                                        |             */
/*    Note all the datatypes, this                          |                                                        |             */
/*    can cause all kinds of downstream problems?           | proc print data=sd1.pywant heading=vertical;           |             */
/*                                                          | run;quit;                                              |             */
/*   SOAPBOX OFF                                            |                                                        |             */
/*                                                          |                                                        |             */
/***********************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/


Pease provide a reproducible example of the Baker/Wurgler value weighted divedend premuium usig r language
Pease provide a reproducible example of the Baker/Wurgler value weighted divedend premuium usig python language
Pease provide a reproducible example of the Baker/Wurgler value weighted divedend premuium usig sas language


python
import numpy as np
import pandas as pd

# Sample data
data = {
    'Company': ['A', 'B', 'C', 'D', 'E'],
    'Market_Value': [1000, 800, 1200, 600, 1500],
    'Book_Value': [500, 400, 800, 300, 1000],
    'Dividend_Payer': [True, True, False, False, True]
}

df = pd.DataFrame(data)

# Calculate market-to-book ratio
df['M/B_Ratio'] = df['Market_Value'] / df['Book_Value']

# Separate payers and non-payers
payers = df[df['Dividend_Payer']]
non_payers = df[~df['Dividend_Payer']]

# Calculate value-weighted average M/B ratio for each group
vw_mb_payers = np.average(payers['M/B_Ratio'], weights=payers['Market_Value'])
vw_mb_non_payers = np.average(non_payers['M/B_Ratio'], weights=non_payers['Market_Value'])

# Calculate dividend premium
dividend_premium = np.log(vw_mb_payers) - np.log(vw_mb_non_payers)

print(f"Value-weighted dividend premium: {dividend_premium:.4f}")



https://www.nber.org/system/files/working_papers/w9995/w9995.pdf
https://www.biz.uiowa.edu/faculty/elie/CateringJFE.pdf
https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=a5a3857c2fa2c0daff867ed148a209b2b3b52dbd


# Load required libraries
library(dplyr)
library(tidyr)

# Create sample data
set.seed(123)
data <- data.frame(
  year = rep(2000:2004, each = 100),
  firm = rep(1:100, 5),
  dividend_payer = sample(c(TRUE, FALSE), 500, replace = TRUE),
  market_value = rnorm(500, mean = 1000, sd = 200),
  book_value = rnorm(500, mean = 800, sd = 150)
)

# Calculate market-to-book ratio
data$market_to_book <- data$market_value / data$book_value

# Calculate value-weighted average market-to-book ratio for payers and non-payers
vw_mb <- data %>%
  group_by(year, dividend_payer) %>%
  summarize(
    vw_mb = weighted.mean(market_to_book, market_value),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = dividend_payer, values_from = vw_mb) %>%
  rename(payers = "TRUE", non_payers = "FALSE")

# Calculate dividend premium
vw_mb$dividend_premium <- log(vw_mb$payers) - log(vw_mb$non_payers)

# Display results
print(vw_mb)
