# Premier rendu #

## Le simulateur ##
  * peut charger des fichiers en mémoire à l'aide de `-m file.mem` où `file.mem` est sur chaque ligne : <addresse hexa> <fichier à ajouter à cette addresse>
  * ajout d'un drapeau de dépassement de capacité sur entiers signés (*flag V(oVerflow)*)
  *  débogueur *pimpé* :
  
      *  l'affichage est un peu plus soigné
	  * affichage des noms des opcodes et pas de leur numéro
	  * ajout du `next` au `step-by-step` : si la dernière commande est `call`, en tapant `n RET`, les étapes entre ce `call` et le `return` correspondant ne seront pas affichées

## L'assembleur ##

  * Implémentation d'un préprocesseur, possédant actuellement 3 directives `#include`, `#main` et `#endmain`.
    * `#include [nom-du-fichier]` inclut les lignes d'un fichier donné à la fin. Il est possible d'utiliser un label définit dans ce fichier avec la syntaxe `[nom-du-fichier]$[nom-du-label]`. C'est pour cela que l'utilisation du caractère `$` est interdite dans la définition de label
    * Les directives `#main` et `#endmain` permettent à un fichier, s'il est inclut, de n'inclure que les lignes de code entre ces deux directives. 
  * La gestion des labels n'est pas garantie optimale
  * `.const` n'est pas encore implanté.

## Code ##
  * `mult.s` pour la multiplication sur 8 bits
  * `div.s` pour la division
  * `mults.s` pour la multiplication signée
  * `mult16.s` pour la multiplication 16 bits

  pour essayer ces codes : entrer dans le fichier, modifier les deux premières lignes avec leti r0 ... et leti r1 ...

# Deuxième Rendu #

Pour tester le deuxième rendu, après avoir vérifié la valeur de WORDSIZE dans `config`, taper `make r2` dans le répertoire racine, ou bien, après avoir compilé : `./simu -g -m bitmap/grlib.mem asm.exec/demo.obj`

## Réorganisation du projet ##

.  
├── asm.exec -> les exécutables du projet (.obj) avec leurs dépendances (.d)  
├── asm.py -> l'assembleur  
├── asm.src -> les fichiers en assembleur (.s)  
├── bitmap -> quelques outils pour afficher du texte  
├── .config -> fichier indiquant l'architecture (32 ou 64 bits)  
├── Makefile  
├── README.md -> ce fichier  
├── remarques.txt  
├── simu -> le simulateur du processeur  
├── simu.obj -> les exécutables nécessaires au simulateur (.o) et leur deps(.d)  
├── simu.src -> le code du simulateur (.cpp)  
└── todo.md -> une petite liste de choses à faire pour impressionner F.  

5 directories, 8 files


## L'assembleur ##

  * Ajout de nouvelles options :
    * `-o OUTFILE`, `--outfile OUTFILE` : permet de donner un fichier cible.
      Si ce fichier n'est pas donné, il s'agit par défaut du fichier source
      avec son extension remplacée par `.obj`
    * `-a {32, 64}`, `--architecture {32, 64}` : permet d'indiquer si le
      programme tourne sur une architecture 32 ou 64 bits. Cela est utile
      pour connaitre la taille des mots de la pile.
    * `-v VERBOSE`, `--verbose VERBOSE` : indique le niveau de verbosité.
    * `-MD`, `--make_dependencies` : génère un fichier de dépendances. Ce
      fichier contient des règles pour le Makefile indiquant pour le fichier
      cible les addresses de tous les fichiers sources inclus avec la directive
      `#include`. L'addresse du fichier de dépendance est l'addresse du fichier
      cible avec son extension remplacée par `.d`.
    les fichier assembleurs `.s` et `asm.exec` contenant les fichiers objets
    `.obj` et les fichiers de dépendance `.d`.
## Le simulateur ##

Nouvelle options `--stats` affiche les statistiques du programme exécuté, à condition que le programme termine (_ie_ qu'il y ait une ligne sautant sur elle-même à un endroit du programme).
On pourra "piper" une simulation avec un `--stats` pour une analyse graphique des fréquences d'apparition des opcodes.  
ex : ``./simu -g -m bitmap/grlib.mem --stats asm.exec/graphic.obj | ./chart.py`


## Compilation ##
  * Désormais, la compilation des fichiers assembleurs est supportée par make.
    Il est conseillé de ne plus compiler les fichiers assembleurs manuellement
    mais avec make.
  * Ajout d'un fichier `.config` indiquant si les programmes tournent sur une
    architecture 32 ou 64 bits. Une modification de ce fichier entraine une
    recompilation du simulateur et des fichiers assembleurs. Cela permet d'être
    sur que le simulateur et les fichiers `.obj` sont compatibles.

# Rendu Final #

Attention : presque tous les programmes ont été écrits pour 32 bits. Tout fonctionnement en 64 serait purement fortuit. Seul `matmul.s` nécessite 64 bits.

## L'assembleur ##
  * Renommage des directive `#include`, `#main` et `#endmain` en `.include`,
    `.main` et `.endmain`.

## Programme ##
  * Création d'un jeu 3D inspiré de Star-Wars IV. Il est possible de
    l'exécuter avec `make rf`.
  * déplacer le X-Wing avec les flèches directionelles pour passer a travers les blocs

## Statistiques ##
  * Le dossier `charts` contient plusieurs graphiques montrant les
    statistiques d'utilisation des commandes. Les fichiers `demo-attact.png`
    et `demo-noattact.png` contiennent les statistiques pour le programe
    `demo.s` avec et sans attente active, tandis que les fichiers
    `rf-attact.png` et `rf-no-attact.png` contiennent les statistiques pour
    le programme final avec et sans attente active.
  * En effet, on remarque que l'attente active déséquilibre les
    statistiques finales, quelques instructions qui font partie de l'une
    des boucles principales d'attente active sont particulièrement
    utilisées.
  * Sans attente active, pour le programme final, les instructions les plus
    utilisée sont `jumpif`, `shift`, `add2`, `add2i`, `readze/push` et...
    `xor3i`. En effet, `xor3i` est particulièrement utilisée pour effectuer
    la soustraction `x <- 127 - x` lorsqu'il s'agit d'afficher un point.
  * Nous n'avons pas eu besoin de certaines instructions logiques telles
    que `or2i`, `and2`, `and2i`, `or3`, `or3i`.
  * Les accès mémoires sont principalement utilisés pour lire des
    instuctions (~61% des lectures) ou lire l'horloge (~29% des lectures).
    Il y a 20 fois moins d'écritures que de lectures. Pour limiter les
    échanges entre le processeur et la mémoire, il faut donc faire du code
    efficace pour limiter les échanges de code, et éviter l'attente active.
