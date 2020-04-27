--IGNASI SANT ALBORS
--PRACTICA HASKELL LP
--CONNECT 4

import System.Random
import Data.List

--MAIN
main :: IO ()
main = do 
    putStrLn $ id "Benvingut al joc"
    putStrLn $ id ""
    mode <- select_mode  
    fil <- select_fila
    col <- select_col
    let tauler = construir_tauler col fil
    jugador <- triar_jugador
    if jugador == 1
        then print_tauler tauler
        else return ()
    juga tauler mode jugador (tirada)
    
--es defineix quantes files tindrà el tauler, no deixa abançar fins que l'usuari no introdueixi
--correctament el nombre de files
select_fila :: IO Int
select_fila = do
    putStrLn $ id  "Entri les files (4 - 25)"
    x <- getLine
    let fil = (read x :: Int)
    if fil > 3 && fil < 26
        then return fil
        else select_fila

--es defineix quantes columnes tindrà el tauler, no deixa abançar fins que l'usuari no introdueixi
--correctament el nombre de columnes
select_col :: IO Int
select_col = do
    putStrLn $ id  "Entri les columnes (4-25)"
    x <- getLine
    let col = (read x :: Int)
    if col > 3 && col <26
        then return col
        else select_col

--es selecciona el mode de joc, no deixa abançar fins que no es seleccioni un dels 3
select_mode :: IO Int
select_mode = do 
    putStrLn $ id "Seleccioni el mode de joc:"
    putStrLn $ id "1 - Random"
    putStrLn $ id "2 - Greedy"
    putStrLn $ id "3 - Smart "
    putStrLn $ id ""
    m <- getLine
    let mode = (read m :: Int)
    if (mode >0 && mode <4)
        then return mode
        else select_mode

--FUNCIO DE JOC-------------------------------------------------------------------------
--funcio de joc, es crida a si mateixa cambian el jugador (-jugador) . A cada crida es produirà
--una tirada d'un jugador diferent. A més a més es comprova que no shagi produit 4 en ratlla i 
--si no s'ha produit es comprova que el tauler no estigui ple
juga :: [[Int]] -> Int -> Int -> ( Int -> [[Int]] -> Int -> IO [[Int]] ) ->IO()
juga  tauler mode jugador f= do 
    tauler <- f jugador tauler mode -- f és la funció tirada
    print_tauler tauler
    if (quatreEnRatlla tauler jugador)
        then fiJoc jugador
            else do
                if (ple tauler == True)
                    then fiJoc 0
                        else  juga tauler mode (-jugador) f
    print()

--FUNCIONS PER COMPROVAR SI HI HA ALGUN GUANYADOR---------------------------------------------------------------

--comprova si el tauler esta ple. Retorna True si no es pot introduir cap fitxa
ple :: [[Int]] -> Bool
ple [] = True
ple (t:ts)
    |(posicio t) < 0 = True && ple ts  --(posicio t) retorna -1 si la columna esta plena de fitxes
    |otherwise = False

--Comprova si hi ha algun 4 en ratlla del jugador
--Passem com a parametre el tauler transposat ja que les funcions el tracten tal i com el veu l'usuari
quatreEnRatlla :: [[Int]] -> Int-> Bool
quatreEnRatlla tauler jugador = (comprobaPerFiles tauler jugador >= 4) || --comprova 4 en ratlla en columnes
    (comprobaPerFiles (transpose tauler) jugador >=4) || --comprova 4 en ratlla en files
    (comprobaPerDiag (transpose tauler) jugador >= 4) --comprova 4 en ratlla en diagonals

--COMPROVAR FILES I COLUMNES(TRANSPOSAR) ----------------------------------------
--reusarem funcions per implementar el greedy

