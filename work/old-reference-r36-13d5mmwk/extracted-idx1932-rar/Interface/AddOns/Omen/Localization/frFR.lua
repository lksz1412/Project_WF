-- French localization file, by Pettigrow
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Omen", "frFR")
if not L then return end

-- Main Omen window
L["<Unknown>"] = "<Inconnu>"
L["Omen Quick Menu"] = "Accès rapide Omen"
L["Use Focus Target"] = true
L["Test Mode"] = "Mode de test"
L["Open Config"] = "Ouvrir la fenêtre de config."
L["Hide Omen"] = "Cacher Omen"
L["Name"] = "Nom"
L["Threat [%]"] = "Menace [%]"
L["TPS"] = "MPS"
L["Toggle Focus"] = true

-- Warnings
L["|cffff0000Error:|r Omen cannot use shake warning if you have turned on nameplates at least once since logging in."] = "|cffff0000Erreur :|r Omen ne peut utiliser l'avertissement par secousse si vous avez activé les \"nameplates\" au moins une fois depuis votre connexion au jeu."
L["Passed %s%% of %s's threat!"] = "Dépassement des %s%% de la menace |2 %s !"

-- Config module titles
L["General Settings"] = "Paramètres généraux"
L["Profiles"] = "Profils"
L["Slash Command"] = "Commande slash"

-- Config strings, general settings section
L["OMEN_DESC"] = "Omen est un \"threat meter\" léger qui affiche la menace des monstres avec lesquels vous êtes en combat. Vous pouvez changer l'apparence et le comportement de Omen, et configurer différents profils pour chacun de vos personnages."
L["Alpha"] = "Transparence"
L["Controls the transparency of the main Omen window."] = "Contrôle la transparence de la fenêtre principale de Omen."
L["Scale"] = "Échelle"
L["Controls the scaling of the main Omen window."] = "Contrôle l'échelle de la fenêtre principale de Omen."
L["Autocollapse"] = "Réduire auto."
L["Collapse to show a minimum number of bars"] = "Réduit Omen afin de n'afficher qu'un nombre minimal de barres."
L["Lock Omen"] = "Verrouiller Omen"
L["Locks Omen in place and prevents it from being dragged or resized."] = "Verrouille Omen afin d'empêcher tout déplacement ou redimensionnement de la fenêtre."
L["Autocollapse Options"] = "Options de la réduction automatique"
L["Grow bars upwards"] = "Ajouter vers le haut"
L["Hide Omen on 0 bars"] = "Cacher si 0 barre"
L["Hide Omen entirely if it collapses to show 0 bars"] = "Cache complètement Omen si aucune barres n'est affichée."
L["Max bars to show"] = "Nombre max. de barres"
L["Max number of bars to show"] = "Détermine le nombre maximal de barres à afficher."
L["Background Options"] = "Options de l'arrière-plan"
L["Background Texture"] = "Texture de l'arrière-plan"
L["Texture to use for the frame's background"] = "Texture à utiliser pour l'arrière-plan du cadre."
L["Border Texture"] = "Texture de la bordure"
L["Texture to use for the frame's border"] = "Texture à utiliser pour la bordure du cadre."
L["Background Color"] = "Couleur arrière-plan"
L["Frame's background color"] = "Couleur de l'arrière-plan du cadre."
L["Border Color"] = "Couleur de la bordure"
L["Frame's border color"] = "Couleur de la bordure du cadre."
L["Tile Background"] = "Arrière-plan carreaux"
L["Tile the background texture"] = "Divise l'arrière-plan en plusieurs carreaux contenant la même texture."
L["Background Tile Size"] = "Taille des carreaux"
L["The size used to tile the background texture"] = "La taille de chaque carreau de l'arrière-plan."
L["Border Thickness"] = "Épaisseur de la bordure"
L["The thickness of the border"] = "L'épaisseur de la bordure."
L["Bar Inset"] = "Décalage des barres"
L["Sets how far inside the frame the threat bars will display from the 4 borders of the frame"] = "Définit le décalage des barres de menace par rapport aux 4 côtés du cadre."

-- Config strings, title bar section
L["Title Bar Settings"] = "Param. du titre"
L["Configure title bar settings."] = "Configure les paramètres de la barre du titre."
L["Title Bar Height"] = "Hauteur de la barre-titre"
L["Height of the title bar. The minimum height allowed is twice the background border thickness."] = "Hauteur de la barre du titre. La hauteur minimale autorisée est le double de l'épaisseur de la bordure de l'arrière-plan."
L["Title Text Options"] = "Options du texte du titre"
L["The font that the title text will use"] = "La police d'écriture que le texte du titre utilisera."
L["The outline that the title text will use"] = "Le contour que le texte du titre utilisera."
L["The color of the title text"] = "La couleur du texte du titre."
L["Control the font size of the title text"] = "Contrôle la taille de la police du texte du titre."

