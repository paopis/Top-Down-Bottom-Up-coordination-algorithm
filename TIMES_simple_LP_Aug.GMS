$TITLE SimplifiedTIMES
$ontext
         ==============================================================
         =                                                            =
         =                  Simplified TIMES model                    =
         =                                                            =
         =                            by                              =
         =          Per Ivar Helgesen and Paolo Pisciella             =
         =                         Aug 2021                           =
         =                                                            =
         ==============================================================

The TIMES model consists of:

Goal
        Minimize Costs = investment costs + fixed costs + variable costs - salvage values
such that
        Process activity <= Capacity
        Supply >= Use
        Commodity production = Commodity processing

Simplifications: Discount rate is 0, and time periods are given --> can sum directly over years.

The LP-model is reformulated as an LCP-model (linear complementarity problem).

$offtext
$oneolcom

option lp=convertd;
option decimals=4;
Sets
        r            regions        / REGION1 /
        years        time periods   / 2009*2060 /
        byear(years) baseyear       / 2010 /
        hyear(years) horizon year   / 2020 /
        t(years)     time periods   / 2009*2020 /
        s            timeslice      / ANNUAL /
        CUR          currency       / CUR /

        p            process        / EL-HYDRO, GASPROD, GASPOWER, NGASBURN, ELHEATER, ELE-DEM, HEAT-DEM/
        p_dem(p)     demand         / ELE-DEM, HEAT-DEM /
        p_prod(p)    production     / EL-HYDRO, GASPOWER, NGASBURN, ELHEATER /
        p_sup(p)     supply         / GASPROD /

        com          commodities    / NATGAS, HYDROR, ELC, LTH, EL-DEMAND, HEAT-DEMAND /
        c_dem(com)   demand         / EL-DEMAND, HEAT-DEMAND /
        c_prod(com)  production     / NATGAS, ELC, LTH /
        c_sup(com)   supply         / HYDROR /
;
ALIAS
        (t, v, vv)    !!         v = vintage periods
        (com, C1, C2)        !! commodities in and out, used by FLO_FUNC
;

PARAMETERS
        nYear(years)         year as number

        NCAP_COST(R,V,P)     investmentcost
        NCAP_BND(R,V,P)      bound on investment (upper)
        ACT_COST(R,V,P)      activity cost
        NCAP_PASTI(R,V,P)    capacity from past years
        NCAP_FOM(R,V,P)      Operating and maintenance cost
        coeff_salv(R,V,P)    salvage values into objective
*       coeff_fix(R,V,P)     fixed costs into objective
*       coeff_actcost(R,V,P) variable costs into objective
*       coeff_cstprd(R,V,C)  variable costs into objective

        TOP_IN(R,P,Com)         Topology - input commodity to process
        TOP_OUT(R,P,Com)        Topology - output commodity from process

        NCAP_AF(R,P,S)          Availability of capacity (ex:EL-HYDRO=0.95)
        PRC_CAPACT(R,P)         Capacity-to-Activity conversion factor MW->GWh
        FLO_FUNC(R,T,P,C1,C2,S) Conversion factor for process producing commodity2 from commodity1

        COM_CSTPRD(R,T,Com)     Cost on production of a commodity
        COM_PROJ(R,T,Com)       Demand baseline projection
;

$INCLUDE C:\Users\pisciell.WIN-NTNU-NO\Desktop\TDBU\SmallLinkExp\parameter_values.gms


POSITIVE VARIABLES
  VAR_ACT(R,V,T,P,S )                Overall activity of a process       [7x2]
  VAR_NCAP(R,V,P )                   New capacity of a process           [4x2]
  VAR_COMPRD(R,T,Com,S )             Total production or consumption of a commodity [1x2]
;

VARIABLES
  OBJz           total discounted system cost
;
EQUATIONS
  EQ_OBJ
  EQL_CAPACT(R,V,T,P,S)  Capacity Utilization
  EQG_COMBAL(R,T,Com,S)  Commodity Balance
  EQE_COMPRD(R,T,Com,S)  Commodity Production Limit
  EQ_NCAP_UPPERB(R,V,P)  Upper bounds on VAR_NCAP
;


* Objective function: Total costs = investment costs + fixed costs + variable costs - salvage values
* Have to balance the investment costs towards variable costs in the shadow prices;
*   divides down to yearly comparable numbers.
EQ_OBJ..        -OBJZ
                + SUM((R,CUR,V,P),                     NCAP_COST(R,V,P) * VAR_NCAP(R,V,P) )  !! "OBJINV" investment costs
                - SUM((R,CUR,V,P), coeff_salv(R,V,P) * NCAP_COST(R,V,P) * VAR_NCAP(R,V,P) )  !! "OBJSAL" salvage value
                + SUM((R,CUR,V,P),
                         sum(t$(ord(t)>=ord(v)), NCAP_FOM(R,V,P) * VAR_NCAP(R,V,P) ) )                        !! "OBJFIX" fixed yearly costs
                + SUM((R,CUR,S  ),                                                           !! "OBJVAR" variable costs
                         sum((T,P),                     ACT_COST(R,T,P) * VAR_ACT(R,T,T,P,S) )
                        +sum((T,Com),               COM_CSTPRD(R,T,Com)  * VAR_COMPRD(R,T,Com,S) )  )
                =E= 0 ;

