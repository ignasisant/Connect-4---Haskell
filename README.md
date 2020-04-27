DOCUMENTACIO PRACTICA HASKELL - QUATRE EN RATLLA - LP -IGNASI SANT ALBORS

COMPILACIÓ:
$ghc joc.hs

EXECUCIÓ:
./joc

Notes inicials a tenir en compte:
-El tauler ESTÀ TRANSPOSAT ja que ens facilita la feina, és a dir, que el programa usa el tauler transposat pero quan el mostro per pantalla el torno a trasposar per que es pugui veure bé. En aquest document quan parlo del tauler, em refereixo a ell sense transposar-lo, és a dir si tenim un taulell de 5 files i 7 columnes em referiré al taulell 5x7. Si en algun moment m'és més convenient usar el tauler transpodat ja ho diré explicitament.
-Al codi es veu que fa cada funcio en els comentaris
-Hi ha dos jugadors, l'usuari i la màquina. En el tauler [[Int]] les fitxes de la maquina seràn els elements denotats amb -1. Per altre banda les fitxes de l'usuari correspondràn amb els elements de valor 1.

-ABANS DE COMENÇAR:

En aquesta implementació del joc connecta 4 l'usuari pot decidir en quin mode de joc jugar (random, greedy, smart). Ho decidirà abans de començar cada partida i podrà tornar-ho a escollir quan l'acabi.

Un cop s'ha decidit quin mode de joc, el programa ens demana que entrem el nombre de files i columnes per al nostre tauler. El programa no acceptarà cap valor de files i columnes més petit que 4. Això es deu a que he pensat que no tenia sentit jugar al 4 en ratlla en un tauler més petit que 4x4. Tot hi aixi es podria haver implementat que com a minim o les files o les columnes haguessin de ser 4 ja que aixi segur que hi podria haver com a minim un quatre en ratlla (Ex tauler 4x1, 1x4). M'he decantat per la primera opció ja que faria el joc més divertit. 

Per altre banda el limit superior a l'hora de determinar la grandaria del tauler és de 25, és a dir, no podrem jugar amb un tauler mes gran que 25x25. Ho he decidit aixi ja que el temps d'execució del programa amb un tauler molt gran excedeix la paciència del usuari.

Un cop hem definit el mode de joc i el tamany del tauler el programa ens demanarà si volem començar tirant o bé que començi la màquina. El input que hem de donar ha de ser el correcte per tal de poder començar la partida.

-TAULER I JUGADORS:

Un cop entrades les caracteristiques del tauler, es crea una matriu de zeros que representa el tauler [[Int]]. Aquest tauler que es crea és el TRANSPOSAT del que intuitivament fariem segons el numero de fila (fil) i el numero de columna (col) que ha entrat l'usuari per tant el tauler és de colxfil. 

Inicialment el tauler és buit (tot zeros) i es va omplint segons qui tiri.
Al ser un joc de dues persones tenim dos jugadors i per tant dos tipus de dades a diferenciar. Per això defineixo les fitxes de l'usuari amb l' 1 i les de la màquina amb -1. D'aquesta manera al fer el cambi de torn després de cada tirada només he de multiplicar per -1 (o be fer -jugador). Aquest fet es pot veure dins la funcio juga (linea 66).

Tot hi aixi quan mostrem el tauler per pantalla el TRASPOSEM abans per que quedi com el tauler que realment ha definit l'usuari. A més a més cambiem cada element del tauler (0, 1 i -1) per un simbol per tal de que sigui més facil i còmode veure el tauler al terminal. Substituim "0" per "-" per tal d'indicar que aquella posició està buida. Substituim "1" per "X" i "-1" per "O".

-FI PARTIDA:

El programa comproba després de cada tirada d'un jugador si hi ha algun 4 en ratlla. Només comprobem si hi ha 4 en ratlla del últim que ha tirat ja que només és ell qui te la possibilitat d'haver fet 4 en ratlla.

Per comprobar si es produeix algun quatre en ratlla hem de comprobar si es dona en les files, en les columnes, en les diagonals cap amunt (fil-1 col+1) o en les diagonals cap avall(fil+1, col+1).