-- Config strings, show when... section
L["Show When..."] = "Afficher quand…"
L["Show Omen when..."] = "Afficher Omen quand…"
L["Show Omen when any of the following are true"] = "Affiche Omen quand l'une des conditions suivantes est vraie."
L["You have a pet"] = "Vous avez un familier"
L["Show Omen when you have a pet out"] = "Affiche Omen quand un familier est à vos côtés."
L["You are alone"] = "Vous êtes seul"
L["Show Omen when you are alone"] = "Affiche Omen quand vous êtes tout seul."
L["You are in a party"] = "Vous êtes en groupe"
L["Show Omen when you are in a 5-man party"] = "Affiche Omen quand vous êtes dans un groupe de 5 joueurs."
L["You are in a raid"] = "Vous êtes dans un raid"
L["Show Omen when you are in a raid"] = "Affiche Omen quand vous êtes dans un raid."
L["You are resting"] = "Vous vous reposez"
L["Show Omen when you are resting"] = "Affiche Omen quand vous êtes en repos."
L["You are in a battleground"] = "Vous êtes ds un CdB"
L["Show Omen when you are in a battleground or arena"] = "Affiche Omen quand vous êtes dans un champ de bataille ou une arène."
L["You are in a dungeon"] = "Vous êtes ds un donjon"
L["Show Omen when you are in a dungeon (5 man and raid)"] = "Affiche Omen quand vous êtes dans un donjon (à 5 ou en raid)."
L["In addition to the above options..."] = true
L["Only show when in combat"] = true
L["Turning this on will cause Omen to hide whenever you are not in combat."] = true

-- Config strings, show classes... section
L["Show Classes..."] = "Afficher les classes…"
L["SHOW_CLASSES_DESC"] = "Affiche les barres de menace de Omen pour les classes suivantes. Les classes mentionnées ici se réfèrent uniquement aux personnes présentes dans votre groupe/raid, à l'exception de l'option 'Pas dans le groupe'."
L["Show bars for these classes"] = "Afficher les barres pour ces classes"
L["DEATHKNIGHT"] = "Chevalier de la mort"
L["DRUID"] = "Druide"
L["HUNTER"] = "Chasseur"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PET"] = "Familier"
L["PRIEST"] = "Prêtre"
L["ROGUE"] = "Voleur"
L["SHAMAN"] = "Chaman"
L["WARLOCK"] = "Démoniste"
L["WARRIOR"] = "Guerrier"
L["*Not in Party*"] = "*Pas dans le groupe*"

-- Config strings, bar settings section
L["Bar Settings"] = "Param. des barres"
L["Configure bar settings."] = "Configure les paramètres des barres."
L["Animate Bars"] = "Barres animées"
L["Smoothly animate bar changes"] = "Anime de façon fluide les variations des barres."
L["Short Numbers"] = "Nombres courts"
L["Display large numbers in Ks"] = "Affiche les grands nombres en milliers."
L["Bar Texture"] = "Texture des barres"
L["The texture that the bar will use"] = "La texture que les barres utiliseront."
L["Bar Height"] = "Hauteur des barres"
L["Height of each bar"] = "Hauteur de chaque barre."
L["Bar Spacing"] = "Espacement des barres"
L["Spacing between each bar"] = "Espacement entre chaque barre."
L["Show TPS"] = "Afficher la MPS"
L["Show threat per second values"] = "Affiche les valeurs de la menace par seconde."
L["TPS Window"] = "Fenêtre MPS"
L["TPS_WINDOW_DESC"] = "Le calcul de la menace par seconde se fait en temps réel sur une fenêtre des X dernières secondes."
L["Show Headings"] = "Afficher les en-têtes"
L["Show column headings"] = "Affiche les en-têtes des colonnes."
L["Heading BG Color"] = "Couleur A-P en-tête"
L["Heading background color"] = "Couleur de l'arrière-plan de l'en-tête."
L["Use 'My Bar' color"] = true
L["Use a different colored background for your threat bar in Omen"] = true
L["'My Bar' BG Color"] = true
L["The background color for your threat bar"] = true
L["Bar Label Options"] = "Options des labels des barres"
L["Font"] = "Police d'écriture"
L["The font that the labels will use"] = "La police d'écriture que les labels utiliseront."
L["Font Size"] = "Taille de la police"
L["Control the font size of the labels"] = "Contrôle la taille de la police des labels."
L["Font Color"] = "Couleur de la police"
L["The color of the labels"] = "La couleur des labels."
L["Font Outline"] = "Contour de la police"
L["The outline that the labels will use"] = "Le contour que les labels utiliseront."
L["None"] = "Aucun"
L["Outline"] = "Contour"
L["Thick Outline"] = "Contour épais"

