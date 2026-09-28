/// Centralise les noms des boxes Hive utilisées dans tout le projet.
/// Pourquoi ? Une faute de frappe dans un nom de box en dur ('home_box'
/// vs 'homebox') crée un bug silencieux difficile à repérer. Ici, une
/// seule source de vérité, complétée par l'autocomplétion de l'IDE.
class HiveBoxes {
  static const String home = 'home_box';
  // On ajoutera : watchlist, auth, search... au fil des features.
}