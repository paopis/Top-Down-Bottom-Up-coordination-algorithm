* the TIMES model is ONLY solved - there is no inserting of the whole routine here. So the io("GAS","ELE") is not reinitialized in the CGE model.
SOLVE TIMES_simple MINIMIZING OBJz using LP ;

$include C:\Users\pisciell.WIN-NTNU-NO\Desktop\TDBU\SmallLinkExp\OutBasis.gms


*        U = prod( sec, (C.L(sec) - muH(sec))**alphaHLES(sec) ) ;

        COST_("ELE",t) =
                    EQG_COMBAL.M("REGION1",t,"EL-DEMAND","ANNUAL")
                   *VAR_ACT.L("REGION1",t,t,"ELE-DEM","ANNUAL") ;
        COST_("GAS",t) =
                    EQG_COMBAL.M("REGION1",t,"NATGAS","ANNUAL")
                   *VAR_ACT.L("REGION1",t,t,"GASPROD","ANNUAL")  ;
        COST_tot(t) =  COST_("ELE",t) + COST_("GAS",t) ;

        COST_shr("ELE",t) = COST_("ELE",t) / COST_tot(t);
        COST_shr("GAS",t) = COST_("GAS",t) / COST_tot(t);

        io("GAS","ELE") =
           ( VAR_ACT.L("REGION1","2020","2020","GASPOWER","ANNUAL")
            )
            /
            (  VAR_ACT.L("REGION1","2020","2020","ELE-DEM","ANNUAL")
            ) ;

        y0ge=io("GAS","ELE")*XD.L("ELE");

REPORT("%run%",iter_out,"U","_")=U;
REPORT("%run%",iter_out,"OBJZ","_")=OBJZ.L;
REPORT("%run%",iter_out,"HOU",I)=C.L(I);
REPORT("%run%",iter_out,"P_",I)=PD.L(I);
REPORT("%run%",iter_out,"PF","K")=PK.L;
REPORT("%run%",iter_out,"PF","L")=PL.L;
REPORT("%run%",iter_out,"Y_O",I)=XD.L(I);
REPORT("%run%",iter_out,"COST_ele",t)=COST_("ELE",t);
REPORT("%run%",iter_out,"COST_gas",t)=COST_("GAS",t);
REPORT("%run%",iter_out,"CSHR_ele",t)=COST_shr("ELE",t);
REPORT("%run%",iter_out,"CSHR_gas",t)=COST_shr("GAS",t);
REPORT("%run%",iter_out,"D_mult","_")=D_mult;
REPORT("%run%",iter_out,"Y0ge","_")=io("GAS","ELE")*XD.L("ELE");

VAR_ACT_iter("%run%",iter_out,t,p)=VAR_ACT.L("REGION1",t,t,p,"ANNUAL");

*DISPLAY REPORT;
