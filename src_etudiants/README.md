# Premier rendu #

## Le simulateur ##

  * ajout d'un drapeau de dépassement de capacité sur entiers signés (*flag V(oVerflow)*)
  *  débogueur *pimpé* :
  
      *  l'affichage est un peu plus soigné
	  * affichage des noms des opcodes et pas de leur numéro
	  * ajout du `next` au `step-by-step` : si la dernière commande est `call`, en tapant `n RET`, les étapes entre ce `call` et le `return` correspondant ne seront pas affichées

## L'assembleur##

  * La gestion des labels n'est pas garantie optimale
  * `.const` n'est pas encore implanté.

## Code ##
  * `mult.s` pour la multiplication sur 8 bits
  * `div.s` pour la division
  * `mults.s` pour la multiplication signée
  * `mult16.s` pour la multiplication 16 bits

## Remarques ##

  * Pourquoi les sauts absolus sont-ils signés ?
  * 4 pointeurs, dont 2 utilisables, c'est vraiment **très** peu
  * assembler les distances de saut à la main, **plus jamais** (surtout avec des opérandes de taille variable).