-- Config strings, slash command section
L["OMEN_SLASH_DESC"] = "Ces boutons exécutent exactement les mêmes fonctions que ceux de la commande slash /omen."
L["Toggle Omen"] = "Afficher/cacher Omen"
L["Center Omen"] = "Centrer Omen"
L["Configure"] = "Configurer"
L["Open the configuration dialog"] = "Ouvre la fenêtre de configuration."

-- Config strings, warning settings section
L["Warning Settings"] = "Param. des avertissements"
L["OMEN_WARNINGS_DESC"] = "Cette section vous permet de personnaliser quand et comment Omen vous prévient si vous êtes sur le point de prendre l'aggro."
L["Enable Sound"] = "Son d'avertissement"
L["Causes Omen to play a chosen sound effect"] = "Fait jouer Omen un effet sonore choisi."
L["Enable Screen Flash"] = "Flash de l'écran"
L["Causes the entire screen to flash red momentarily"] = "Fait clignoter les bords de l'écran en rouge momentanément."
L["Enable Screen Shake"] = "Secousse de l'écran"
L["Causes the entire game world to shake momentarily. This option only works if nameplates are turned off."] = "Secoue momentanément toute la fenêtre du jeu. Cette option ne fonctionne que si les \"nameplates\" sont désactivées."
L["Enable Warning Message"] = "Msg d'avertissement"
L["Print a message to screen when you accumulate too much threat"] = "Affiche un message à l'écran quand vous avez accumulé trop de menace."
L["Warning Threshold %"] = "Seuil d'avertissement (%)"
L["Sound to play"] = "Son à jouer"
L["Disable while tanking"] = "Désactiver en tankant"
L["DISABLE_WHILE_TANKING_DESC"] = "Ne donne aucun avertissement si vous êtes en posture défensive, en forme d'ours, sous fureur vertueuse ou en présence de givre."
L["Test warnings"] = "Test d'avertissement"
L["Passed %s%% of %s's threat!"] = "Dépassement des %s%% de la menace |2 %s !"
-- Config strings, for Fubar
L["Click|r to toggle the Omen window"] = "Clic gauche|r pour afficher/cacher la fenêtre de Omen"
L["Right-click|r to open the options menu"] = "Clic droit|r pour ouvrir le menu des options"
L["FuBar Options"] = "Options FuBar"
L["Attach to minimap"] = "Attacher à la minicarte"
L["Hide minimap/FuBar icon"] = "Cacher l'icône de la minicarte/de FuBar"
L["Show icon"] = "Afficher l'icône"
L["Show text"] = "Afficher le texte"
L["Position"] = "Position"
L["Left"] = "Gauche"
L["Center"] = "Centre"
L["Right"] = "Droite"

-- FAQ
L["Help File"] = "Fichier d'aide"
L["A collection of help pages"] = "Une série de pages d'aide"
L["Frequently Asked Questions"] = "Question fréquemment posées"
L["Warrior"] = "Guerrier"