* Capacity utilization: Process activity <= Capacity
* Process activity < capacity availability factor * conversion factor * capacity   (both existing and new capacity)
EQL_CAPACT(R,T,T,P_prod,S) ..  -(VAR_ACT(R,T,T,P_prod,S)
                                - SUM(vv$(ORD(vv)<=ORD(T)),
                                  NCAP_AF(R,P_prod,S)*PRC_CAPACT(R,P_prod)*VAR_NCAP(R,vv,P_prod) )
                                - NCAP_AF(R,P_prod,S)*PRC_CAPACT(R,P_prod)*NCAP_PASTI(R,"2010",P_prod))
                                =G= 0 ; !! Cheats on vintage here

* Supply of commodity >= Use of commodity
* Supply could be: from import, production based on activity, production based on capacity
* Use could be: demand, use by activity, use by capacity, export
* TIMES includes VAR_COMPRD(R,T,C,S) here, I use corresponding VAR_ACT instead.
EQG_COMBAL(R,T,Com,S)$(not C_SUP(Com)) .. -((-1)*sum(P, TOP_OUT(R,P,Com)*VAR_ACT(R,T,T,P,S) )
                        + sum((P,c2)$(FLO_FUNC(R,T,P,Com,C2,S)>0),
                          TOP_IN(R,P,Com) * VAR_ACT(R,T,T,P,S)/FLO_FUNC(R,T,P,Com,C2,S) )
                        + COM_PROJ(R,T,Com))
                        =G= 0;  !! COM_PROJ is the final demand

* Commodity production must correspond with process activities
EQE_COMPRD(R,T,Com,S)$(COM_CSTPRD(R,T,Com)>0) .. -sum(P, TOP_OUT(R,P,Com)*VAR_ACT(R,T,T,P,S)) =E= -VAR_COMPRD(R,T,Com,S) ;

* Define upper bounds - parameter NCAP_BND.
EQ_NCAP_UPPERB(R,V,P)$(NCAP_BND(R,V,P)>0) ..   -(VAR_NCAP(R,V,P) - NCAP_BND(R,V,P)) =G= 0 ;

*option iterlim=0;
option limrow=99;
option limcol=99;
MODEL TIMES_simple / EQ_OBJ,
                     EQL_CAPACT, EQG_COMBAL, EQE_COMPRD,
                     EQ_NCAP_UPPERB
/;

* Get rid of unwanted variables
VAR_COMPRD.fx(R,T,Com,S )=0;
VAR_COMPRD.up(R,T,Com,S)$(COM_CSTPRD(R,T,Com)>0) = +INF;
TIMES_SIMPLE.HOLDFIXED=1;



TIMES_simple.optfile=1;
SOLVE TIMES_simple MINIMIZING OBJz using LP ;



set i1,j1;
* Build the tableau out of the Jacobian
* a) include the initial Matrix
parameter A(i1,*) tableau;
$gdxin jacobian.gdx
$load i1 =i
$load j1 =j
$load A
$gdxin


* These parameters are taken from "dictmap.gdx" that links the original indices with the general indices.
parameters
* variables mapping between j and all the original indices
         VAR_ACT_VM(j1,R,V,T,P,S ),
         VAR_NCAP_VM(j1,R,V,P ),
         VAR_COMPRD_VM(j1,R,T,Com,S ),
* equations mapping between i and all the original indices
         EQL_CAPACT_EM(i1,R,V,T,P,S),
         EQG_COMBAL_EM(i1,R,T,Com,S),
         EQE_COMPRD_EM(i1,R,T,Com,S),
         EQ_NCAP_UPPERB_EM(i1,R,V,P);

execute_load 'dictmap.gdx' VAR_ACT_VM,VAR_NCAP_VM,VAR_COMPRD_VM, EQL_CAPACT_EM,EQG_COMBAL_EM,EQE_COMPRD_EM,EQ_NCAP_UPPERB_EM;


alias(i1,ii1);
alias(j1,jj1);
parameter Tab(i1,*),Slack(i1,ii1);
Slack(i1,ii1)=0;
*EQE are the equality constraints, for which we do not need to define slack variables for the Tableau
Slack(i1,ii1)$(ord(i1)=ord(ii1) and not sum((R,T,Com,S),EQE_COMPRD_EM(i1,R,T,Com,S)))=1;
Tab(i1,j1)=A(i1,j1);
Tab(i1,ii1)=Slack(i1,ii1);
* Tab is the LP TABLEAU

option lp=cplex;

TIMES_simple.optfile=0;

$exit
SOLVE TIMES_simple MINIMIZING OBJz using LP ;