--Retorna el número màxim de fitxes consecutives d'un jugador determinat tenint en compte totes les files
comprobaPerFiles:: [[Int]] -> Int-> Int
comprobaPerFiles [x] j  = comprobaFila x j 0
comprobaPerFiles(t:ts) jugador = max (comprobaFila t jugador 0)  (comprobaPerFiles ts jugador)


--Retorna la quantitat maxima de fitxes juntes en una fila per al jugador 
--Ens servirà per l'estrategia greedy
comprobaFila ::[Int] -> Int -> Int  -> Int
comprobaFila [] j s= s
comprobaFila (l:ls) j s
    |l==j = comprobaFila ls j (s+1)
    |otherwise = max s $comprobaFila ls j 0

--COMPROVAR LES DIAGONALS ----------------------------------------------------------
--Retorna la quantitat maxima de fitxes consecutives per part d'un jugador tenint en compte totes les 
--diagonals que tenen 4 o més elements
comprobaPerDiag:: [[Int]] -> Int -> Int
comprobaPerDiag tauler jugador = max max1 max2
    where
        max1 = vesIterantDiag1 tauler jugador (3, (length tauler-1))
        max2 = vesIterantDiag2 tauler jugador (0, (length (tauler!!0) -4) )

--Comprova les diagonals amb 4 elements o mes que comencen a la columna 0
--parametres: tauler, jugador , interval (a,b) 
vesIterantDiag1:: [[Int]] -> Int -> (Int , Int) -> Int 
vesIterantDiag1 t j (a, b) 
    |a == b = max1
    |a < b = max max1  $vesIterantDiag1 t j (a+1,b)
    |otherwise = 0
    where 
        max1 = max  (comprobaDiagAmunt t j a 0 0) (comprobaDiagAvall t j (a-3) 0 0)

--Comprova les diagonals amb 4 elements o més que comencen a la fila 0 o a la última fila.
--parametres: tauler, jugador , interval (a,b) 
vesIterantDiag2:: [[Int]] -> Int -> (Int , Int) -> Int 
vesIterantDiag2 t j (a, b) 
    |a == b = max1
    |a < b = max max1  $vesIterantDiag2 t j (a+1,b)
    |otherwise = 0
    where 
        max1 = max  (comprobaDiagAmunt t j (length t -1) a 0) (comprobaDiagAvall t j 0 a 0)

-- Comprova quantes fitxes consecutives d'un jugador hi ha en una diagonal cap amunt -> fil-1 col+1
-- se li ha d'indicar A QUIN ELEMENT COMENÇA LA DIAGONAL
-- parametres: tauler, jugador,fila ,col, suma(fitxes consecutives)
comprobaDiagAmunt :: [[Int]] -> Int -> Int -> Int -> Int -> Int
comprobaDiagAmunt t j fil col s
    |col>= (length (t!!0))|| fil <0 = s
    |getElemMat t fil col ==  j = comprobaDiagAmunt t j (fil-1) (col+1) (s+1)
    |otherwise = max s $comprobaDiagAmunt t j (fil-1) (col+1) 0


-- comprova quantes fitxes consecutives d'un jugador hi ha en una diagonal cap avall -> fil+1 col+1
-- se li ha d'indicar A QUIN ELEMENT COMENÇA LA DIAGONAL
-- parametres: tauler, jugador,fila ,col, suma(fitxes consecutives)
comprobaDiagAvall :: [[Int]] -> Int -> Int -> Int -> Int -> Int
comprobaDiagAvall t j fil col s
    |col >= (length (t!!0)) || fil >= (length t) = s
    |getElemMat t fil col ==  j = comprobaDiagAvall t j (fil+1) (col+1) (s+1)
    |otherwise = max s $comprobaDiagAvall t j (fil+1) (col+1) 0

--retorna l'element de la matriu que esta en la posició indicada
getElemMat :: [[Int]] -> Int -> Int -> Int
getElemMat (t:ts) fil col
    | fil == 0 = getElemVec t col
    | otherwise = getElemMat ts (fil-1) col

