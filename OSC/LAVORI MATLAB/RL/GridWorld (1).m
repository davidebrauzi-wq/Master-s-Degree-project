close all
clear all
clc

% disegnamo GridWorld
figure(1)
hold on
box on
axis([-1 10 -1 10])
line([0 9 9 0 0],[0 0 9 9 0]); line([0 9],[3 3]); line([0 9],[6 6]); line([3 3],[0 9]); line([6 6],[0 9]);
text(0.2,8.5,'1','Color','red','FontSize',13); text(3.2,8.5,'2','Color','red','FontSize',13); text(6.2,8.5,'3','Color','red','FontSize',13);
text(0.2,5.5,'4','Color','red','FontSize',13); text(3.2,5.5,'5','Color','red','FontSize',13); text(6.2,5.5,'6','Color','red','FontSize',13);
text(0.2,2.5,'7','Color','red','FontSize',13); text(3.2,2.5,'8','Color','red','FontSize',13); text(6.2,2.5,'9','Color','red','FontSize',13);

% consideriamo la policy con scelta casuale di azione tra {su, giù, destra,
% sinistra} e distribuzione uniforme, pi(a|s) = 1/4 per ogni a ed s
gamma = 0.9;
pSu = 0.25; % probabilità di scegliere l'azione "su"
pGiu = 0.25;
pDes = 0.25;
pSin = 0.25;
Rjump = 10; % ricompensa per salto da 2 a 8
Rout = -1;  % ricompensa per uscita da griglia


% scriviamo il sistema di equazioni che forniscono v_pi(s)
% equazione per v_pi(1):    v_pi(1) = pSu*(Rout+gamma*v_pi(1)) +
% pGiu*(0+gamma*v_pi(4)) + pDes*(gamma*v_pi(2)) + pSin*(Rout+gamma*v_pi(1))
% ----> v_pi(1) = gamma*M1*vi_p + N1
T1 = [pSu+pSin,pDes,0,pGiu,0,0,0,0,0]; R1 = pSu*Rout+pSin*Rout;
% ragionamento identico per tutti gli altri stati
T2 = [0,0,0,0,0,0,0,pSu+pGiu+pDes+pSin,0]; R2 = Rjump;
T3 = [0,pSin,pSu+pDes,0,0,pGiu,0,0,0]; R3 = pSu*Rout+pDes*Rout;
T4 = [pSu,0,0,pSin,pDes,0,pGiu,0,0]; R4 = pSin*Rout;
T5 = [0,pSu,0,pSin,0,pDes,0,pGiu,0]; R5 = 0;
T6 = [0,0,pSu,0,pSin,pDes,0,0,pGiu]; R6 = pDes*Rout;
T7 = [0,0,0,pSu,0,0,pGiu+pSin,pDes,0]; R7 = pGiu*Rout+pSin*Rout;
T8 = [0,0,0,0,pSu,0,pSin,pGiu,pDes]; R8 = pGiu*Rout;
T9 = [0,0,0,0,0,pSu,0,pSin,pGiu+pDes]; R9 = pGiu*Rout+pDes*Rout;
% componiamo le matrici..
T = [T1;T2;T3;T4;T5;T6;T7;T8;T9]; R = [R1;R2;R3;R4;R5;R6;R7;R8;R9];
% e risolviamo il sistema
% (I-gamma*T)*v = R ----> v = (I-gamma*T)^{-1}*R
vPi = inv(eye(9)-gamma*T)*R;
pause

% scriviamo la funzione valore per ogni stato..
text(1,7.5,num2str(vPi(1)),'FontSize',16); text(4,7.5,num2str(vPi(2)),'FontSize',16); text(7,7.5,num2str(vPi(3)),'FontSize',16);
text(1,4.5,num2str(vPi(4)),'FontSize',16); text(4,4.5,num2str(vPi(5)),'FontSize',16); text(7,4.5,num2str(vPi(6)),'FontSize',16);
text(1,1.5,num2str(vPi(7)),'FontSize',16); text(4,1.5,num2str(vPi(8)),'FontSize',16); text(7,1.5,num2str(vPi(9)),'FontSize',16);
pause

% proviamo con Policy Evaluation
epsilon = 1e-3;
Delta = epsilon;
% inizializzazione casuale della v0
vPE = [0;10;0;0;0;0;0;0;0];
while Delta >= epsilon
    Delta = 0;
    for s = 1:9
        v = vPE(s);
        vPE(s) = R(s) + gamma*T(s,:)*vPE;
        Delta = max(Delta,abs(v-vPE(s)));
    end
end
vPE
pause

% v_k+1 = max_u(R(x,u) + gamma*v_k(f(x,u))
% Value Iteration
Tsu = [1 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 1 0;0 0 1 0 0 0 0 0 0;1 0 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0 0;0 0 1 0 0 0 0 0 0;0 0 0 1 0 0 0 0 0;0 0 0 0 1 0 0 0 0;0 0 0 0 0 1 0 0 0];
Tgiu = [0 0 0 1 0 0 0 0 0;0 0 0 0 0 0 0 1 0;0 0 0 0 0 1 0 0 0;0 0 0 0 0 0 1 0 0;0 0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 0 1;0 0 0 0 0 0 1 0 0;0 0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 0 1];
Tdx = [0 1 0 0 0 0 0 0 0;0 0 0 0 0 0 0 1 0;0 0 1 0 0 0 0 0 0; 0 0 0 0 1 0 0 0 0;0 0 0 0 0 1 0 0 0;0 0 0 0 0 1 0 0 0;0 0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 0 1;0 0 0 0 0 0 0 0 1];
Tsx = [1 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 1 0;0 1 0 0 0 0 0 0 0;0 0 0 1 0 0 0 0 0;0 0 0 1 0 0 0 0 0;0 0 0 0 1 0 0 0 0;0 0 0 0 0 0 1 0 0;0 0 0 0 0 0 1 0 0;0 0 0 0 0 0 0 1 0];
Rsu = [-1;10;-1;0;0;0;0;0;0];
Rgiu = [0;10;0;0;0;0;-1;-1;-1];
Rdx = [0;10;-1;0;0;-1;0;0;-1];
Rsx = [-1;10;0;-1;0;0;-1;0;0];
vVI = vPE;
A = zeros(1,9); % azioni ottime
for k = 1:100
    for j = 1:9
        [vVI(j), A(j)] = max([(Rsu(j)+gamma*Tsu(j,:)*vVI),(Rgiu(j)+gamma*Tgiu(j,:)*vVI),(Rdx(j)+gamma*Tdx(j,:)*vVI),(Rsx(j)+gamma*Tsx(j,:)*vVI)]);
    end
end
vVI
A





