import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private let favoritesKey = "favoriteCharacters"

    private init() {}

    func isFavorite(characterID: Int) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(characterID)
    }

    func toggleFavorite(characterID: Int) -> Bool {
        var favorites = getFavorites()
        if favorites.contains(characterID) {
            favorites.removeAll { $0 == characterID }
        } else {
            favorites.append(characterID)
        }
        saveFavorites(favorites)
        return favorites.contains(characterID)
    }

    func getFavorites() -> [Int] {
        return UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? []
    }

    private func saveFavorites(_ favorites: [Int]) {
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }
}
