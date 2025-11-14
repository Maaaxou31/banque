# ES_Banque - Système Bancaire pour FiveM

Système bancaire complet pour serveurs FiveM GTA RP compatible avec **ESX (es_extended)** et **oxmysql**.

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

Assurez-vous d'avoir installé :
- **es_extended** (framework ESX)
- **oxmysql** (base de données)

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

## Intégration avec ESX

Le système utilise les fonctions d'ESX pour :
- Obtenir les informations du joueur (`ESX.GetPlayerFromId`)
- Gérer l'argent liquide (`getMoney`, `addMoney`, `removeMoney`)
- Gérer l'argent bancaire (`getAccount('bank')`, `addAccountMoney`, `removeAccountMoney`)
- Afficher les notifications (`ESX.ShowNotification`)
- **Synchronisation automatique** : Toutes les modifications d'argent sont automatiquement synchronisées avec la base de données par ESX

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

- **Synchronisation automatique** : L'argent est automatiquement synchronisé avec la base de données via ESX
- **Pas de modification d'es_extended nécessaire** : Fonctionne directement avec ESX sans modifications
- **Compatible avec tous les scripts ESX** : Utilise les mêmes fonctions standard qu'ESX pour gérer l'argent
- **Sécurisé** : Toutes les transactions sont gérées côté serveur

## Crédits

Développé pour les serveurs FiveM GTA RP utilisant ESX (es_extended) et oxmysql.
