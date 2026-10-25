% Genera grafo disgiuntivo 
clear all
clc
close all
% Anzitutto riporto la funzione che disegna le frecce
function drawArrowWithHead(x1, y1, x2, y2, r, lineProps, arrowColor)
% Disegna una freccia da (x1,y1) a (x2,y2) evitando i nodi (raggio r)
% lineProps: cell array con proprietà linea (es. {'Color','k','LineWidth',2})
% arrowColor: colore del triangolo punta (es. 'r' oppure [0.2 0.4 0.8])

    % Calcolo direzione normalizzata
    dx = x2 - x1;
    dy = y2 - y1;
    L = hypot(dx, dy);
    if L < 1e-6
        warning('Punti troppo vicini, freccia non disegnata.');
        return;
    end
    ux = dx / L;
    uy = dy / L;

    % Margine per non toccare i nodi
    margin = 0.05;
    offset = r + margin;

    % Estremi accorciati
    x_start = x1 + ux * offset;
    y_start = y1 + uy * offset;
    x_end   = x2 - ux * offset;
    y_end   = y2 - uy * offset;

    % Corpo della freccia (linea)
    plot([x_start, x_end], [y_start, y_end], lineProps{:});

    % Parametri punta
    arrow_len = 0.85;
    arrow_wid = 0.55;

    % Base del triangolo
    xb = x_end - ux * arrow_len;
    yb = y_end - uy * arrow_len;

    % Perpendicolare alla direzione
    px = -uy;
    py =  ux;

    % Vertici del triangolo
    tip    = [x_end, y_end];
    base1  = [xb + px * arrow_wid, yb + py * arrow_wid];
    base2  = [xb - px * arrow_wid, yb - py * arrow_wid];

    % Disegna la punta con colore personalizzato
    fill([tip(1), base1(1), base2(1)], ...
         [tip(2), base1(2), base2(2)], ...
         arrowColor, 'EdgeColor', 'none');
end

% A questo punto leggo ciò che mi serve per la rappresentazione (r_d varie
% iterazioni, ordine macchine sched, e schedule sui macch)
% Istanza Giordani 3x3 (macchine diverse prima iterazione)
% RD = readmatrix("matr_ad.xlsx",'Range',"A17:X21"); % r_d (ipercolonna)
% SCHED = readmatrix("matr_ad.xlsx",'Range',"B25:D28"); % schedule su macch
% M_SCHED = readmatrix("matr_ad.xlsx",'Range',"A31:D31"); % ordine schedula macch.
% PROC_TIME = readmatrix("matr_ad.xlsx",'Range',"A33:L33"); % proc_time
% M_D = readmatrix("matr_ad.xlsx",'Range',"A35:J35"); % macchina richiesta dalle varie operazioni

% % Istanza 4x4 con seed 33 (ordine diverso primo macchinario prima iterazione)
% RD = readmatrix("matr_ad_2(seed_33).xlsx",'Range',"A23:AJ27"); % r_d (ipercolonna)
% SCHED = readmatrix("matr_ad_2(seed_33).xlsx",'Range',"B31:E34"); % schedule su macch
% M_SCHED = readmatrix("matr_ad_2(seed_33).xlsx",'Range',"A37:D37"); % ordine schedula macch.
% PROC_TIME = readmatrix("matr_ad_2(seed_33).xlsx",'Range',"A39:R39"); % proc_time
% M_D = readmatrix("matr_ad_2(seed_33).xlsx",'Range',"A41:P41"); % macchina richiesta dalle varie operazioni

% Istanza 4x4 con seed 42 (ordine diverso primo macchinario prima iterazione)
RD = readmatrix("matr_ad_3(seed_42).xlsx",'Range',"A23:AJ27"); % r_d (ipercolonna)
SCHED = readmatrix("matr_ad_3(seed_42).xlsx",'Range',"B31:E34"); % schedule su macch
M_SCHED = readmatrix("matr_ad_3(seed_42).xlsx",'Range',"A37:D37"); % ordine schedula macch.
PROC_TIME = readmatrix("matr_ad_3(seed_42).xlsx",'Range',"A39:R39"); % proc_time
M_D = readmatrix("matr_ad_3(seed_42).xlsx",'Range',"A41:P41"); % macchina richiesta dalle varie operazioni


E = [4 4 4 4];    % Lunghezza di ciascuna catena
%E = [3 4 3];
N = sum(E);
% Genero ora le etichette per i nodi 
label = strings(1,N+2);
label(1) = "s";
label(N+2) = "t";

