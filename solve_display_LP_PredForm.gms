* here you need to extract the exact basis linked to that iteration given the results of the MTD.
Sens(i1)=sum((ii1,cuts)$(eta_p(cuts) > 0),IB(i1,ii1,cuts)*b(ii1));

* first need to map i1 to the relevant j1.
* Matrix Base created in TIMES(Aug) has the mapping on the diagonal.
counter=0;

ne_cur = sum(cuts$(eta_p(cuts) > 0), ne_vec(cuts))

loop(j1$(y(j1)),
counter=counter+1;
*yout(j1)=sum(i1$(ord(i1)=ne+counter),Sens(i1));
yout(j1)=sum(i1$(ord(i1)=ne_cur+counter),Sens(i1));
);


*SOLVE TIMES_simple MINIMIZING OBJz using LP ;

* then map j1 to the relevant variables in the model.
* update the variables of interest out of the solution from the Sensitivity

VAR_ACT_p(R,V,T,P,S)=sum(j1$(VAR_ACT_VM(j1,R,V,T,P,S)),yout(j1));
EQG_COMBAL_p(R,T,Com,S)=sum(i1$EQG_COMBAL_EM(i1,R,T,Com,S),duale(i1) );
OBJZ_p=-Sens("e1");

*execute_unload "upresTIMES.gdx" x,yout,eout,Sens,qx,y,VAR_ACT_p,EQG_COMBAL_p,duale;


        COST_("ELE",t) =

                    EQG_COMBAL_p("REGION1",t,"EL-DEMAND","ANNUAL")
                   *VAR_ACT_p("REGION1",t,t,"ELE-DEM","ANNUAL") ;
        COST_("GAS",t) =
                    EQG_COMBAL_p("REGION1",t,"NATGAS","ANNUAL")
                   *VAR_ACT_p("REGION1",t,t,"GASPROD","ANNUAL")  ;
        COST_tot(t) =  COST_("ELE",t) + COST_("GAS",t) ;

        COST_shr("ELE",t) = COST_("ELE",t) / COST_tot(t);
        COST_shr("GAS",t) = COST_("GAS",t) / COST_tot(t);

        io("GAS","ELE") =
           ( VAR_ACT_p("REGION1","2020","2020","GASPOWER","ANNUAL")
            )
            /
            (  VAR_ACT_p("REGION1","2020","2020","ELE-DEM","ANNUAL")
            ) ;

        y0ge=io("GAS","ELE")*XD.L("ELE");

REPORT("%run%",iter_out,"U","_")=U;
REPORT("%run%",iter_out,"OBJZ","_")=OBJZ_p;
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

VAR_ACT_iter("%run%",iter_out,t,p)=VAR_ACT_p("REGION1",t,t,p,"ANNUAL");

*DISPLAY REPORT;
