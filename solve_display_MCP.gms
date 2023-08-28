* the CGE model is ONLY solved - there is no inserting of the whole routine here. So the io("GAS","ELE") is not reinitialized in the CGE model.
Solve CGE_link_MTD USING MCP;
* i need this as a parameter to put it as a condition in the code
eta_p(iter_out)=0;
eta_p(cuts)=eta.l(cuts);

display eta.L;
display eta_p;
*display cuts$(eta(cuts));

        U = prod( sec, (C.L(sec) - muH(sec))**alphaHLES(sec) ) ;
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