* dual values for the variables and equations
* the variables are mapped between the original indices (R,V,T,P,S etc...)
* and the general ones (i,j) to have everything written as variables x_j and equation e_i
* VM parameters are variable mappings and EM parameters are equation mappings
* they come from dictmap.gdx, which is created using convertd and with option file convertd
parameter dualx(j1),duale(i1),x(j1);
dualx(j1)=sum((R,V,T,P,S )$(VAR_ACT_VM(j1,R,V,T,P,S)),VAR_ACT.M(R,V,T,P,S ))
+sum((R,V,P  )$(VAR_NCAP_VM(j1,R,V,P )),VAR_NCAP.M(R,V,P ))
+sum((R,T,Com,S )$(VAR_COMPRD_VM(j1,R,T,Com,S )),VAR_COMPRD.M(R,T,Com,S ));

duale(i1)=(sum((R,V,T,P,S)$EQL_CAPACT_EM(i1,R,V,T,P,S),EQL_CAPACT.M(R,V,T,P,S))
+sum((R,T,Com,S)$EQG_COMBAL_EM(i1,R,T,Com,S),EQG_COMBAL.M(R,T,Com,S))
+sum((R,T,Com,S)$EQE_COMPRD_EM(i1,R,T,Com,S),EQE_COMPRD.M(R,T,Com,S))
+sum((R,V,P)$EQ_NCAP_UPPERB_EM(i1,R,V,P),EQ_NCAP_UPPERB.M(R,V,P)));

x(j1)=sum((R,V,T,P,S )$(VAR_ACT_VM(j1,R,V,T,P,S)),VAR_ACT.L(R,V,T,P,S ))
+sum((R,V,P  )$(VAR_NCAP_VM(j1,R,V,P )),VAR_NCAP.L(R,V,P ))
+sum((R,T,Com,S )$(VAR_COMPRD_VM(j1,R,T,Com,S )),VAR_COMPRD.L(R,T,Com,S ));

parameter b(i1);
b(i1)=sum((R,V,T,P_prod,S)$EQL_CAPACT_EM(i1,R,V,T,P_prod,S),-NCAP_AF(R,P_prod,S)*PRC_CAPACT(R,P_prod)*NCAP_PASTI(R,"2010",P_prod))
+sum((R,T,Com,S)$EQG_COMBAL_EM(i1,R,T,Com,S),COM_PROJ(R,T,Com))
+sum((R,T,Com,S)$EQE_COMPRD_EM(i1,R,T,Com,S),-0)
+sum((R,V,P)$EQ_NCAP_UPPERB_EM(i1,R,V,P),-NCAP_BND(R,V,P));

set data / set.i1, set.j1 /;
alias(data,d);

parameter y(*),q(data);
q(data)=0;
y(j1)=1$(dualx(j1)=0);
y(i1)=1$(duale(i1)=0);
q(d)=sum(data$(ord(data)<=ord(d)),y(data))*y(d);




*5) Define an indicator array containing the position of the basic variables
parameter ind(*);


*6) define for decision and slack variables the index of basic variables
ind(j1)=ord(j1)$(y(j1)=1);
ind(i1)=(ord(i1))$(y(i1)=1);

*7) Define a matrix that takes the colums of the tableau corresponding to the
* basic variables

parameter Base(i1,*) Basis matrix;
parameter invb(i1,i1) Inverse basis;

loop(i1,
  loop(j1$(ord(j1)=ind(j1)),Base(i1,j1)=Tab(i1,j1))
  loop(ii1$(ord(ii1)=ind(ii1)),Base(i1,ii1)=Tab(i1,ii1))
);


* To invert the basis we need to make it run over a single index
parameter BB(i1,i1);
loop (i1,
     loop((d,ii1)$(ord(ii1)=q(d)),BB(i1,ii1)=Base(i1,d))
);


execute_unload 'basis.gdx', i1, BB;
execute '=invert.exe basis.gdx i1 BB D.gdx invb';
execute_load 'D.gdx', invb;

*execute_unload "Tableau.gdx" A,T,Base,BB,invB;

parameter Sens(i1);
Sens(i1)=sum(ii1,invb(i1,ii1)*b(ii1));

parameter test;
test=sum(i1,duale(i1)*b(i1));

execute_unload "Tableau.gdx" A,Tab,Base,BB,invB,Sens,x,b,duale,test,OBJZ.L;


PARAMETER VAL_TOT(t), VAL_SHR(*,t);
val_shr("ELE",t) = -EQG_COMBAL.M("REGION1",t,"EL-DEMAND","ANNUAL") * VAR_ACT.L("REGION1",t,t,"ELE-DEM","ANNUAL") ;
val_shr("GAS",t) = -EQG_COMBAL.M("REGION1",t,"NATGAS","ANNUAL") * VAR_ACT.L("REGION1",t,t,"GASPROD","ANNUAL")  ;
val_tot(t) =  val_shr("ELE",t) + val_shr("GAS",t) ;
val_shr("ELE",t) = val_shr("ELE",t) / val_tot(t);
val_shr("GAS",t) = val_shr("GAS",t) / val_tot(t);
