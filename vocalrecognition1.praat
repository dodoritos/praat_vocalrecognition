#script vocal recognition stimuli ah
# Praat version 6.4.05
#23 fevrier 2024
#Lola Terny

# form "Input"
#     word: "Sujet", "xx" 
# endform
path$ = ""
sujet$ = "xx"
# ====================================================================
# ========== Définition des noms de dossiers et de fichiers ==========
# ====================================================================

# Aucune commande n'est vraiment lancée ici.

# Configuration des consignes

# !!! ATTENTION !!! : les chemins (path) sont différents pour Windows et MacOS.
# Tout les '/' problématiques sonts ici, c'est donc facile a changer.

pathConsigne$ = "consignes\"
pathButons$ = "boutons\"
pathIcons$ = "icones\"
pathAudio$ = "audio\"
# pathConsigne$ = "consignes/"
# pathButons$ = "boutons/"
# pathIcons$ = "icones/"

pathConsigne1$ = path$ + pathConsigne$ + "consigne1.png"
pathConsigne2$ = pathConsigne$ + "consigne2.png"
pathConsigne3$ = pathConsigne$ + "consigne3.png"
pathConsigne4$ = pathConsigne$ + "consigne4.png"
pathConsigne5$ = pathConsigne$ + "consgine5.png"

# Configuration des boutons & icones
pathBoutonIconeSon$ =   pathIcons$ + "icone_son2.png"

pathBoutonPeur$ =       pathButons$ + "bouton_peur.jpg"
pathBoutonJoie$ =       pathButons$ + "bouton_joie.jpg"
pathBoutonTristesse$ =  pathButons$ + "bouton_tristesse.jpg"
pathBoutonColere$ =     pathButons$ + "bouton_colere.jpg"


# ====================================================================
# ======== Lecture des fichiers d'items et création des tables =======
# ====================================================================

# Charger la liste des fichiers
# Erreur majeure ici. fileListID était censé contenir la liste de tes fichiers audio. 
### ERREUR -> fileListID = Create Strings as file list: "FileList", path$
# On veut donc lire tout ce qui se trouve dans "audio\".
# On vas d'ailleurs la renomer "AudioList"
audioListID = Create Strings as file list: "AudioList", pathAudio$

# On crée une nouvelle table depuis le fichier "liste_fichiers.txt". Cette table vas s'appeler liste_fichiers
Read Table from tab-separated file: "liste_fichiers.txt"

# Nombre total d'audios
numberOfRow = Get number of rows

# Créer la table des résultats => il y a un problème avec cette commande
resultTableID = Create Table with column names: "Results_" + sujet$, numberOfRow,
... "Sujet Stimulus Identification Ident_num"

# Configuration de la démo
demo Select outer viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100
demo Text: 50, "centre", 50, "half", "Cliquez pour démarrer!"
# demoWaitForInput ()

# Afficher les consignes du début
#selectObject: DemoForm
demo Select outer viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100
demo Erase all
demo Insert picture from file: path$ + pathConsigne1$, 0, 100, 0, 100
demoWaitForInput ()
demo Insert picture from file: path$ + pathConsigne2$, 0, 100, 0, 100
demoWaitForInput ()
demo Insert picture from file: path$ + pathConsigne3$, 0, 100, 0, 100
demoWaitForInput ()
demo Erase all

numItem = 0

