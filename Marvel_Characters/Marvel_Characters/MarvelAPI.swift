import Foundation
import CryptoKit

struct MarvelAPI {
    static let baseURL = "https://gateway.marvel.com/v1/public"
    static let publicKey = "079ccf677887cd256027c310c15e3443"
    static let privateKey = "3f636946786ae0852d0b48c993dde77c961bffa9"

    static func generateHash(ts: String) -> String {
        let toHash = ts + privateKey + publicKey
        return Insecure.MD5.hash(data: Data(toHash.utf8)).map { String(format: "%02hhx", $0) }.joined()
    }

    static func charactersEndpoint(page: Int, itemsPerPage: Int, query: String? = nil) -> String {
        let ts = String(Date().timeIntervalSince1970)
        let hash = generateHash(ts: ts)
        var url = "\(baseURL)/characters?apikey=\(publicKey)&ts=\(ts)&hash=\(hash)&limit=\(itemsPerPage)&offset=\((page - 1) * itemsPerPage)"
        if let query = query {
            url += "&nameStartsWith=\(query)"
        }
        return url
    }
}
