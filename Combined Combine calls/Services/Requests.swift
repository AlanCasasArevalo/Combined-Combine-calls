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
        let url = URL(string: "http://a-user.com")!
        return URLSession.shared.dataTaskPublisher(for: url).tryMap { result in
            guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode <= 200 && httpResponse.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return result.data
        }
        .decode(type: User.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func loadDetails(user: User) -> AnyPublisher<UserDetails, Error> {
        let url = URL(string: "http://a-user.com/\(user.id)/details")!
        return URLSession.shared.dataTaskPublisher(for: url).tryMap { result in
            guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode <= 200 && httpResponse.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return result.data
        }
        .decode(type: UserDetails.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func loadFriends(user: User) -> AnyPublisher<[Friend], Error> {
        let url = URL(string: "http://a-user.com/\(user.id)/friends")!
        return URLSession.shared.dataTaskPublisher(for: url).tryMap { result in
            guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode <= 200 && httpResponse.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return result.data
        }
        .decode(type: [Friend].self, decoder: JSONDecoder())
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
