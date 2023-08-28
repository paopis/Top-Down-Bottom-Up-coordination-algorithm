*Define years as numbers
nYear("2009")=2009;
nYear("2010")=2010;
nYear("2011")=2011;
nYear("2012")=2012;
nYear("2013")=2013;
nYear("2014")=2014;
nYear("2015")=2015;
nYear("2016")=2016;
nYear("2017")=2017;
nYear("2018")=2018;
nYear("2019")=2019;
nYear("2020")=2020;
nYear("2021")=2021;
nYear("2022")=2022;
nYear("2023")=2023;
nYear("2024")=2024;
nYear("2025")=2025;
nYear("2026")=2026;
nYear("2027")=2027;
nYear("2028")=2028;
nYear("2029")=2029;
nYear("2030")=2030;
nYear("2031")=2031;
nYear("2032")=2032;
nYear("2033")=2033;
nYear("2034")=2034;
nYear("2035")=2035;
nYear("2036")=2036;
nYear("2037")=2037;
nYear("2038")=2038;
nYear("2039")=2039;
nYear("2040")=2040;
nYear("2041")=2041;
nYear("2042")=2042;
nYear("2043")=2043;
nYear("2044")=2044;
nYear("2045")=2045;
nYear("2046")=2046;
nYear("2047")=2047;
nYear("2048")=2048;
nYear("2049")=2049;
nYear("2050")=2050;
nYear("2051")=2051;
nYear("2052")=2052;
nYear("2053")=2053;
nYear("2054")=2054;
nYear("2055")=2055;
nYear("2056")=2056;
nYear("2057")=2057;
nYear("2058")=2058;
nYear("2059")=2059;
nYear("2060")=2060;

*Investment cost for new capacity
NCAP_COST("REGION1",V, "EL-HYDRO") = 12200;  !! kNOK/MW 50years
NCAP_COST("REGION1",V, "GASPOWER") = 3200;   !! kNOK/MW 25years
NCAP_COST("REGION1",V, "NGASBURN") =   46.3; !! kNOK/GWh/a 25years
NCAP_COST("REGION1",V, "ELHEATER") = 2100;   !! kNOK/GWh/a 25years
NCAP_COST("REGION1","2016", "EL-HYDRO") =  22200;  !! kNOK/MW 50years
NCAP_COST("REGION1","2017", "EL-HYDRO") =  22200;  !! kNOK/MW 50years
NCAP_COST("REGION1","2018", "EL-HYDRO") =  22200;  !! kNOK/MW 50years
NCAP_COST("REGION1","2019", "EL-HYDRO") =  22200;  !! kNOK/MW 50years
NCAP_COST("REGION1","2020", "EL-HYDRO") =  22200;  !! kNOK/MW 50years

*Fixed operating and maintenance cost
NCAP_FOM("REGION1",V, "EL-HYDRO")  = 205.23; !! kNOK/MW
NCAP_FOM("REGION1","2020", "EL-HYDRO")  = 2300; !! kNOK/MW
NCAP_FOM("REGION1",V, "GASPOWER") =  96   ;  !! kNOK/MW
NCAP_FOM("REGION1",V, "NGASBURN") =   3.8 ;  !! kNOK/GWh/a
NCAP_FOM("REGION1",V, "ELHEATER") =   2   ;  !! kNOK/GWh/a

*Variable cost associated with activity
ACT_COST("REGION1",V, "EL-HYDRO")  = 4.37;   !! kNOK/GWh

*Cost on production of a commodity (2010: 153, 2020:225)
COM_CSTPRD("REGION1",     V ,"NATGAS") = 130; !! 225;  !! kNOK/GWh
COM_CSTPRD("REGION1", "2010","NATGAS") = 153; !! 153;  !! kNOK/GWh

*Availability of capacity
NCAP_AF("REGION1",P,"ANNUAL") = 1;
NCAP_AF("REGION1","EL-HYDRO","ANNUAL") = 0.95;

*Relationship between 2 groups of flows
FLO_FUNC(R,T,P,C1,C2,S)=0;
FLO_FUNC(R,T,"EL-HYDRO","HYDROR","ELC",S)=1;
FLO_FUNC(R,T,"GASPOWER","NATGAS","ELC",S)= 0.4;
FLO_FUNC(R,T,"NGASBURN","NATGAS","LTH",S)= 0.95;
FLO_FUNC(R,T,"ELHEATER","ELC","LTH",S)   = 1;
FLO_FUNC(R,T,"ELE-DEM","ELC","EL-DEMAND",S)= 1;
FLO_FUNC(R,T,"HEAT-DEM","LTH","HEAT-DEMAND",S)= 1;
FLO_FUNC(R,T,"GASPROD",C1,C2,S)=0;

*Capacity to activity conversion factor
PRC_CAPACT("REGION1",P) = 1;
PRC_CAPACT("REGION1","EL-HYDRO") = 8.76;     !! MW --> GWh
PRC_CAPACT("REGION1","GASPOWER") = 8.76;     !! MW --> GWh