--retorna l'element del vector que esta en la posició indicada  
getElemVec :: [Int] -> Int -> Int
getElemVec (v:vs) pos
    |pos == 0 = v
    |otherwise = getElemVec vs (pos-1)

---FINAL DEL JOC I TORNAR A COMENÇAR---------------------------------------------------------

-- Final del joc
-- Se li passa el jugador com a parametre, si aquest te el valor 0 és que hi ha un empat
-- Torna a començar una nova partida
fiJoc :: Int -> IO()
fiJoc jugador = do
    if jugador == 0
        then putStrLn $ id "Empat"
            else do
                if jugador == 1
                    then putStrLn $ id "Has guanyat!"
                    else putStrLn $ id "T'ha guanyat la màquina"
    putStrLn $ id "Prem qualsevol tecla per tornar a començar"
    getLine
    main 

--FUNCIONS RELACIONADES AMB UNA TIRADA---------------------------------------------------------------

-- decideix qui comença tirant 
triar_jugador :: IO Int
triar_jugador = do
    putStrLn $ id  "Prem 1 si vols començar, prem 0 altramet"
    j <- getLine
    let jugador = assigna_jugador (read j::Int)
    if jugador == 0 
        then  triar_jugador
        else return jugador

--assigna jugador 1-> usuari ,  -1 -> maquina
assigna_jugador :: Int ->  Int
assigna_jugador x
    | x == 1 = 1
    | x == 0 = (-1)
    | otherwise = 0


--fa una tirada 
--tirada jugador tauler
tirada :: Int -> [[Int]] -> Int -> IO [[Int]]
tirada jugador tauler mode = do
    t <- if jugador == 1 -- realment ens passaran (col,fil) ja que el tauler esta transposat
        then inserir_fitxaFOS tauler (tiradaUsuari) jugador mode
        else inserir_fitxaFOS tauler (tirada_IA) jugador mode
    return t    

--retorna la columna on vol tirar l'usuari sempre que sigui possible
tiradaUsuari :: [[Int]] -> Int -> IO (Int,Int)
tiradaUsuari tauler _ = do
    putStrLn $ id ""
    putStrLn $ id  ("indica la columna on vols tirar -> (1 - "++ (show $length tauler ::String) ++ ")" )
    y <- getLine
    let fil = (read y :: Int) 
    if (fil > 0 && fil < (length tauler + 1) ) --dins del rang?
        then do
            let g = gravetat tauler (fil-1)
            if (g == -1) --columna plena?
            then do
                putStrLn $ id "no pots tirar en aquesta columna ja que esta plena"
                tiradaUsuari tauler 0
            else  return (fil-1, g)-- de 0 a length tauler -1 
        else tiradaUsuari tauler 0    

--tirada de la màquina, se li passa com a parametre l'estrategia a seguir i acutua amb consequència
tirada_IA :: [[Int]] -> Int-> IO (Int,Int)
tirada_IA tauler mode= do
    putStrLn $ id ""
    putStrLn $ id "tirada_IA"
    putStrLn $ id ""
    if mode == 1 
        then random_strategy tauler
        else do
            if mode == 2
                then greedy tauler
                else smart tauler
 
--ESTRATEGIA RANDOM---------------------------------------------------------------
--parametres: tauler 
--retorna la posició on anira la fitxa seguint l'estratègia random
random_strategy :: [[Int]] -> IO(Int,Int)
random_strategy tauler = do
    random <- randomIO :: IO Int
    let col = 0 + random `mod` ( (length tauler -1)- 0 + 1)
    let g = gravetat tauler col
    if (g == -1)
        then random_strategy tauler
        else return (col,g) --tauler transposat

