import Foundation
import Combine

class Requests {
    
    func loadUser() -> AnyPublisher<User, Error> {
        let url = URL(string: "http://a-url.com")!
        URLSession.shared.dataTaskPublisher(for: url).tryMap { result in
            guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode <= 200 && httpResponse.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return result.data
        }.decode(type: User.self, decoder: JSONDecoder())
    }
    
}

struct User: Codable {
    let id: UUID
}