El cas de les files i les columnes és senzill ja que podem usar el mateix algorisme passant el tauler transposat i sense transposar. He creat dues funcions (comprobaPerFiles i comprobaFila) que duen a terme tot aquest procés. Bàsicament el que fa comprobaFila es retornar el numero de fitxes consecutives en una fila per part d'un jugador. Si aquest número és més gran o igual a 4 vol dir que hi ha un quatre en ratlla (només necessitem saber si es produeix o no, no necessitem saber on es produeix) . Pot semblar raro que retorni el numero de fitxes consecutives en comptes de retornar un Bool però ho vaig implementar aixi ja que em podria ser d'ajuda al fer el Greedy i per tant podria fer reús de les funcions. ComprobaPerFiles basicament crida comprobaFila passant-li com a parametre cadascuna de les files del tauler per tal de que les retorni totes. Al igual que en la funcio anterior no és retorna un Bool sino que es retorna el numero màxim de fitxes consecutives que te un jugador tenint en compte totes les files del tauler. 

El cas de les diagonals és més complex ja que no totes les diagonals poden produir un 4 en ratlla, per tant si comprobem aquestes diagonals perdrem eficiència. La idea que he tingut és fer dues funcions diferents (comprobaDiagAmunt -> fil-1, col+1 i comprobaDiagAvall -> fil+1, col+1 ) on els hi passem la posició d'inici de les seves respectives diagonals i aquestes retornen el numero de fitxes consecutives d'un jugador que hi ha a la diagonal. El motiu de que retorni el numero en comptes de un Bool dient si s'ha produit o no el 4 en ratlla és el mateix que en el cas de les files i les columnes. 
Com que a aquestes funcions els hi hem de passar la posicio (fil,col) de l'element d'inici de la seva diagonal,hem de fer una funció (vesIterantDiag) que s'encarregui d'anar comprobant totes les diagonals i guardant el número maxim de fitxes consecutives d'un jugador en totes les diagonals. En aquesta funció és on es veu reflectit que no es comproben les diagonals amb menys de 4 elements. Si agafem el cas de les diagonals cap amunt veiem que no hem de comprobar les diagonals que comencen des de la columna 0 i files 0 a 2 ja que aquestes diagonals tenen menys de 4 elements. Per tant començarem comprobant la diagonal cap amunt que comença a la posicio (3,0) i anirem iterant i comprobant els elements (2,1) -> (1,2) -> (0,3), en aquest punt ja hauriem comprobat tota la diagonal i retornariem el resultat. Tot hi aixi només em comprobat les diagonals que comencen a la columna 0 pero ara hem de comprobar les diagonals que comencen a la fila final (length tauler -1). A aquestes diagonals els hi passara el mateix que a les anteriors ja que a les que comencin des de la última fila i les 3 últimes columnes les diagonals no tindràn 4 elements i per tant no s'hauran de comprobar.

Per altre banda si no s'ha produit 4 en ratlla, el programa comproba que el tauler no estigui ple ja que en aquest cas voldria dir que s'ha produit un empat i encara que no hi hagi guanyador s'ha acabat la partida.

-JOC:

El joc es desenvolupa gràcies a la funció "juga". El que fa aquesta funció és una mica el paper d'un arbitre. Bàsicament se la crida des del main passant-li el tauler definit per l'ususari (buit, tot 0), el mode de joc, el jugador (usuari 1 o màquina -1) i la funció "tirada". He dit que fa d'arbitre ja que, el que fa la funció, és modificar el tauler amb l'ajut de la funcio "tirada" (que rep com a parametre). Un cop la funció "tirada" ha retornat el tauler modificat per la tirada d'algun dels jugadors la funcio "juga" comproba que en aquest no hi hagi cap quatre en ratlla. Si no és així comproba que el tauler no sigui ple. Si cap d'aquestes condicions es compleix vol dir que l'altre jugador pot tirar, per tant es tornarà a cridar a si mateixa amb el tauler modificat per la tirada anterior com a parametre. A més quan es torni a cridar a si mateixa també cambiarà el parametre jugador ja que ara li tocarà tirar a laltre jugador. Els altres parametres no es modificaràn. 
D'aquesta manera el programa va fent tirades fins que el joc s'acaba. Quan la partida s'acaba perque s'ha produit un quatre en ratlla, es crida a la funció "fiJoc" passant com a parametre el jugador que ha guanyat. Per altre banda si la partida s'acaba ja que el tauler ha quedat ple, es crida a la funció "fiJoc" amb el parametre "0" ja que d'aquesta manera sap que s'ha produit un empat.

-ESTRATÈGIA RANDOM:

Aquesta estratègia s'implementa en la funció "random_strategy"
En aquesta estratègia bàsicament el que es fa és generar un número random entre 0 i el nombre de columnes -1. Aquest nombre correspodrà a la columna on es farà la tirada. Abans, però, hem de comprobar que aquella columna no estigui plena, si ho està tornarem a començar el procés per tal de que es generi un altre nombre random a veure si aquesta altre columna no està ocupada. Finalment retornarem la fila i la columna on s'ha d'introduir la fitxa. La fila es calcula a partir de la funcio gravetat, que simula el fet d'introduir una fitxa en una columna, i retorna fins a quina fila pot caure. Si aquesta retorna -1 vol dir que la columna esta plena i que pertant haurem de repetir el procés. Cal recordar que,en el programa, degut a que el tauler està transposat, retornem la posicio (col,fil) en comptes de (fil,col).

Si ens fixem en la implementació anterior podem arribar a la conclusió de que si tenim files plenes podem fer que el generador de nombres randoms només generi nombres en el rang de les files buides, evitant aixi haver de repetir tot el procés si el nombre generat correspon a una columna plena. He decidit no fer-ho aixi ja que es necessiten unes quantes tirades per omplir alguna de les columnes i per tant al principi de la partida estariem calculant quines files estan lliures i quines no inútilment ja que totes ho estarien. A part per hauriem de recorre la matriu al anar comprobant cada una de les columnes si està lliure. Penso que al final surt més a compte no saber quines estàn plenes i quines buides, i repetir tot el procés si és que just el nombre generat coincideix amb una columna plena. A part així només ho comprobem un cop per cada nombre generat, de l'altre manera ho comprobariem tants cops com columnes hi hagi.

-ESTRATÈGIA GREEDY:

Aquesta estratègia s'implementa en la funció "greedy".
La idea en aquesta estretègia és que l'ordinador tiri a la columna que li permet posar en ratlla el nombre més alt de fitxes pròpies. En la meva implementació he seguit la següent idea.
Primer estudio la puntuació que tindria si tires a cada una de les columnes amb la funció "insersio_multiple", el resultat el guardo en un vector on en la posició 0 te la puntuació màxima obtinguda si hagués tirat a la columna 0 , a la posicio 1 el mateix però si tirés a la columna 1, i aixi... Si en una columna no puc tirar ja que està plena, en el vector es guarda el valor -1. 
Un cop tinc aquest vector he de buscar quines son les posicions que tenen la major puntuació ja que seràn aquestes on més m'interessa tirar. Això ho faig amb la funció "indexMax" que em retorna un vector amb les columnes on puc tirar per obtindre la puntuació màxima (si n'hi ha més d'una). Els elements d'aquest vector contenen el nombre de les columnes, per tant, com que en totes obtindria la puntuació màxima més igual on tirar. Elegeixo una posició random del vector. Aquesta posició m'indicarà la columna on he de tirar, ara només he de saber fins a quina fila cauria la fitxa, tal i com passaria en un tauler real. 
Per calcular a quina fila ha d'estar la fitxa m'ajudo de la funció "gravetat" que rep una columna i retorna la fila del tauler on s'hauria de colocar per que no quedés cap posició buida entre fitxa i fitxa. 
Per últim retorno la posició (fil,col) on s'ha d'inserir la fitxa. Cal recordar que,en el programa, degut a que el tauler està transposat, retornem la posicio (col,fil).

Si en algun moment veu que l'usuari pot guanyar aquesta estratègia evitarà que el contrincant faci quatre en ratlla a la jugada següent. Tot hi aixi si es troba en la situació que detecta que l'usuari pot guanyar en la jugada següent pero ell pot guanyar en la jugada actual, anirà a guanyar.


-ESTRATÈGIA SMART:

Aquesta estratègia s'implementa a la funció "smart".
La meva idea principal era fer un min-max on es tirés a la columna on obtens una millor puntuació per a tu i la pitjor per a l'adversari. Degut a la falta de temps no he pugut implementar aquesta versió.

La segona idea que tenia és la de millorar alguns aspectes del greedy. Per exemple si al fer una tirada es facilités el 4 en ratlla a l'adversari aquesta tirada no es fa, és a dir, evitar tirar en una casella on en la següent tirada l'adversari pot guanyar aprofitant la teva tirada. 

Degut a la falta de temps no he implementat aquesta part.