COLORS = [
    1.00, 0.00, 0.00;   % rosso vivo
    0.00, 0.45, 0.74;   % blu MATLAB
    0.00, 0.60, 0.00;   % verde vivo
    0.93, 0.69, 0.13;   % giallo senape
    0.49, 0.18, 0.56;   % viola intenso
    0.30, 0.75, 0.93;   % azzurro chiaro
    0.85, 0.33, 0.10;   % arancio bruciato
    0.75, 0.00, 0.75;   % magenta acceso
    0.00, 0.75, 0.75;   % ciano
    0.60, 0.40, 0.00    % marrone/dorato
];
% matrice di colori usata per archi disgiuntivi

% === CREAZIONE GRAFO ===


% === COSTRUZIONE POSIZIONI CUSTOM PER PLOT ===
e = length(E);
positions = zeros(N+2, 2);   % Posizioni [x,y] per ogni nodo
l = 1; % serve per regolare l'altezza
positions(1,:) = [0, ceil(length(E)^2/2)*5 + 5*l];
positions(N+2,:) = [(max(E) + 1) * 10, ceil(length(E)^2/2)*5 + 5*l];


succ = 1;
l = 1; % parametro che serve per l'altezza della sorgente e del pozzo

for j = 1:e
    for i = 1:E(j)
        succ = succ + 1;
        positions(succ,1) = i * 10;
        positions(succ,2) = j * length(E) * 5;
        label(succ) = strcat("T_",string(M_D(succ-1)),"_,_",string(j));
    end
end

%% === DISPLAY DEL GRAFO===
close all
figure(1);
axis off
xlim([-5 (max(E)+2)*4]);
ylim([0 (length(E)^2 + 3) * 5])
hold on
% Tracciamo tutti i punti
scatter(positions(:,1), positions(:,2), 'SizeData',1000, 'MarkerEdgeColor','black');
for i = 1:N+2
    etichette = text(positions(i,1), positions(i,2), label{i}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 12, ...
        'Color', 'black');  % Colore del testo

    r_d(i) = text(positions(i,1), positions(i,2)+5, strcat("[",string(RD(1,2*i -1)),",",string(RD(1,2*i)),"]"), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 12, 'Color', 'blue', 'FontWeight','bold');
    proc_time = text(positions(i,1), positions(i,2)+7.25, strcat("(",string(PROC_TIME(i)),")"), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 12, 'Color', [0.13, 0.55, 0.13], 'FontWeight','bold');
end
succ = 2;
for j = 1:e
    x1 = positions(1,1);
    y1 = positions(1,2);
    x2 = positions(succ,1);
    y2 = positions(succ,2);
    drawArrowWithHead(x1, y1, x2, y2, 3, {'Color', 'k', 'LineWidth', 1}, 'black');
    drawArrowWithHead(positions(succ + E(j) - 1,1), positions(succ + E(j) - 1,2), positions(N+2,1), positions(N+2,2), 3,{ 'Color', 'k', 'LineWidth', 1}, 'black');
    for i = 1:E(j)-1
        drawArrowWithHead(positions(succ+i-1,1), positions(succ+i-1,2), positions(succ+i,1), positions(succ+i,2), 3,{ 'Color', 'k', 'LineWidth', 1}, 'black');
    end
    succ = succ + E(j);
end
axis equal
hold off

pause
figure(1)
axis off
hold on
%A questo punto itero sulle iterazioni della SHFT BTNK 
for t = 1:length(M_SCHED)
    delete(r_d);
    for i = 1:N+2
        r_d(i) = text(positions(i,1), positions(i,2)+5, strcat("[",string(RD(t+1,2*i -1)),",",string(RD(t+1,2*i)),"]"), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, 'Color', 'blue', 'FontWeight','bold');
    end
    % individuo indice di macchinario M_SCHED(t)
    for j = 1:e-1
        if SCHED(M_SCHED(t),j+1) >= 1 
            drawArrowWithHead(positions(SCHED(M_SCHED(t),j),1), positions(SCHED(M_SCHED(t),j),2), positions(SCHED(M_SCHED(t),j+1),1), positions(SCHED(M_SCHED(t),j+1),2), 3,{ 'Color', COLORS(M_SCHED(t),:), 'LineWidth', 0.5, 'LineStyle', '--'}, COLORS(M_SCHED(t),:));
        end
    end
pause
end