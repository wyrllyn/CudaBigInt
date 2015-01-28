CudaBigInt
==========

Utilisation
-----------

`make`

`./gpu.exe [opérateur] [entier] [entier]`

- **opérateur :** +, -, \\*, /, !, p
- **entier :** signé ou non (ex: 25, +25, -25 sont des entiers valides)


Organisation des sources
------------------------

- **main.cu:**          interprétation des arguments et exécution
- **BigInteger.cu:**    description objet BigInteger, appel des fonctions de calcul parallèle appropriées
- **utility.cu:**       fonctions utilitaires
- **kernel.cu:**        fonctions de calcul parallèle
- **cpu.cu:**           fonctions de calcul cpu


Notes
-----
- Les retenus sont appliquées après l'appel de kernel, en CPU
- La division est réalisée en grande partie par le CPU, seule les soustractions successives sont parallelisées
- La factorielle ne marche pas au-dela de 147
- On traite toujours la factorielle en tant que nombre positif