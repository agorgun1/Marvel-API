import Foundation

class MarvelAPIService {
    static let shared = MarvelAPIService()
    private var currentTask: URLSessionDataTask?

    func getCharacters(from endpoint: String, completion: @escaping (Result<[Character], Error>) -> Void) {
        
        currentTask?.cancel()

        guard let url = URL(string: endpoint) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        }

        currentTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as? URLError, error.code == .cancelled {
                return 
            }

            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
            }

            do {
                let response = try JSONDecoder().decode(CharacterResponse.self, from: data)
                completion(.success(response.data.results))
            } catch {
                completion(.failure(error))
            }
        }

        currentTask?.resume()
    }
}
