# Spécification Fonctionnelle — Application de Gestion Commerciale

## 1. Objectifs et Architecture

### 1.1 Vision
Fournir aux TPE/PME marocaines une solution complète pour piloter leurs cycles Ventes, Achats, Stocks et Trésorerie tout en respectant strictement les obligations comptables et fiscales nationales.

### 1.2 Exigences de conformité
- Gestion de la TVA marocaine avec des taux configurables.
- Champs obligatoires pour les tiers : ICE, IF et RC.
- Génération automatique des écritures comptables selon le Plan Comptable Général Marocain (PCGM).

### 1.3 Pile technologique (PERN)
- **PostgreSQL** pour la fiabilité des données financières.
- **Express.js / Node.js** avec **TypeScript** pour l'API REST sécurisée.
- **React.js** pour l'interface utilisateur dynamique, avec mode clair et sombre.

### 1.4 Expérience utilisateur
- Palette professionnelle vert-bleu.
- Tableau de bord interactif pour faciliter la prise de décision.
- Accessibilité et ergonomie pour les utilisateurs métiers.

## 2. Modules Fonctionnels

### 2.1 Gestion des Ventes
Workflow atomique : `Devis → Bon de Livraison → Facture → Règlement`.
- Le bon de livraison décrémente le stock.
- La facture crée la créance client et les écritures comptables associées.
- Le règlement met à jour la trésorerie (comptes 51xx) et clôt la créance.

### 2.2 Gestion des Achats
Workflow atomique : `Bon de Commande → Bon de Réception → Facture → Règlement`.
- Le bon de réception incrémente le stock.
- La facture fournisseur enregistre la dette et déclenche les écritures comptables.
- Le règlement solde la dette fournisseur et met à jour la trésorerie.

### 2.3 Fiches Tiers (Clients & Fournisseurs)
- Informations complètes : coordonnées, identifiants fiscaux, plafonds de crédit.
- Suivi du solde courant et de l’historique des transactions.

### 2.4 Gestion des Stocks et Produits
- Classification des produits par catégories.
- Mise à jour automatique des quantités via BL/BR.
- Journal détaillé des mouvements (entrée, sortie, inventaire).
- Alertes en cas de seuil de stock minimum atteint.

### 2.5 Comptabilité et Trésorerie
- Écritures comptables générées automatiquement pour chaque facture et règlement.
- Suivi précis des flux de caisse et de banque.
- Conformité au PCGM avec des montants gérés en `DECIMAL(10,2)`.

## 3. Sécurité et Gouvernance des Données

### 3.1 Authentification et Autorisation
- Authentification par JWT et hashage des mots de passe avec Bcrypt.
- Matrice de rôles et permissions (Admin, Comptable, Commercial, Magasinier).
- Middleware d’accès vérifiant les droits (lecture, création, modification, suppression) pour chaque module.

### 3.2 Traçabilité
- Journal d’activité obligatoire : `utilisateur_id`, `action_type`, horodatage et ressource ciblée.
- Exemple : modification du prix de vente, suppression d’une facture.

### 3.3 Intégrité des données
- Contrainte d’intégrité référentielle via clés étrangères.
- Contrôles de type et de précision financière.

## 4. Tableau de Bord & Indicateurs Clés

### 4.1 KPIs Prioritaires
- Chiffre d’affaires HT/TTC.
- Marge brute estimée.
- Total des créances clients et dettes fournisseurs.

### 4.2 Analyses et Visualisations
- Graphiques d’évolution mensuelle du chiffre d’affaires.
- Top 5 des clients et des produits par chiffre d’affaires.

### 4.3 Alertes et Notifications
- Factures impayées arrivées à échéance.
- Produits en dessous du stock minimum.

## 5. Prochaines Étapes
- Définition du modèle de données détaillé (schéma ERD).
- Rédaction des spécifications API (OpenAPI/Swagger).
- Prototypage UI/UX (maquettes haute fidélité vert-bleu + mode sombre).

