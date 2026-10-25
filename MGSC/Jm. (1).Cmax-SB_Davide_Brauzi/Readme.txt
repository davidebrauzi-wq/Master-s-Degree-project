In questo file sono presentati gli elaborati relativi al primo progetto del corso di MGSC (Shifting Bottleneck e Jm||Cmax)
Proj_MGSC_Davide_Brauzi.pdf: tesina vera e propria.
Il restante materiale è diviso in due cartelle così organizzate: 
	>>Materiale_AMPL: contiene i codici relativi alle varie sperimentazioni
		>SHIFTING_BOTTLENECK: presenta i codici relativi all'algoritmo Shifting Bottleneck; i seguenti file .dat sono blocchi di codice richiamati nel .run in modo da rendere lo 			script principale più snello ed ordinato. 
			>BACKWARD.dat: blocco di codice relativo alla procedura BACKWARD.
			>ORD_PIU_FORWARD.dat: blocco di codice relativo alla procedura di ORD TOP e alla PROCEDURA FORW.
			>BUILD_SOLVE_IST.dat: costruzione e risoluzione del problema 1|rj|Lmax per le varie macchine esaminate a ciascuna iterazione + confronto per capire se la macchina è 			bottleneck.
			>ORIENTA_ARCHI_DISG.dat: orientamento archi congiuntivi sulla base del bottleneck.
			Queste 4 procedure sono incluse nello script tramite "data ..."
			
			>SHFT_BTNK_COMPACT.run: script per la risoluzione di precise istanze; necessita della dichiarazione del file test_matrici.mod e del .dat relativo a qualsiasi 				istanza (ho preferito non metterli all'interno dello script per avere la possibilità di risolvere diverse istanze da console rapidamente).
			>SHFT_BTNK_COMPACT_SP.run: script usato per la sperimentazione con il generatore di istanze (nel formato fornito nel canale Teams); anche qui si ha l'inserimento 			dei relativi blocchi di codice tramite file .dat; ho preferito usare istanze generate randomicamente per automatizzare il processo di raccolta dati tramite 				scrittura su appositi file .csv.

			>1.rj.Lmax.mod: modello presentato a lezione per risoluzione sottoproblemi.
			>test_matrici.mod: file di input per SHFT_BTNK_COMPACT.run

			>ISTANZE (tutte codificate come nel file .txt presente nel team):
				>esercizio_giordani.dat: istanza delle dispense.
				>4x4_BE1.dat: istanza (n=4, m=4) utilizzata nella tesina per mostrare l'effetto della scelta arbitraria di sched. equivalenti sulla macchina bottleneck.
				>abz_5.dat: istanza (n=10,m=10) nota in letteratura
				>20x20.dat: istanza di Yamada e Nakamo (n=20, m=20) nota in letteratura

		>RISOLUZIONE OTTIMO: per il test delle 3 (+1) formulazioni, dove la quarta è una TI_INDEXED migliorata da un mio ragionamento
			>risolvi_ottimo.run: Generatore (la generazione presenta lo stesso schema di quella fatta in SHFT_BTNK_COMPACT_SP.run) e risolutore di istanze per confronto delle 3 			(+1) formulazioni, con la possibilità di valutare l'impatto dell'UB fornito dalla Shifting Bottleneck sui tempi di calcolo/numero e variabili (per la time 				indexed ovviamente).
			>J..Cmax.mod: modello su grafo disgiuntivo visto a lezione => nella tesina è DM
			>J..Cmax(rank_based): modello posizionale visto a lezione => nella tesina è RB
			>J..Cmax(time_indexed): modello impulsivo time_indexed visto a lezione => nella tesina è TI(1)
			>J..Cmax(time_indexed): modello impulsivo time_indexed visto da me migliorato => nella tesina è TI(2) [diminuisce il numero di variabili a parità di T]
			>UBs_5x5_1-30.dat: UB per le 30 istanze (n=5,m=5) con (1<=p_{i,j}<=30) forniti dalla Shifting Bottleneck
			>UBs_5x5_30-60.dat: UB per le 30 istanze (n=5,m=5) con (60<=p_{i,j}<=90) forniti dalla Shifting Bottleneck
			>UBs_5x5_60-90.dat: UB per le 30 istanze (n=5,m=5) con (60<=p_{i,j}<=90) forniti dalla Shifting Bottleneck

		>Confronti.xlsx: Excel riepilogativo dei risultati ottenuti, a loro volta sintetizzati nella tesina per brevità.



	>>Codici_grafica_MATLAB: contiene codici MATLAB per graficare i risultati ed esempi di output prodotti dagli stessi.
		>Costruisci_grafo.m: rappresentazione automatica delle iterazioni della Shifting Bottleneck. In input ha i vettori r,d tra le varie iterazioni,la matrice di adiacenza 			della rete e la schedule ottenute nelle varie iterazioni	
		>Genera_sched_giusto.m: rappresentazione della schedula tramite diagramma di Gantt (sfrutta il fatto che SB produce schedule ES rispetto a gli r_j calcolati all'ultima 		iterazione). 
		>schedula_20x20_esempio.png: possibile output su 20x20.dat risolta con Shift-Bottleneck.
		>SBH_GRAPHICS_4x4: rappresentazione completa di un possibile output su 4x4_BE1.dat contenente le 5 configurazioni di rete e la schedula finale.
		