# IBMConv

Application iOS en natif utilisant les services watson :
- Cloudant pour l'enregistrement et la connexion
- Conversation pour le chatbot

## La configuration

Il faut impérativement renommer le fichier CredentialsExample.swift en CredentialsExample.swift en y ajoutant ses informations personnelles issues IBM Cloud pour l'utilisation des différents services (credentials).

![alt text](https://github.com/maxgfr/IBMConv/blob/master/tuto/vcap.png)


Il faudra également ne pas oublier d'installer les dépendances.

### Cocoapods
```
    pod install
```

### Carthage
```
    carthage update --platform iOS
```


## Conversation :

![alt text](https://github.com/maxgfr/IBMConv/blob/master/tuto/conv.png)

## Cloudant:

### La connexion :

![alt text](https://github.com/maxgfr/IBMConv/blob/master/tuto/connexion_reussi.png)

### L'enregistrement:

![alt text](https://github.com/maxgfr/IBMConv/blob/master/tuto/enregistrement_reussi.png)
