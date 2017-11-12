# Premier rendu #

## Le simulateur ##

  * ajout d'un drapeau de dépassement de capacité sur entiers signés (*flag V(oVerflow)*)
  *  débogueur *pimpé* :
  
      *  l'affichage est un peu plus soigné
	  * affichage des noms des opcodes et pas de leur numéro
	  * ajout du `next` au `step-by-step` : si la dernière commande est `call`, en tapant `n RET`, les étapes entre ce `call` et le `return` correspondant ne seront pas affichées

## L'assembleur##

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
