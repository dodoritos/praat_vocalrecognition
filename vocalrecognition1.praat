#script vocal recognition stimuli ah
# Praat version 6.4.05
#23 fevrier 2024
#Lola Terny

# Formulaire bizare qui marche pas toujours chez moi...
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



# ====================================================================
# ===================== Dessin des  des consignes ====================
# ====================================================================

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


# ====================================================================
# =============== Définition des positions des bouttons ==============
# ====================================================================

# Comme ça on encode ici la position des bouttons une bonne fois pour toute.
# Ca sera utile pour détecter le clic aussi.
# N'essaye pas de comprendre parce qu'on s'en fout.

buttonRow# =        { 15, 45 }
buttonColere# =     { 10, 25, buttonRow#[1], buttonRow#[2] }
buttonJoie# =       { 30, 45, buttonRow#[1], buttonRow#[2] }
buttonTristesse# =  { 50, 65, buttonRow#[1], buttonRow#[2] }
buttonPeur# =       { 70, 85, buttonRow#[1], buttonRow#[2] }

# ====================================================================
# =================== Boucle principale de la tache ==================
# ====================================================================

numItem = 0
for row to numberOfRow
    
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
    @drawButtons

    demo Select outer viewport: 0, 100, 0, 100
    demo Axes: 0, 100, 0, 100
    demo Paint rectangle: "black", 80, 100, 0, 10
    demo White
    demo Text: 90, "centre", 5, "half", "Suivant"
    

    #attend que l'utilisateur clique (whiledemowait...)
    while demoWaitForInput()
        # Détection de tout les clicks possibles
        @demoClickedInSquare: buttonColere#
        cliskedInColere = demoClickedInSquare.result
        @demoClickedInSquare: buttonJoie#
        cliskedInJoie = demoClickedInSquare.result
        @demoClickedInSquare: buttonTristesse#
        cliskedInTristesse = demoClickedInSquare.result
        @demoClickedInSquare: buttonPeur#
        cliskedInPeur = demoClickedInSquare.result

        if cliskedInColere
            # Zone cliquée pour bouton_colere.jpg
            grade = 1
            # Erreur ici: les variable de type texte doiventent êtres entre ""
            response$ = "colère" 
            @drawButtons
            @selectButton: buttonColere#

        elsif cliskedInJoie
            # Zone cliquée pour bouton_joie.jpg
            grade = 2 
            response$ = "joie"
            @drawButtons
            @selectButton: buttonJoie#

        elsif cliskedInTristesse 
            # Zone cliquée pour bouton_tristesse.jpg
            grade = 3
            response$ = "tristesse"
            @drawButtons
            @selectButton: buttonTristesse#

        elsif cliskedInPeur
            # Zone cliquée pour bouton_peur.jpg
            grade = 4 
            response$ = "peur"
            @drawButtons
            @selectButton: buttonPeur#
        elsif demoClickedIn(35, 65, 50, 100) 
            #zone bouton icone2 replay le son
            selectObject: stimulusAudioID
            asynchronous Play
            
        elsif demoClickedIn (80, 100, 0, 10)
            if grade < 5
                # ce sont les coordonnées du bouton "suivant" encodé dans "dessiner les images"
                select resultTableID
                Set string value: row, "Sujet", sujet$
                Set string value: row, "Stimulus", nameOfStimuli$-".wav"
                Set string value: row, "Identification", response$
                Set numeric value: row, "Ident_num", grade
                
                demo Erase all
                demo 24
                demo Text: 90, "centre", 5, "half", "Suivant"
                demoWaitForInput ( )
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


# ====================================================================
# =================== Engegistrement des résultats ===================
# ====================================================================
#                              PAS TESTE


# Créer la table des résultats 
resultTableID = Create Table with column names: "Results_" + sujet$, response$, numberOfRow,
... "Sujet Stimulus Identification Ident_num"


# Sauvegarde des résultats
selectObject: resultTableID
Save as tab-separated file: "Results_Identification_" + sujet$ + ".txt"

# Nettoyage des objets Praat
removeObject: audioListID
removeObject: resultTableID
demo Erase all


# ====================================================================
# ============================ Procédures ============================
# ====================================================================

# procédure de création du rectangle s'affichant après le clic sur la réponse choisie
# rappel au sein de la boucle pour l'afficher
procedure selectButton: .buttonVector#
    demo Pink
    demo Line width: 3
    demo Draw rectangle: .buttonVector#[1]+1, .buttonVector#[2]-1, .buttonVector#[3]+1, .buttonVector#[4]-1
    demo Line width: 1
endproc

# procédure de création de boutons dorianGPT
procedure drawButtons:
    demo Insert picture from file: pathBoutonColere$,       buttonColere#[1],    buttonColere#[2],    buttonColere#[3],    buttonColere#[4]
    demo Insert picture from file: pathBoutonJoie$,         buttonJoie#[1],      buttonJoie#[2],      buttonJoie#[3],      buttonJoie#[4]
    demo Insert picture from file: pathBoutonTristesse$,    buttonTristesse#[1], buttonTristesse#[2], buttonTristesse#[3], buttonTristesse#[4]
    demo Insert picture from file: pathBoutonPeur$,         buttonPeur#[1],      buttonPeur#[2],      buttonPeur#[3],      buttonPeur#[4]
endproc

procedure demoClickedInSquare: .square#
    .result = demoClickedIn(.square#[1], .square#[2], .square#[3], .square#[4])
endproc

