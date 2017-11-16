# À faire

  * `main.cpp`: Indiquer qu'il y a un fichier `.mem` à charger en mémoire à l'aide de `-m` (expliquer ça dans `README.md` n'est pas nécessaire pour le premier rendu) et donc corriger le par défaut : `${nomdefichier/.obj/.mem}`
  * créer un "préprocesseur" :
      ????
	  * directive `#load` pour décrire un fichier `.mem` (dans le genre `#load 0x60000 war8x8` doit écrire dans un fichier `.mem` : `0x60000 war8x8`(quel fichier, c'est une bonne question))
	  * directive `#write` pour écrire des phrases à un endroit de la mémoire
	  ????
  * créer des makefiles (pour pouvoir séparer les fichiers `.s` des fichiers `.m` des fichiers `.o`)
  * assembleur
	* tous les autres trucs graphiques.
	* décider de ce qu'on fera pour impressionner Floflo
