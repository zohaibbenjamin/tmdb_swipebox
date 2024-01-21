//
//  NetworkRequestManager.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import Combine
import Foundation
import Alamofire

struct ApiConstants {
    static let apiKey = "b057623fa2b1875bed99c945c6f7b329"
    static let baseUrl = "https://api.themoviedb.org/3"
    static let originalImageUrl = "https://image.tmdb.org/t/p/original"
    static let smallImageUrl = "https://image.tmdb.org/t/p/w154"
}

enum Endpoint: String {
    case searchPopularMovies = "/search/movie"
    case popularMovies = "/movie/popular"
    case movieDetail = "/movie/"
}


class NetworkManager {
    
    static let shared = NetworkManager()

    init() {
        
    }
  
    private var cancellables = Set<AnyCancellable>()
    let baseURL = "https://api.themoviedb.org/3"
    let imageURL = "https://image.tmdb.org/t/p/original"

    
    func makeRequest(request: URLRequest) -> Future<Data, Error>{
        return Future<Data,Error> { [weak self] promise in
            guard let self = self else {return}
            URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                        break
                    }
                } receiveValue: { data in
                    print(String(data: data,encoding: .utf8))
                    promise(.success(data))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func getDataWithAuthnAppendID<T: Decodable>(endpoint: Endpoint, params:String?, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue + (params ?? "") + "?language=en-PK&api_key=\(ApiConstants.apiKey)"))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
            var request = URLRequest(url: url)

            request.httpMethod = "GET"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
             request.addValue("Bearer \(ApiConstants.apiKey)", forHTTPHeaderField: "Authorization")
           // request.addValue("Bearer 181af7fcab50e40fabe2d10cc8b90e37", forHTTPHeaderField: "authorization")
            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                   
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        print("Token",ApiConstants.apiKey)
                        print("NETWORK MANAGER Data:",jsonObj)
                    }catch{ print("erroMsg in serializing data") }
                   
                    
                     let httpResponse = response as? HTTPURLResponse
                    
                    if (httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201)
                    {
                        return data
                    }
                    else
                    {
                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
                        
                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
                    
                    }
                   
                   
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    
                    if case let .failure(error) = completion {
                        switch error {
                        case let reEror as ResponseError:
                            promise(.failure(reEror))
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as ResError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(ResError.unknown))
                        }
                    }
                }, receiveValue:{value in
                    print(value)
                    promise(.success(value))
                })
                .store(in: &self.cancellables)
        }
    }
 
    
    func getDataWithQuery<T: Decodable>(endpoint: Endpoint,parameters: [String: String],type: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self]  promise in
            guard let self = self else {return}
            
            let url = self.baseURL.appending(endpoint.rawValue)
            var urlComponent = URLComponents(string: url)!
            urlComponent.queryItems = parameters.map{ URLQueryItem(name: $0.key, value: $0.value)}
            var request = URLRequest(url: urlComponent.url!)
            request.httpMethod = "GET"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue(ApiConstants.apiKey, forHTTPHeaderField: "authentication")
            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    var jsonObj:[String:Any]?
                    print("Token",ApiConstants.apiKey)
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        print("Token",ApiConstants.apiKey)
                        print("NETWORK MANAGER Data:",jsonObj)
                    }catch{ print("erroMsg in serializing data") }
                   
                    
                     let httpResponse = response as? HTTPURLResponse
                    
                    if (httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201)
                    {
                        return data
                    }
                    else
                    {
                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
                        
                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
                    
                    }
                   
                   
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    
                    if case let .failure(error) = completion {
                        switch error {
                        case let reEror as ResponseError:
                            promise(.failure(reEror))
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as ResError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(ResError.unknown))
                        }
                    }
                }, receiveValue:{value in
                    print(value)
                    promise(.success(value))
                })
                .store(in: &self.cancellables)

        }
    }
    

}


enum ResError: Error {
    case invalidURL
    case responseError
    case unknown
}

struct ResponseError:Error{
    var statusCode : Int?
    var errorMsg : String?
}



struct createParam{
    
    static var params = ""
    
   static func createParam(par:[String:String])->String{
        
        params = ""
        
        for item in par {
            params = self.params + item.key + "=" + item.value.description + "&"
        }
         
        if params.count>0
        {
        params.removeLast()
        }
       return params
    }
    
}
