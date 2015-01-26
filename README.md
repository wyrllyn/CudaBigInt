CudaBigInt
==========

Utilisation
-----------

`./gpu.exe [opérateur] [entier] [entier]`
- opérateur: +, -, \\*, /, !, pgcd
- entier: signé ou non (ex: 25, +25, -25 sont des entiers valides)

Organisation des sources
------------------------

- main.cu:          interprétation des arguments et exécution
- BigInteger.cu:    description objet BigInteger, appel des fonctions de calcul parallèle appropriées
- utility.cu:       fonctions utilitaires
- kernel.cu:        fonctions de calcul parallèle
- cpu.cu:           fonctions de calcul cpu