--ESTRATÈGIA GREEDY----------------------------------------------------------------
greedy :: [[Int]] -> IO(Int,Int)
greedy tauler = do
    let vecPuntuacio = insersio_multiple  tauler 0 (-1) --vector amb la puntuacio si tirem a cada columna v[0] puntuacio si tirem a la columna 0
    let vecPuntContrincant = insersio_multiple  tauler 0 1 
    if ( (any (>3) vecPuntContrincant) && (any (>3) vecPuntuacio) == False) --nomes es sacrifica cuan no pot guanyar
        then do
            let vecColMax2 = indexMax vecPuntContrincant 0 (maximum vecPuntContrincant)
            random <- randomIO :: IO Int
            let aux = 0 + random `mod` ( (length vecColMax2 -1)- 0 + 1) 
            let col = vecColMax2!!aux -- agafem la primera ja que nomes podem tapar una
            let g = gravetat tauler col
            return (col,g) --tauler transposat
        else do
            let vecColMax = indexMax vecPuntuacio 0 (maximum vecPuntuacio) --vector amb les columnes q tenen maxima puntuació
            random <- randomIO :: IO Int
            let aux = 0 + random `mod` ( (length vecColMax -1)- 0 + 1) 
            let col = vecColMax!!aux --escollim una columna random entre les millor puntuades
            let g = gravetat tauler col
            return (col,g)


--retorna les posicions dels l'elements més grans d'un vector
--parametres: vector , index , 
indexMax :: [Int] -> Int ->Int-> [Int]
indexMax [] _ _  = []
indexMax (l:ls) i m   
    |l == m = [i] ++ indexMax ls (i+1) m
    |otherwise = indexMax ls (i+1) m

--retorna un vector amb la les fitxes consecutives que hi hauria per la maquina si tires una  fitxa
-- a cada columna 
insersio_multiple :: [[Int]] -> Int -> Int ->[Int]
insersio_multiple t col j
    |col < length t && gravetat t col > (-1)  = [puntuacio t2 j ] ++ insersio_multiple t (col+1) j
    | col < length t = [-1] ++ insersio_multiple t (col+1) j
    | col >= length t = []
    where 
        t2 = inserir_fitxa t col (gravetat t col) j --recordar tauler transposat

--retorna la quantitat maxima de fitxes consecutives en un tauler per un jugador
puntuacio:: [[Int]] ->Int  -> Int
puntuacio tauler jugador  = maximum [max1, max2, max3]
    where 
        max1 = comprobaPerFiles tauler jugador 
        max2 = comprobaPerFiles (transpose tauler) jugador
        max3 = comprobaPerDiag (transpose tauler) jugador
    
--ESTRATÈGIA SMART----------------------------------------------------------------------------------

smart:: [[Int]] -> IO(Int,Int)
smart tauler = do
    let vecPuntuacio = insersio_multiple  tauler 0 (-1) --vector amb la puntuacio si tirem a cada columna v[0] puntuacio si tirem a la columna 0
    let vecPuntContrincant = insersio_multiple  tauler 0 1 
    if ( (any (>3) vecPuntContrincant) && (any (>3) vecPuntuacio) == False) --nomes es sacrifica cuan no pot guanyar
        then do
            let vecColMax2 = indexMax vecPuntContrincant 0 (maximum vecPuntContrincant)
            random <- randomIO :: IO Int
            let aux = 0 + random `mod` ( (length vecColMax2 -1)- 0 + 1) 
            let col = vecColMax2!!aux -- agafem un random on tapar
            let g = gravetat tauler col
            return (col,g)
        else do
            let vecColMax = indexMax vecPuntuacio 0 (maximum vecPuntuacio) --vector amb les columnes q tenen maxima puntuació
            random <- randomIO :: IO Int
            let aux = 0 + random `mod` ( (length vecColMax -1)- 0 + 1) 
            let col = vecColMax!!aux --escollim una columna random entre les millor puntuades
            let g = gravetat tauler col
            return (col,g)


--FUNCIONS PER SABER FINS ON CAU LA FITXA QUAN LA POSES EN UNA COLUMNA------------------------------------------

