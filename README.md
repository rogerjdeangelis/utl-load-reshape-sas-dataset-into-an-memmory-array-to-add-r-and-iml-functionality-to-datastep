# utl-load-reshape-sas-dataset-into-an-memmory-array-to-add-r-and-iml-functionality-to-datastep
Load reshape sas dataset into in memory array to add matrix functionality to the datastep like r and iml
    %let pgm=utl-load-reshape-sas-dataset-into-an-memmory-array-to-add-r-and-iml-functionality-to-datastep;

    %stop_submission;

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