*Topology
TOP_IN("REGION1","EL-HYDRO" ,"HYDROR") = 1;
TOP_IN("REGION1","ELE-DEM" ,"ELC")    = 1;
TOP_IN("REGION1","GASPOWER","NATGAS") = 1;
TOP_IN("REGION1","HEAT-DEM" ,"LTH")    = 1;
TOP_IN("REGION1","NGASBURN","NATGAS") = 1;
TOP_IN("REGION1","ELHEATER","ELC")    = 1;

*Topology
TOP_OUT("REGION1","EL-HYDRO" ,"ELC")       = 1;
TOP_OUT("REGION1","ELE-DEM" ,"EL-DEMAND") = 1;
TOP_OUT("REGION1","GASPOWER","ELC")       = 1;
TOP_OUT("REGION1","GASPROD" ,"NATGAS")    = 1;
TOP_OUT("REGION1","HEAT-DEM" ,"HEAT-DEMAND")= 1;
TOP_OUT("REGION1","NGASBURN","LTH")       = 1;
TOP_OUT("REGION1","ELHEATER","LTH")       = 1;

*Salvage value of investment cost, invested in year V, salvage value share by 2021
coeff_salv("REGION1", V    , "EL-HYDRO") = (nYear(V) +50 -2021) / 50 ;
coeff_salv("REGION1", V    , "GASPOWER") = (nYear(V) +25 -2021) / 25 ;
coeff_salv("REGION1", V    , "NGASBURN") = (nYear(V) +25 -2021) / 25 ;
coeff_salv("REGION1", V    , "ELHEATER") = (nYear(V) +25 -2021) / 25 ;
*display coeff_salv;

*Fixed costs
*coeff_fix(R, V    ,P)=   16   *NCAP_FOM(R,"2010",P);
*coeff_fix(R,"2020",P)=    5.55*NCAP_FOM(R,"2010",P)   + 4.95*NCAP_FOM(R,"2020",P);

*Variable costs from activity
*coeff_actcost(R, V    ,P)=  6 * ACT_COST(R,"2010",P);
*coeff_actcost(R,"2020",P)= 10 * ACT_COST(R,"2020",P);

*Variable costs from commodity production
*coeff_cstprd(R,  V   ,C)= 4.5 *COM_CSTPRD(R,"2010",C) + 1.5 *COM_CSTPRD(R,"2020",C);
*coeff_cstprd(R,"2020",C)= 1   *COM_CSTPRD(R,"2010",C) + 9   *COM_CSTPRD(R,"2020",C);

*Capacity installed prior to study years
NCAP_PASTI("REGION1","2010","EL-HYDRO") = 0;       !! *8.76
NCAP_PASTI("REGION1","2020","EL-HYDRO") = 0 *9/10; !! *8.76
NCAP_PASTI("REGION1","2010","GASPOWER") =  0.0;       !! *8.76
NCAP_PASTI("REGION1","2020","GASPOWER") =  0.0 *9/10; !! *8.76

*Bound on level of investment in new capacity in a period
NCAP_BND(R,T,"EL-HYDRO")= .1  ;
NCAP_BND(R,"2009","EL-HYDRO")= 2;
NCAP_BND(R,"2013","EL-HYDRO")= 0.01;
NCAP_BND(R,"2014","EL-HYDRO")= 0.01;
NCAP_BND(R,"2015","EL-HYDRO")= 0.001;
NCAP_BND(R,"2016","EL-HYDRO")= 0.001;
NCAP_BND(R,"2017","EL-HYDRO")= 0.001;
NCAP_BND(R,"2018","EL-HYDRO")= 0.001;
NCAP_BND(R,"2019","EL-HYDRO")= 0.001;
NCAP_BND(R,"2020","EL-HYDRO")= 0.001;
*NCAP_BND(R,"2010","GASPOWER")= 10  ;
*NCAP_BND(R,"2020","GASPOWER")= 11.1;

*Demand baseline projection
COM_PROJ(R, T    ,"HEAT-DEMAND") = (      4  + 2  + 3 + 1 + [1.0*(nYear(T)-2010)/1000]) / 0.7 ;
COM_PROJ(R, T    ,"EL-DEMAND")   = ( 1  + 1  + 7  + 8 + 5 + [2.2*(nYear(T)-2010)/1000]) / 1.0 ;

*COM_PROJ(R,"2020","HEAT-DEMAND") = 2*1.05 + 3*1.10 + (1+3)*1.11;
*COM_PROJ(R,"2020","EL-DEMAND")   = 1*0.9  + 1*1.1  +    7 *1.11 + 6*1.4 + 2*1.1;




*Social Accounting Matrix (SAM):
*        GAS     ELE     MAN     NON     L       K       HOU     |tot
*GAS              4       2       3                       1      | 10
*ELE      1       1       7       8                       5      | 22
*MAN      1       3       6      26                       2      | 38
*NON      5      10      10      30                      92      |147
*L        1       1       5      53                              | 60
*K        2       3       8      27                              | 40
*HOU                                     60      40              |100
*----------------------------------------------------------------+
*tot     10      22      38      147     60      40      100
