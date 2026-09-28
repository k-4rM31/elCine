# elCine

**elCine** est une application Flutter de découverte de films et séries basée sur l'API [TMDb](https://www.themoviedb.org/documentation/api). Elle propose l'authentification, la recherche, les détails des contenus, les recommandations, une watchlist, un cache local et un mode hors-ligne.

> L'application ne sert pas à regarder des films ou séries : elle sert à les **découvrir**, consulter leurs informations, et organiser sa liste d'envies — dans une expérience moderne inspirée de Netflix.

---

## Fonctionnalités

| Écran | Description | État |
|---|---|---|
| **Authentification** | Connexion / inscription / déconnexion, gestion access + refresh token | En cours |
| **Accueil** | Tendance de la semaine, sélection "Pour commencer", pull-to-refresh | Fonctionnel |
| **Détail** | Titre, affiche, synopsis, note, date de sortie, ajout à la watchlist | À venir |
| **Shorts** | Bandes-annonces (architecture prête pour YouTube/TMDb trailers) | À venir (placeholder) |
| **Recherche** | Recherche multi (films, séries, personnes) via TMDb | À venir (placeholder) |
| **Ciné IA** | Interface de recommandations personnalisées en langage naturel | À venir (placeholder) |
| **Profil** | Infos utilisateur, watchlist, préférences, déconnexion | À venir (placeholder) |

**Légende** : Fonctionnel · En cours · Placeholder / à venir

---

## Architecture

Le projet suit une **Clean Architecture** organisée en **Feature-First**, avec le **Repository Pattern** comme point de bascule entre données distantes et locales.

```
lib/
├── core/                        # Code transverse, utilisé par toutes les features
│   ├── constants/                  # URLs et endpoints TMDb
│   ├── di/                         # Injection de dépendances (get_it)
│   ├── error/                      # Failure (domain) & Exception (data)
│   ├── network/                    # DioClient, intercepteurs, mapping d'erreurs, Hive
│   ├── router/                     # Navigation (go_router) + bottom nav shell
│   ├── theme/                      # Thème sombre, couleurs
│   ├── usecase/                    # Contrat UseCase générique
│   └── widgets/                    # Composants UI réutilisables
│
├── features/
│   ├── auth/
│   ├── home/                    # Feature pilote, complète (référence du pattern)
│   ├── detail/
│   ├── search/
│   ├── shorts/
│   ├── cine_ia/
│   ├── watchlist/
│   └── profile/
│       └── {data, domain, presentation}/
│
test/
└── features/home/data/repositories/   # Tests unitaires du repository
```

### Les 3 couches, dans chaque feature

```
presentation  →  domain  ←  data
```

- **`domain`** : Dart pur. Entités, contrats de repository (`abstract class`), usecases. Ne connaît ni Dio, ni Hive, ni Flutter.
- **`data`** : implémente les contrats du domain. Contient les *models* (JSON ↔ entité), les *datasources* (remote via Dio, local via Hive) et l'implémentation du repository.
- **`presentation`** : écrans, widgets, providers Riverpod. Ne connaît que le `domain` (usecases), jamais directement Dio ou Hive.

### Flux de gestion des erreurs

```
DataSource (Dio / Hive)
   │  throw NetworkException / ServerException / CacheException
   ▼
Repository (seul endroit avec try/catch)
   │  catch (e) → return Left(Failure) ou Right(Data)
   ▼
UseCase → Provider Riverpod
   │  Either<Failure, T>
   ▼
UI
   │  either.fold(afficherErreur, afficherDonnées)
```

### Mode hors-ligne

Chaque repository suit la même logique :
1. Vérifie la connexion (`NetworkInfo`).
2. Si connecté → appelle l'API, sauvegarde le résultat en cache (Hive), retourne les données.
3. Si non connecté → retourne les données du cache local.
4. Si ni API ni cache disponibles → retourne un `Failure` explicite (jamais une liste vide silencieuse).

---

## Stack technique

| Besoin | Choix | Raison |
|---|---|---|
| Langage / Framework | Flutter & Dart | Imposé |
| State management | **Riverpod** | DI intégré, testable, moderne |
| Appels HTTP | **Dio** | Intercepteurs, gestion fine des erreurs |
| Stockage local | **Hive** | Léger, rapide, simple à démarrer |
| Injection de dépendances | **get_it** | Service locator simple, explicite |
| Navigation | **go_router** | Déclaratif, gère bien les bottom nav shells |
| Gestion fonctionnelle des erreurs | **fpdart** (`Either<Failure, T>`) | Force la gestion explicite des erreurs |
| Tests | **mocktail** | Mocking sans génération de code |

---

## Installation

### Prérequis
- Flutter SDK installé ([guide officiel](https://docs.flutter.dev/get-started/install))
- Une clé API TMDb ([créer un compte et générer une clé](https://www.themoviedb.org/settings/api))

### Étapes

```bash
# 1. Cloner le projet
git clone <url-du-repo>
cd el_cine

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application avec la clé TMDb
flutter run --dart-define=TMDB_API_KEY=votre_cle_ici
```

### Lancer les tests

```bash
flutter test
```

---

## Tests

Les tests unitaires couvrent la couche **repository** de la feature `home`, garantissant le comportement du mode hors-ligne :

1. Les données récupérées depuis l'API sont sauvegardées dans le cache.
2. La recherche transmet correctement la requête au datasource distant.
3. Les données du cache sont retournées lorsque le réseau est indisponible.

Emplacement : `test/features/home/data/repositories/home_repository_impl_test.dart`

---

## Design

- Interface sombre, style plateforme de streaming.
- Couleur d'accent : jaune/vert lumineux (`#CFFF04`).
- Fond noir / bleu très sombre.
- Cartes avec coins arrondis.
- Navigation inférieure à 5 onglets : Accueil, Shorts, Recherche, Ciné IA, Profil.

---

## État du projet & prochaines étapes

Ce projet est développé de façon incrémentale, feature par feature, en suivant systématiquement le pattern validé sur `home` :

- [x] Fondations `core` (erreurs, réseau, DI, router, usecase)
- [x] Feature `home` complète (domain, data, presentation, tests)
- [x] Navigation à 5 onglets
- [ ] Feature `detail`
- [ ] Feature `search`
- [ ] Feature `auth` (backend mocké, structure prête pour un vrai backend)
- [ ] Feature `watchlist`
- [ ] Feature `shorts` (structure prête, contenu vidéo à connecter)
- [ ] Feature `cine_ia` (interface prête, IA à connecter)
- [ ] Feature `profile`
