import Foundation
import Combine

class Requests {
    
    func loadUserDetailAndFriends () -> AnyPublisher<(UserDetails, [Friend]), Error>{
        loadUser().flatMap { user in
            Publishers.Zip(self.loadDetails(user: user), self.loadFriends(user: user))
        }
        .eraseToAnyPublisher()
    }
    
    func loadUserDetails () -> AnyPublisher<UserDetails, Error>{
        loadUser().flatMap(loadDetails).eraseToAnyPublisher()
    }
    
    func loadUser() -> AnyPublisher<User, Error> {
        return load(url: URL(string: "http://a-user.com")!)
    }
    
    func loadDetails(user: User) -> AnyPublisher<UserDetails, Error> {
        return load(url: URL(string: "http://a-user.com/\(user.id)/details")!)
    }
    
    func loadFriends(user: User) -> AnyPublisher<[Friend], Error> {
        return load(url: URL(string: "http://a-user.com/\(user.id)/friends")!)
    }
    
    func load<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url).tryMap { result in
            guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode <= 200 && httpResponse.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return result.data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
}

struct User: Codable {
    let id: UUID
}

struct UserDetails: Codable {
    let id: UUID
    let name, firstName, email: String
}

struct Friend: Codable {
    let name, image: String
}
