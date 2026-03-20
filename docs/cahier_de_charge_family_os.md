# 📄 Cahier de Charge – FamilyOS

## 1. 📌 Présentation du projet

**Nom de l'application :** FamilyOS  
**Type :** Application mobile privée (Android / iOS)  
**Cible :** Usage personnel et familial  
**Objectif :** Centraliser les besoins numériques d’une famille dans une seule application sécurisée.

---

## 2. 🎯 Objectifs

- Centraliser les fichiers familiaux
- Faciliter la communication entre membres
- Organiser les tâches et événements
- Sécuriser les documents sensibles
- Créer une mémoire familiale durable

---

## 3. 👥 Utilisateurs

### 3.1 Types d’utilisateurs
- Administrateur (toi)
- Membres (famille)

### 3.2 Rôles
- Admin : gestion complète
- Membres : accès aux fonctionnalités selon permissions

---

## 4. 🔥 Fonctionnalités

### 4.1 Authentification
- Inscription (email / mot de passe)
- Connexion
- Déconnexion
- Réinitialisation de mot de passe

---

### 4.2 Gestion des utilisateurs
- Ajout de membres
- Attribution de rôles
- Suppression de comptes

---

### 4.3 Stockage de fichiers

#### Types supportés
- Images
- Vidéos
- Documents (PDF, DOCX)

#### Fonctionnalités
- Upload
- Téléchargement
- Suppression
- Organisation par dossiers

---

### 4.4 Galerie familiale
- Affichage des images
- Création d’albums
- Classement automatique

---

### 4.5 Chat familial
- Envoi de messages texte
- Envoi de fichiers
- Notifications

---

### 4.6 Agenda partagé
- Ajout d’événements
- Modification
- Suppression
- Notifications de rappel

---

### 4.7 To-Do List
- Création de tâches
- Attribution à un membre
- Marquer comme terminé

---

### 4.8 Coffre sécurisé

#### Contenu
- Documents sensibles
- Identifiants

#### Sécurité
- Chiffrement des données
- Accès restreint

---

### 4.9 Notes familiales
- Création de notes
- Modification
- Suppression

---

### 4.10 Localisation (optionnel)
- Partage de position en temps réel
- Activation/désactivation

---

## 5. 🧱 Architecture technique

### 5.1 Frontend
- Flutter

### 5.2 Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### 5.3 Stockage alternatif
- Cloudinary (images/vidéos)
- Supabase (documents)

---

## 6. 🗂️ Structure des données (Firestore)

### Users
- id
- nom
- email
- rôle

### Files
- id
- nom
- type
- url
- owner

### Messages
- id
- sender
- contenu
- timestamp

### Events
- id
- titre
- date
- description

### Tasks
- id
- titre
- assigné
- statut

---

## 7. 🔐 Sécurité

- Authentification Firebase
- Règles de sécurité Firestore
- Chiffrement des fichiers sensibles
- Gestion des permissions

---

## 8. 🎨 UI/UX

- Mode sombre
- Navigation simple (Bottom Navigation)
- Design minimaliste

---

## 9. 📦 Déploiement

- Android (APK)
- iOS (optionnel)

---

## 10. 🚀 Évolutions futures

- Authentification biométrique
- IA pour organisation automatique
- Sauvegarde automatique
- Version web

---

## 11. 📅 Planning prévisionnel

### Phase 1
- Authentification
- UI de base

### Phase 2
- Stockage
- Galerie

### Phase 3
- Chat
- Agenda

### Phase 4
- Coffre sécurisé
- Optimisation

---

## 12. ⚙️ Contraintes

- Utilisation du plan gratuit Firebase (Spark)
- Optimisation du stockage
- Connexion internet requise

---

## 13. 🧠 Conclusion

FamilyOS est une application privée visant à améliorer la gestion numérique familiale en centralisant les outils essentiels dans un environnement sécurisé et simple d’utilisation.

