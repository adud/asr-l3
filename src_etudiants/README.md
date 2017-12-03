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

  * Nouvelles options :
	* `--stats` affiche les statistiques du programme exécuté, à condition que le programme termine (_ie_ qu'il y ait une ligne sautant sur elle-même à un endroit du programme)

## Compilation ##
  * Désormais, la compilation des fichiers assembleurs est supportée par make.
    Il est conseillé de ne plus compiler les fichiers assembleurs manuellement
    mais avec make.
  * Ajout d'un fichier `.config` indiquant si les programmes tournent sur une
    architecture 32 ou 64 bits. Une modification de ce fichier entraine une
    recompilation du simulateur et des fichiers assembleurs. Cela permet d'être
    sur que le simulateur et les fichiers `.obj` sont compatibles.
