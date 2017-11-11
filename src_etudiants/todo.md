# À faire

  * `README.md` & `remarques.txt` à finir pour envoyer le premier rendu à floflo [An]. [Al]?
  * `main.cpp`: Indiquer qu'il y a un fichier `.mem` à charger en mémoire à l'aide de `-m` (expliquer ça dans `README.md` n'est pas nécessaire pour le premier rendu) et donc corriger le par défaut : `${nomdefichier/.obj/.mem}`
  * créer un "préprocesseur" : 
	  * directive `#load` pour décrire un fichier `.mem` (dans le genre `#load 0x60000 war8x8` doit écrire dans un fichier `.mem` : `0x60000 war8x8`(quel fichier, c'est une bonne question))
	  * directive `#include` pour ajouter un fichier en fin de fichier (par exemple si on veut des multiplications, pouvoir juste écrire `#include mult.s`) mais renommer les labels pour ne pas avoir de collisions (par exemple remplacer tous les `loop` dans `mult` par `mult(caractère réservé)loop`)
	  * directives `#main` et `#endmain` pour ne pas charger certains morceaux si le fichier est inclus
  
  * créer des makefiles (pour pouvoir séparer les fichiers `.s` des fichiers `.m` des fichiers `.o`)
  * assembleur
	* affichages de caractères [An]...
	* tous les autres trucs graphiques.
	* décider de ce qu'on fera pour impressionner Floflo ([An] vote Jonesforth)
  
*Nota bene*, seul le premier point est vraiment urgent