for row to numberOfRow
    
    # Asynchronous Play
    grade = 5
    selectObject: "Table liste_fichiers"
    nameOfStimuli$ = Get value: row, "name_stimuli"
    selectObject: audioListID
    stimulusAudioID = Read from file: path$ + "audio\" + nameOfStimuli$
    selectObject: stimulusAudioID
    asynchronous Play
    demo Erase all
    demo 12
    demo Times
    demo Black
    #ça correspond à 1/56 en haut à droite de mon écran (progression des stimuli)
    demo Text: 0, "left", 99, "half", string$ (row) + "/" + string$ (numberOfRow)
    demo 24
    demo Black

    #coordonnées de réponses boutons de réponses
    demo Insert picture from file: pathBoutonIconeSon$, 35, 65, 50, 100
    @drawButtons: 15, 45

    demo Select outer viewport: 0, 100, 0, 100
    demo Axes: 0, 100, 0, 100
    demo Paint rectangle: "black", 80, 100, 0, 10
    demo White
    demo Text: 90, "centre", 5, "half", "Suivant"
    

    #attend que l'utilisateur clique (whiledemowait...)
    # Erreur ici: les variable de type texte doiventent êtres entre ""
    while demoWaitForInput()
        if demoClickedIn(10, 25, 15, 45) 
            # Zone cliquée pour bouton_colere.jpg
            grade = 1
            response$ = "colère" 
            @drawButtons: 15, 45
            @selectButton: 10, 25, 15, 45

        elsif demoClickedIn(30, 45, 15, 45) 
            # Zone cliquée pour bouton_joie.jpg
            grade = 2 
            response$ = "joie"
            @drawButtons: 15, 45
            @selectButton: 20, 45, 15, 45

        elsif demoClickedIn(50, 65, 15, 45) 
            # Zone cliquée pour bouton_tristesse.jpg
            grade = 3
            response$ = "tristesse"
            @drawButtons: 15, 45
            @selectButton: 50, 65, 15, 45

        elsif demoClickedIn(70, 85, 15, 45) 
            # Zone cliquée pour bouton_peur.jpg
            grade = 4 
            response$ = "peur"
            @drawButtons: 15, 45
            @selectButton:70, 85, 15, 45
        elsif demoClickedIn(35, 65, 50, 100) 
            #zone bouton icone2 replay le son
            selectObject: stimulusAudioID
            Asynchronous Play            
        endif
        if grade < 5
    demo White
    demo 24
    demo Text: 90, "centre", 5, "half", "Suivant"
    demoWaitForInput ( )
    if demoClickedIn (80, 100, 0, 10)
        # ce sont les coordonnées du bouton "suivant" encodé dans "dessiner les images"
        select resultTableID
        Set string value: i, "Sujet", sujet$
        Set string value: i, "Stimulus", name_stimuli$-".wav"
        Set string value: i, "Identification", response$
        Set numeric value: i, "Ident_num", grade
        #upgrade = 6
        goto NEXT
    endif	
endif
endwhile

label NEXT
removeObject: stimulusAudioID
selectObject: resultTableID
Save as tab-separated file: "Results_Identification_pauline_1_"+sujet$ +".txt"
numItem = numItem + 1
endfor 
numItem = 0

# Créer la table des résultats 
resultTableID = Create Table with column names: "Results_" + sujet$, response$, numberOfRow,
... "Sujet Stimulus Identification Ident_num"

# procédure de création du rectangle s'affichant après le clic sur la réponse choisie
# rappel au sein de la boucle pour l'afficher
procedure selectButton: .x1, .x2, .y1, .y2
    demo Pink
    demo Line width: 3
    demo Draw rectangle: .x1+1, .x2-1, .y1+1, .y2-1
    demo Line width: 1
endproc

# procédure de création de boutons chatGPT
procedure drawButtons: .row1, .row2
    demo Insert picture from file: pathBoutonColere$,       10, 25, .row1, .row2
    demo Insert picture from file: pathBoutonJoie$,         30, 45, .row1, .row2
    demo Insert picture from file: pathBoutonTristesse$,    50, 65, .row1, .row2
    demo Insert picture from file: pathBoutonPeur$,         70, 85, .row1, .row2
endproc


# Sauvegarde des résultats
selectObject: resultTableID
Save as tab-separated file: "Results_Identification_" + sujet$ + ".txt"

# Nettoyage des objets Praat
removeObject: audioListID
removeObject: resultTableID
demo Erase all
