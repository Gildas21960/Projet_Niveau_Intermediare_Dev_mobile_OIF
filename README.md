# Mes Notes

Application mobile de prise de notes développée avec **Flutter** et une base de données locale **SQLite**.
Projet de la semaine 6 - Développement Mobile, niveau intermédiaire (DCLIC / OIF).

**Auteur :** Mahugnon Gildas Gnonhossou

## Fonctionnalités

- **Inscription et connexion** avec nom d'utilisateur et mot de passe, et messages d'erreur clairs en cas d'échec.
- **Liste des notes** de l'utilisateur connecté, de la plus récente à la plus ancienne (titre, aperçu, date).
- **Création et modification** d'une note sur un écran d'édition dédié (boutons Annuler et Enregistrer).
- **Suppression** d'une note avec confirmation préalable.
- **Stockage local** dans SQLite : aucune connexion Internet n'est nécessaire et les données restent sur l'appareil.
- **Thème clair ou sombre** selon le réglage du téléphone.

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) 3.19 ou plus récent (Dart 3.3 ou plus récent).
- Un émulateur Android ou un téléphone Android en mode développeur.
- Un éditeur : VS Code (avec l'extension Flutter) ou Android Studio.

Vérifiez votre installation avec :

```bash
flutter doctor
```

> **Windows :** le chemin du dossier du projet ne doit contenir **aucun caractère accentué** (par exemple `Projet_Niveau_Intermediaire` et non `Projet_Niveau_Intermédiaire`), sinon la compilation Android échoue. Il est aussi préférable de placer le projet en dehors de OneDrive.

## Installation

1. Récupérez le projet :

   ```bash
   git clone <lien-du-depot-github>
   cd <dossier-du-projet>
   ```

   Si vous avez reçu une archive `.zip`, décompressez-la et ouvrez un terminal dans le dossier obtenu.

2. Installez les dépendances :

   ```bash
   flutter pub get
   ```

Les dépendances principales sont déclarées dans `pubspec.yaml` :

| Paquet    | Rôle                                        |
|-----------|---------------------------------------------|
| `sqflite` | Base de données SQLite locale               |
| `path`    | Construction du chemin du fichier de base   |
| `crypto`  | Hachage SHA-256 des mots de passe           |

## Lancement

1. Démarrez un émulateur Android ou branchez un téléphone (`flutter devices` liste les appareils détectés).
2. Lancez l'application :

   ```bash
   flutter run
   ```

> `sqflite` fonctionne sur **Android et iOS**. L'application n'est pas prévue pour le web.

## Utilisation

1. **Créer un compte :** sur l'écran de connexion, appuyez sur *Créer un compte*, choisissez un nom d'utilisateur (3 caractères minimum) et un mot de passe (6 caractères minimum), confirmez-le, puis appuyez sur *Créer le compte*. Vous êtes connecté automatiquement.
2. **Se connecter :** saisissez votre nom d'utilisateur et votre mot de passe, puis appuyez sur *Connexion*. L'icône en forme d'œil affiche ou masque le mot de passe. En cas d'erreur, un bandeau explique le problème.
3. **Ajouter une note :** sur l'écran principal, appuyez sur le bouton *Nouvelle note*, saisissez un titre (obligatoire) et un contenu, puis appuyez sur *Enregistrer*.
4. **Modifier une note :** appuyez sur la note dans la liste, changez son titre ou son contenu, puis appuyez sur *Enregistrer*. *Annuler* abandonne les changements.
5. **Supprimer une note :** appuyez sur l'icône corbeille de la note, puis confirmez avec *Supprimer*.
6. **Se déconnecter :** appuyez sur l'icône de déconnexion en haut à droite de l'écran principal.

## Structure du projet

```
lib/
  main.dart                       Point d'entrée (MonApplication, thèmes)
  models/
    user.dart                     Modèle Utilisateur
    note.dart                     Modèle Note (toMap / fromMap)
  services/
    database_helper.dart          Création de la base SQLite et CRUD des notes
    auth_service.dart             Inscription et connexion
    password_hasher.dart          Hachage des mots de passe (SHA-256 avec sel)
  screens/
    login_screen.dart             Connexion
    register_screen.dart          Création de compte
    notes_interface.dart          Liste des notes, suppression, déconnexion
    note_edit_screen.dart         Création et modification d'une note
  widgets/
    error_banner.dart             Bandeau d'erreur réutilisable
  utils/
    date_format.dart              Formatage des dates (Aujourd'hui, Hier, ...)
```

Les écrans correspondent aux wireframes du dossier de conception :

| Wireframe | Écran de l'application |
|-----------|------------------------|
| S1, S2    | `login_screen.dart` (connexion et erreur) |
| S3        | `register_screen.dart` |
| S4, S5, S6, S9 | `notes_interface.dart` (liste, liste vide, confirmation de suppression, message d'enregistrement) |
| S7, S8    | `note_edit_screen.dart` |

## Base de données

Fichier `mes_notes.db`, créé automatiquement au premier lancement.

**Table `users`**

| Colonne    | Type                                        |
|------------|---------------------------------------------|
| `id`       | INTEGER, clé primaire, auto-incrémentée     |
| `username` | TEXT, unique (sans distinction de casse)    |
| `password` | TEXT, sous la forme `sel$empreinte`         |

**Table `notes`**

| Colonne      | Type                                                        |
|--------------|-------------------------------------------------------------|
| `id`         | INTEGER, clé primaire, auto-incrémentée                     |
| `user_id`    | INTEGER, référence `users(id)` (suppression en cascade)     |
| `title`      | TEXT                                                        |
| `content`    | TEXT                                                        |
| `updated_at` | TEXT, date au format ISO 8601                               |

Chaque note appartient à un utilisateur : on ne voit et ne modifie que ses propres notes.

## Choix de conception

- **Séparation des responsabilités :** modèles, accès aux données, authentification et interface sont dans des dossiers distincts, ce qui facilite la lecture et les tests.
- **Navigation :** `Navigator.push` avec `MaterialPageRoute`. La connexion, l'inscription et la déconnexion remplacent la pile de navigation pour que le bouton Retour ne ramène pas à un écran obsolète.
- **Gestion des erreurs :** validation des formulaires (champs obligatoires, longueurs minimales, confirmation du mot de passe), erreurs d'authentification lisibles et `try/catch` autour des accès à la base, avec message à l'utilisateur.
- **Sécurité :** le mot de passe n'est jamais stocké en clair. Le même message s'affiche si le compte n'existe pas ou si le mot de passe est faux, pour ne pas révéler les noms d'utilisateur existants.
- **Écoconception :** interface sobre sans image (logo vectoriel), thème sombre automatique, aucune requête réseau, requêtes SQLite simples et rechargement de la liste uniquement après une modification.

## Limites connues

- La session n'est pas conservée : après la fermeture de l'application, il faut se reconnecter.
- Le hachage SHA-256 avec sel convient à un projet pédagogique. Pour une application en production, on utiliserait un algorithme de dérivation lent (bcrypt, Argon2) et un stockage sécurisé de la session.
- Les données sont uniquement locales : désinstaller l'application les supprime.

## Dépannage

- **`Your project path contains non-ASCII characters`** (Windows) : déplacez le projet dans un chemin sans accent, par exemple `C:\dev\mon_projet`.
- **`package:flutter_lints/flutter.yaml can't be found`** : exécutez `flutter pub add dev:flutter_lints` puis `flutter pub get`.
- **Erreur de dépendances après un changement de version** : exécutez `flutter clean` puis `flutter pub get`.
- **Repartir d'une base vide :** désinstallez l'application de l'émulateur ou du téléphone, puis relancez `flutter run`.
