
Solve CGE_link_MTD USING MCP;
SOLVE TIMES_simple MINIMIZING OBJz using LP ;

* calcolo utilità iniziale
* costi iniziali per produzione elettricità e gas calcolati come duale X livello di attività
* calcolo di quantità di

        U = prod( sec, (C.L(sec) - muH(sec))**alphaHLES(sec) ) ;

        COST_("ELE",t) =
***                    U_COMBAL.L("REGION1",t,"EL-DEMAND","ANNUAL")
***                    EQG_KKT_COMBAL.M("REGION1",t,"EL-DEMAND","ANNUAL")
                    EQG_COMBAL.M("REGION1",t,"EL-DEMAND","ANNUAL")
                   *VAR_ACT.L("REGION1",t,t,"ELE-DEM","ANNUAL") ;
        COST_("GAS",t) =
***                    U_COMBAL.L("REGION1",t,"NATGAS","ANNUAL")
***                    EQG_KKT_COMBAL.M("REGION1",t,"NATGAS","ANNUAL")
                    EQG_COMBAL.M("REGION1",t,"NATGAS","ANNUAL")
                   *VAR_ACT.L("REGION1",t,t,"GASPROD","ANNUAL")  ;
        COST_tot(t) =  COST_("ELE",t) + COST_("GAS",t) ;

        COST_shr("ELE",t) = COST_("ELE",t) / COST_tot(t);
        COST_shr("GAS",t) = COST_("GAS",t) / COST_tot(t);

*       io("GAS","ELE") =
*          ( VAR_ACT.L("REGION1","2020","2020","GASPOWER","ANNUAL")
**           * EQG_COMBAL.M("REGION1",t,"EL-DEMAND","ANNUAL")
*           )
*           /
*           (  VAR_ACT.L("REGION1","2020","2020","ELE-DEM","ANNUAL")
**           * EQG_COMBAL.M("REGION1",t,"EL-DEMAND","ANNUAL")
*           ) ;
* at this point io is the original from the CGE model.
        y0ge=io("GAS","ELE")*XD.L("ELE");
*         y0ge=XD.L("ELE");  !! errore
* io is computed using CGE initial data (IOZ/XDZ)

* scrivo il report per il run iniziale senza linking.
REPORT("%run%","run0","U","_")=U;
REPORT("%run%","run0","OBJZ","_")=OBJZ.L;
REPORT("%run%","run0","HOU",I)=C.L(I);
REPORT("%run%","run0","P_",I)=PD.L(I);
REPORT("%run%","run0","PF","K")=PK.L;
REPORT("%run%","run0","PF","L")=PL.L;
REPORT("%run%","run0","Y_O",I)=XD.L(I);
REPORT("%run%","run0","COST_ele",t)=COST_("ELE",t);
REPORT("%run%","run0","COST_gas",t)=COST_("GAS",t);
REPORT("%run%","run0","CSHR_ele",t)=COST_shr("ELE",t);
REPORT("%run%","run0","CSHR_gas",t)=COST_shr("GAS",t);
REPORT("%run%","run0","D_mult","_")=D_mult;
REPORT("%run%","run0","Y0ge","_")=io("GAS","ELE")*XD.L("ELE");

VAR_ACT_iter("%run%","run0",t,p)=VAR_ACT.L("REGION1",t,t,p,"ANNUAL");

*DISPLAY REPORT;
