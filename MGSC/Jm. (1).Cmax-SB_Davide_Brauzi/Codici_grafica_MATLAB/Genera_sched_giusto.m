% Script -per generare il diagramma di Gantt
clear all
close all
N = readmatrix("risultati_prova.xlsx",'Range',"A3:A3"); % Numero attivita
n = readmatrix("risultati_prova.xlsx",'Range',"B3:B3"); % Numero job
m = readmatrix("risultati_prova.xlsx",'Range',"C3:C3"); % Numero macchine
Cmax = readmatrix("risultati_prova.xlsx",'Range',"D3:D3"); % Numero macchine
%%
% M è composta da vettori [ESj Cj Ris J]
M = readmatrix("risultati_prova.xlsx",'Range',"B5:OK8");
COLORS = ["#FF5733", "#33FF57", "#3357FF", "#FF33A8", "#33FFF6", ...
          "#F6FF33", "#8E44AD", "#1ABC9C", "#E67E22", "#2ECC71", ...
          "#E74C3C", "#3498DB", "#9B59B6", "#34495E", "#16A085", ...
          "#F39C12", "#D35400", "#7F8C8D", "#BDC3C7", "#2C3E50"];
letters = ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" ...
           "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T"];

%%
close all
hold on 
box on
o = Cmax + Cmax/14;
top = 2*m + 1;
axis([-Cmax/7 o 0 top - 1])
%unique([0:50:o, 3.14])
xticks(unique([0:100:o, Cmax]))
%xticks(0:50:o);
yticks([]);
for i = 1:m
    str = strcat("M_{",string(i),"}"); % Scrivo il nome della macchina
    text(-Cmax/14,2*m - 2*i + 1,str,'Color','blue','FontSize',10);
    top = 2*m - 2*i;
    rectangle('Position', [0, top, Cmax, 2], 'EdgeColor', 'black', 'LineWidth', 1, 'FaceColor','black','FaceAlpha', 0.05);
end

for j = 1:N
    % Coordinate in x ed y del punto in questione
    y = 2*m -2*M(3,j);
    x = M(1,j);
    C = M(2,j);
    p = C - M(1,j);
    word = letters(M(4,j));
    indice = M(4,j);
    colore = COLORS(indice);
    rectangle('Position', [x, y, p, 2], 'EdgeColor', 'black', 'LineWidth', 1, 'FaceColor',colore,'FaceAlpha', 0.5);
    text((x+C-1)/2,y+1,word,'Color','black','FontSize',10);
end