-- indica fins a on cauria la fitxa si la introduim en una certa columna (recordar tauler transposat)
-- si en la columna no hi cap la fitxa retorna -1
--parametres : tauler, columna  (que ara es fila)
gravetat :: [[Int]] -> Int -> Int
gravetat (t:ts) fil 
    | fil == 0 = posicio t
    | fil > 0 = gravetat ts (fil-1)


--retorna el numero de celes buides que hi ha en una columna (ara es fila ja que el tauler esta girat)
--per tant calcula fins on pot caure una fitxa en una columna.
posicio :: [Int] -> Int
posicio [x]
    |x /= 0 = -1
    |x == 0 = 0
posicio (x:x2:xs)
    |(x == 0 && x2 /= 0) = 0
    |(x == 0 && x2 == 0) = 1 + posicio (x2:xs) 
    |x /= 0  = -1

--FUNCIONS CONSTRUCCIÓ TAULER---------------------------------------------------------------------------------
--construeix una matriu de zeros
--parametres: fila columna 
construir_tauler :: Int -> Int -> [[Int]]
construir_tauler 0 _ = []
construir_tauler fil col = zeros col : construir_tauler (fil-1) col 

--retorna un vector de 0 
zeros :: Int -> [Int]
zeros 0 = []
zeros a = [0] ++ zeros (a-1)

--FUNCIONS PER MODIFICAR EL TAULER AL FER UNA TIRADA --------------------------------------------------------

-- insereix una fitxa del jugador a la posició indicada
--parametres: tauler fila columna jugador (1/-1)
inserir_fitxa :: [[Int]] -> Int -> Int -> Int ->  [[Int]]
inserir_fitxa tauler fil col j = (inserir2D j fil col tauler)

inserir_fitxaFOS :: [[Int]] -> ([[Int]] -> Int-> IO (Int,Int) )-> Int -> Int ->  IO [[Int]]
inserir_fitxaFOS t f j m = do 
    (fil,col) <- f t m 
    return (inserir2D j fil col t)
    

--insereix element en array 2d
inserir2D :: a -> Int -> Int -> [[a]] -> [[a]]
inserir2D x'  0 py (r:rs) = inserir1D x' py r : rs
inserir2D x' px py (r:rs) = r : inserir2D x' (px - 1) py rs

--insereix element en array 1d
inserir1D :: a -> Int -> [a] -> [a]
inserir1D x' 0 (_:xs) = x':xs
inserir1D x' p (x:xs) = x : inserir1D x' (p - 1) xs

--FUNCIONS PER MOSTRAR EL TAULER CORRECTAMENT-----------------------------------------------------------------
-- A RECORDAR:  per tal de facilitar la feina el programa tracta tota l'estona amb una translacio
-- del taule, és a dir, les files ara passen a ser columnes i les columnes files. Per tant al 
-- imprimir tauler li passem  EL TAULER TRANSPOSAT
--mostra per pantalla el tauler 
print_tauler :: [[Int]] -> IO() 
print_tauler t = do
    mapM_ putStrLn (tauler_string  (transpose t)) --TRANSPOSEM 
    putStrLn (numString 1 (length t))

--passa el tauler a string per poder imprimir
tauler_string ::  [[Int]]-> [String]
tauler_string [] = []
tauler_string (t:ts) = fila_string t  : tauler_string ts


--converteix una fila del tauler a un string
fila_string :: [Int] -> String
fila_string [] = ""
fila_string (l:ls) = convert l ++ " "++ fila_string ls


--per fer-ho bonic cambia els 0,1,-1 del tauler per caràcters més agradables
convert:: Int -> String
convert l 
    |l == 1 = "X"
    |l == (-1) = "O"
    |otherwise = "-"

--per imprimir el el número de cada columna sota el tauler
numString:: Int -> Int -> String
numString a b 
    |a<= b = (show a::String) ++ " "++  numString (a+1) b
    |a>b = "<-columna" 