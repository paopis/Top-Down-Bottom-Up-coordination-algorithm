
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

b(i1)=sum((R,V,T,P_prod,S)$EQL_CAPACT_EM(i1,R,V,T,P_prod,S),-NCAP_AF(R,P_prod,S)*PRC_CAPACT(R,P_prod)*NCAP_PASTI(R,"2010",P_prod))
+sum((R,T,Com,S)$EQG_COMBAL_EM(i1,R,T,Com,S),COM_PROJ(R,T,Com))
+sum((R,T,Com,S)$EQE_COMPRD_EM(i1,R,T,Com,S),-0)
+sum((R,V,P)$EQ_NCAP_UPPERB_EM(i1,R,V,P),-NCAP_BND(R,V,P));

y(data) = 0;
qx(data)=0;
q(data)=0;
y(j1)=1$(dualx(j1)=0);
y(i1)=1$(duale(i1)=0);
qx(data)=sum(jj1$(ord(jj1)<=ord(data)),y(jj1))*y(data);
q(d)=sum(data$(ord(data)<=ord(d)),y(data))*y(d);

nx=sum(d$(ord(d) eq card(d)),qx(d));
ne=sum(d$(ord(d) eq card(d)),q(d))-nx;
ne_new = ne;


*5) Define an indicator array containing the position of the basic variables



*6) define for decision and slack variables the index of basic variables
ind(j1)=ord(j1)$(y(j1)=1);
ind(i1)=(ord(i1))$(y(i1)=1);


*7) Define a matrix that takes the colums of the tableau corresponding to the
* basic variables

* extracting the columns from Tab(leau) and allocating them in Base depending on the ind(j1) indicator.
* ind(j1) is equal to the position on the tableau where the dual is zero.
loop(i1,
  loop(j1$(ord(j1)=ind(j1)),Base(i1,j1)=Tab(i1,j1))
  loop(ii1$(ord(ii1)=ind(ii1)),Base(i1,ii1)=Tab(i1,ii1))
);



* To invert the basis we need to make it run over a single index

loop (i1,
     loop((d,ii1)$(ord(ii1)=q(d)),BB(i1,ii1)=Base(i1,d))
);


execute_unload 'basis.gdx', i1, BB;
execute '=invert.exe basis.gdx i1 BB D.gdx invb';
execute_load 'D.gdx', invb;

*execute_unload "Tableau.gdx" A,T,Base,BB,invB;


Sens(i1)=sum(ii1,invb(i1,ii1)*b(ii1));

test=sum(i1,duale(i1)*b(i1));

execute_unload "Tableau.gdx" A,Tab,Base,BB,invB,Sens,x,b,duale,test,OBJZ.L;