L["GENERAL_FAQ"] = [[
|cffffd200En quoi Omen3 est-il différent de Omen2 ?|r

Omen3 se fie complètement à l'API de la menace de Blizzard ainsi qu'aux évènements de menace. Il n'essaie pas de calculer ou d'extrapoler la menace contrairement à Omen2.

Omen2 utilisait ce que nous avions appelé la bibliothèque Threat-2.0. Cette bibliothèque avait pour mission de surveiller le journal de combat, le lancement des sorts, les buffs, les débuffs, les postures, les talents et les modificateurs de l'équipement afin de calculer la menace de chacun. La menace était calculée en se basant sur ce que l'on connaissait ou approximée selon les comportements observés. De nombreuses compétences telle que Repousser au loin étaient juste assumées (d'être une réduction de 50% de la menace) étant donné qu'il était pratiquement impossible de le vérifier.

La bibliothèque Threat-2.0 comprenait également la partie communication afin de diffuser votre menace aux autres membres du raid, pour autant que ces derniers utilisaient également Threat-2.0. Ces données étaient alors utilisées pour fournir une vue d'ensemble des menaces du raid.

Depuis le patch 3.0.2, Omen ne fait plus rien de cela et n'a plus besoin d'une bibliothèque de menace. Omen3 utilise le nouveau système de surveillance des menaces intégré au jeu par Blizzard pour obtenir les valeurs exactes des menaces de tous les membres. Cela signifie que Omen3 n'a pas besoin de synchroniser les données, d'analyser le journal de combat ou de faire des suppositions, permettant ainsi d'augmenter considérablement les performances au niveau du trafic réseau, du temps CPU et de la mémoire utilisée. L'implémentation de modules de boss pour les événements de menace spécifiques (comme la réinitialisation de la menace lors de l'atterrisage de Plaie-de-nuit) n'est également plus nécessaire.

Un autre avantage de cette nouvelle implementation est l'ajout de la menace des PNJs envers un monstre (ex. la forme humaine de Kalecgos). Cependant, il y a également quelques inconvénients : les fréquences de mise à jour sont beaucoup plus lentes, les détails de la menace ne peuvent être obtenues qu'à condition que quelqu'un dans votre groupe/raid cible le monstre en question et il n'est également pas possible d'obtenir la menace d'un monstre envers lequel vous n'êtes directement en combat.

|cffffd200Comment faire pour que Omen3 ressemble à Omen2 ?|r

Utilisez comme texture d'arrière-plan et de bordure la texture \"Blizzard Tooltip\" et mettez la couleur de l'arrière-plan en noir (en mettant la barre de luminosité tout en bas) et celle de la bordure en bleu.

|cffffd200Pourquoi aucune donnée de menace ne s'affiche concernant un monstre que je cible, même s'il est en combat ?|r

L'API de Blizzard ne renvoye pas de données de menace concernant les monstres envers lesquels vous n'êtes pas directement en combat. Nous pensons qu'il s'agit là d'une mesure de Blizzard afin d'économiser la bande passante.

|cffffd200Est-ce que Omen3 se synchronise ou analyse le journal de combat ?|r

Non. Omen3 n'essaie pas de se synchroniser ou d'analyser le journal de combat. Il n'y a actuellement aucune intention de le faire.

|cffffd200Les mises à jour de la menace sont lentes...|r

Omen3 met à jour les valeurs des menaces que vous voyez aussi souvent que les mises à jour des valeurs provenants de Blizzard le permettent.

|cffffd200Où puis-je signaler des bogues ou faire une suggestion ?|r

http://forums.wowace.com/showthread.php?t=14249

|cffffd200Qui a écrit Omen3 ?|r

Xinhuan (Blackrock US Alliance).
]]
L["WARRIOR_FAQ"] = [[Les données suivantes proviennent de http://www.tankspot.com/forums/f200/39775-wow-3-0-threat-values.html et datent du 2 octobre 2008 (merci à Satrina). Les nombres concernent le niveau 80.

|cffffd200Modificateurs|r
Posture de combat ____ x 80
Posture berserk ______ x 80
Maîtrise tactique ____ x 121/142/163
Posture défensive ____ x 207.35

Notez que dans nos estimations initiales de la menace (que nous utilisons actuellement dans WoW 2.0), nous égalisions 1 dégât à 1 menace, et utilisions 1.495 pour représenter le multiplicateur de la posture+défi. Nous avons vu que la méthode de Blizzard est d'utiliser le multiplicateur sans décimal, donc dans la version 2.x cela devrait être x149 (peut-être x149.5); et c'est x207 (peut-être 207.3) dans la version 3.0. Il se peut que cela permette le transport de valeurs integer au lieu de valeurs décimales à travers le réseau à des fins d'efficacité. Il semblerait que les valeurs de menace sont multipliées par 207.35 sur le serveur, puis arrondies.

Si vous souhaitez toujours utiliser la méthode 1 dégât = 1 menace, les modificateurs de posture sont 0.8 et 2.0735, etc.

|cffffd200Valeurs de menace (les modificateurs de posture s'appliquent sauf mention contraire) :|r
Cri de guerre ___________ 78 (divisé)
Enchaînement ____________ dégâts + 225 (divisé)
Cri de commandement _____ 80 (divisé)
Coup traumatisant _______ dégâts uniquement
Bouclier de dégâts ______ dégâts uniquement
Cri démoralisant ________ 63 (divisé)
Dévaster ________________ dégâts + 5% de la PA *** à re-vérifier pour la 8982 **
Esquive/Parade/Blocage __ 1 (en posture défensive avec Posture défensive améliorée uniquement)
Frappe héroïque _________ dégâts + 259
Lancer héroïque _________ 1.50 x dégâts
Gain de rage ____________ 5 (le modificateur de posture n'est pas appliqué)
Pourfendre ______________ dégâts uniquement
Vengeance _______________ dégâts + 121
Coup de bouclier ________ 36
Heurt de bouclier _______ dégâts + 770
Onde de choc ____________ dégâts uniquement
Heurtoir ________________ dégâts + 140
Renvoi de sort __________ dégâts uniquement (uniquement les sorts dirigés vers vous)
Social Aggro ____________ 0
Fracasser armure ________ 345 + 5% de la PA
Coup de tonnerre ________ 1.85 x dégâts
Vigilance _______________ 10% de la menace générée par la cible (le modificateur de posture n'est pas appliqué)

Vous ne gagnez pas de menace pour avoir renvoyé les sorts dirigés vers les alliés avec Renvoi de sort amélioré. Quand vous renvoyez un sort pour un allié, ce dernier gagne la menace générée par les dégâts infligés par le sort renvoyé.
]]

