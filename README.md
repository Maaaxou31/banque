# ES_Banque - Système Bancaire pour FiveM

Système bancaire complet pour serveurs FiveM GTA RP compatible avec **ESX (es_extended)**, **jaksam_core** et **oxmysql**.

## Compatibilité Multi-Framework

Ce système détecte **automatiquement** le framework utilisé sur votre serveur :
- ✅ **ESX (es_extended)** - Compatible
- ✅ **jaksam_core** - Compatible

**Pas besoin de configuration** : Le système s'adapte automatiquement au framework détecté au démarrage !

## Fonctionnalités

- Déposer de l'argent liquide sur son compte bancaire
- Retirer de l'argent de son compte bancaire
- Transférer de l'argent à d'autres joueurs
- Interface utilisateur moderne et intuitive
- Blips sur la carte pour les banques et distributeurs
- Markers 3D aux emplacements des banques et ATM
- Commandes admin pour gérer l'argent des joueurs
- Compatible avec oxmysql
- Système d'exports pour d'autres ressources

## Installation

### 1. Télécharger et installer

1. Placez le dossier `banque` dans votre dossier `resources`
2. Ajoutez `ensure banque` dans votre `server.cfg`

### 2. Base de données

Exécutez le fichier `sql/install.sql` dans votre base de données MySQL :

```sql
-- Créer la table des transactions
SOURCE sql/install.sql
```

**IMPORTANT** : Assurez-vous que votre table `users` contient une colonne `bank`. Si ce n'est pas le cas, exécutez :

```sql
ALTER TABLE `users` ADD COLUMN `bank` INT NOT NULL DEFAULT 0;
```

### 3. Configuration

Éditez le fichier `config.lua` pour personnaliser :
- Les positions des banques et distributeurs
- Les distances d'interaction
- Les markers et blips
- Les montants min/max

### 4. Dépendances

Assurez-vous d'avoir installé **un des frameworks suivants** :
- **es_extended** (framework ESX) **OU**
- **jaksam_core** (framework jaksam)

Et également :
- **oxmysql** (base de données) - optionnel pour l'historique des transactions

## Utilisation

### Pour les joueurs

1. Rendez-vous à une banque ou un distributeur (marqués sur la carte)
2. Appuyez sur **E** pour interagir
3. Utilisez l'interface pour :
   - **Déposer** : Transférer votre argent liquide vers votre compte
   - **Retirer** : Récupérer de l'argent liquide depuis votre compte
   - **Transférer** : Envoyer de l'argent à un autre joueur

### Commandes

- `/bank` - Ouvrir le menu bancaire (n'importe où)
- `/givebank [id] [montant]` - (Admin) Donner de l'argent à un joueur

### Raccourcis clavier

- **E** - Interagir avec une banque/ATM
- **ESC** - Fermer le menu
- **Enter** - Valider une action

## Configuration avancée

### Modifier les positions des banques

Éditez `config.lua` et modifiez le tableau `Config.BankLocations` :

```lua
Config.BankLocations = {
    {x = 149.46, y = -1040.54, z = 29.37, name = "Fleeca Bank"},
    -- Ajoutez vos positions ici
}
```

### Modifier les positions des ATM

Éditez `config.lua` et modifiez le tableau `Config.ATMLocations` :

```lua
Config.ATMLocations = {
    {x = 147.44, y = -1035.69, z = 29.34},
    -- Ajoutez vos positions ici
}
```

### Exports disponibles

Vous pouvez utiliser ces exports dans d'autres ressources :

```lua
-- Obtenir le solde bancaire d'un joueur
local balance = exports['banque']:GetBankBalance(identifier)

-- Ajouter de l'argent au compte bancaire
exports['banque']:AddBankMoney(identifier, amount)

-- Retirer de l'argent du compte bancaire
exports['banque']:RemoveBankMoney(identifier, amount)
```

## Intégration Multi-Framework

Le système utilise un **bridge automatique** pour s'adapter au framework :

### Avec ESX (es_extended) :
- Obtenir les informations du joueur (`ESX.GetPlayerFromId`)
- Gérer l'argent liquide (`getMoney`, `addMoney`, `removeMoney`)
- Gérer l'argent bancaire (`getAccount('bank')`, `addAccountMoney`, `removeAccountMoney`)
- Afficher les notifications (`ESX.ShowNotification`)
- **Synchronisation automatique** avec la base de données

### Avec jaksam_core :
- Obtenir les informations du joueur (`jaksam.GetPlayerFromId`)
- Gérer l'argent liquide (`getMoney`, `addMoney`, `removeMoney`)
- Gérer l'argent bancaire (`getAccount('bank')`, `addAccountMoney`, `removeAccountMoney`)
- Afficher les notifications (`jaksam.ShowNotification`)
- **Synchronisation automatique** avec la base de données

Le système **détecte automatiquement** au démarrage quel framework est présent et utilise les bonnes fonctions.

## Structure des fichiers

```
banque/
├── client/
│   └── main.lua          # Logique client
├── server/
│   └── main.lua          # Logique serveur
├── html/
│   ├── ui.html           # Interface utilisateur
│   ├── style.css         # Styles
│   └── script.js         # Logique UI
├── sql/
│   └── install.sql       # Schéma de base de données
├── bridge.lua            # Bridge multi-framework (ESX/jaksam)
├── config.lua            # Configuration
├── fxmanifest.lua        # Manifest FiveM
└── README.md             # Documentation
```

## Support

Pour toute question ou problème :
1. Vérifiez que toutes les dépendances sont installées
2. Vérifiez les logs du serveur (`F8` dans le jeu)
3. Assurez-vous que la base de données est correctement configurée

## Licence

Ce projet est libre d'utilisation pour vos serveurs FiveM.

## Avantages de cette version

- **🔄 Compatible Multi-Framework** : Fonctionne avec ESX ET jaksam_core automatiquement
- **🚀 Détection automatique** : Pas besoin de choisir le framework, c'est automatique
- **💾 Synchronisation automatique** : L'argent est automatiquement synchronisé avec la base de données
- **✅ Plug & Play** : Aucune modification du framework nécessaire
- **🔒 Sécurisé** : Toutes les transactions sont gérées côté serveur
- **🎨 Interface moderne** : UI responsive et intuitive

## Crédits

Développé pour les serveurs FiveM GTA RP.
Compatible avec ESX (es_extended), jaksam_core et oxmysql.
