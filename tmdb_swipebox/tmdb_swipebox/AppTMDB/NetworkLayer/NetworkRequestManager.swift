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
    case movieDetail = "dashboard/banners/v"
}


class NetworkManager {
    
    static let shared = NetworkManager()

    init() {
        
    }
  
    private var cancellables = Set<AnyCancellable>()
    let baseURL = "https://api.themoviedb.org/3"
    let imageURL = "https://image.tmdb.org/t/p/original"
   
    
    func postDataParamsWithoutAUth<T: Decodable>(endpoint: Endpoint, params:Data, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL + endpoint.rawValue)
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
            var request = URLRequest(url: url)
            request.httpBody = params
            request.httpMethod = "POST"
           // request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           // request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("lms@321", forHTTPHeaderField: "authentication")
            
            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
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
    
//    func postImageWithData(endpoint: Endpoint,method: HTTPMethod = .post,image: UIImage,parameters: [String: Any]) -> Future<Data,Error> {
//        return Future { promise in
//            
//            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//                promise(.failure(NSError(domain: "Invalid Image Data", code: 0, userInfo: nil)))
//                return
//            }
//            
//            guard let url = URL(string: self.baseURL.appending(endpoint.rawValue)) else {
//                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
//            }
//            
//            AF.upload(multipartFormData: { multipartFormData in
//                for (key, value) in parameters {
//                    if let data = "\(value)".data(using: .utf8) {
//                        multipartFormData.append(data, withName: key)
//                    }
//                }
//
//                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
//            },
//                      to: url,
//                      method: method,
//                      headers: HTTPHeaders(["authentication": self.auth_token]),
//                      requestModifier: { $0.timeoutInterval = 120 })
//            .publishString()
//            .map(\.data)
//            .receive(on: RunLoop.main)
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            } receiveValue: { data in
//                if let data = data {
//                    print(String(data: data,encoding: .utf8))
//                    promise(.success(data))
//                }
//            }
//            .store(in: &self.cancellables)
//        }
//    }
    
    
//    func postImage<T: Decodable>(endpoint: Endpoint, method: HTTPMethod = .post ,image: UIImage,name: String = "image",parameters: [String: Any], type: T.Type) -> Future<T, Error> {
//        return Future { promise in
//                guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//                    promise(.failure(NSError(domain: "Invalid Image Data", code: 0, userInfo: nil)))
//                    return
//                }
//
//            
//                guard let url = URL(string: self.baseURL.appending(endpoint.rawValue))
//                else {
//                    return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
//                }
//                print("URL is \(url.absoluteString)")
//
//                AF.upload(
//                    multipartFormData: { multipartFormData in
//                        for (key, value) in parameters {
//                            if let data = "\(value)".data(using: .utf8) {
//                                multipartFormData.append(data, withName: key)
//                            }
//                        }
//
//                        multipartFormData.append(imageData, withName: name, fileName: "image.jpg", mimeType: "image/jpeg")
//                    },
//                    to: url,
//                    method: method,
//                    headers: HTTPHeaders(["authentication": self.auth_token]),
//                    requestModifier: { $0.timeoutInterval = 120 } // Set a custom timeout if needed
//                )
//                .publishString()
//                .tryMap { response in
//                    guard let data = response.data else {
//                        throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
//                    }
//                    print(response.value)
//                    var jsonObj:[String:Any]?
//                    print("Token",self.auth_token)
//                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
//                    do{
//                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
//                        print("Token",self.auth_token)
//                        print("NETWORK MANAGER Data:",jsonObj)
//                    }catch{ print("erroMsg in serializing data") }
//                   
//                    
//                    let httpResponse = response.response
//                    
//                    if (httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201)
//                    {
//                        return data
//                    }
//                    else
//                    {
//                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
//                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
//                        
//                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
//                    
//                    }
//                }
//                .decode(type: T.self, decoder: JSONDecoder())
//                .receive(on: RunLoop.main)
//                .sink(receiveCompletion: { completion in
//                    if case let .failure(error) = completion {
//                        switch error {
//                        case let reEror as ResponseError:
//                            promise(.failure(reEror))
//                        case let decodingError as DecodingError:
//                            promise(.failure(decodingError))
//                        case let apiError as ResError:
//                            promise(.failure(apiError))
//                        default:
//                            promise(.failure(ResError.unknown))
//                        }
//                    }
//                }, receiveValue: { result in
//                    promise(.success(result))
//                })
//                .store(in: &self.cancellables)
//            }
//    }
    
    
 //   func putDataWithAuth<T: Decodable>(endpoint: Endpoint, params:Data, type: T.Type) -> Future<T, Error>
//    {
//        return Future<T, Error> { [weak self] promise in
//            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue))
//            else {
//                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
//            }
//            print("URL is \(url.absoluteString)")
//            var request = URLRequest(url: url)
//            request.httpBody = params
//            request.httpMethod = "PUT"
//           // request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//           // request.setValue("application/json", forHTTPHeaderField: "Accept")
//            print("Token",self.auth_token)
//            request.addValue(self.auth_token, forHTTPHeaderField: "authentication")
//            
//            URLSession.shared.dataTaskPublisher(for:request)
//                .tryMap { (data, response) -> Data in
//                    
//                    var jsonObj:[String:Any]?
//                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
//                    do{
//                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
//                    
//                        print("NETWORK MANAGER Data:",jsonObj)
//                    }catch{ print("erroMsg in serializing data") }
//                   
//                    
//                     let httpResponse = response as? HTTPURLResponse
//                    
//                    if (httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201)
//                    {
//                        return data
//                    }
//                    else
//                    {
//                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
//                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
//                        
//                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
//                    
//                    }
//                   
//                   
//                }
//                .decode(type: T.self, decoder: JSONDecoder())
//                .receive(on: RunLoop.main)
//                .sink(receiveCompletion: { (completion) in
//                    
//                    if case let .failure(error) = completion {
//                        switch error {
//                        case let reEror as ResponseError:
//                            promise(.failure(reEror))
//                        case let decodingError as DecodingError:
//                            promise(.failure(decodingError))
//                        case let apiError as ResError:
//                            promise(.failure(apiError))
//                        default:
//                            promise(.failure(ResError.unknown))
//                        }
//                    }
//                }, receiveValue:{value in
//                    print(value)
//                    promise(.success(value))
//                })
//                .store(in: &self.cancellables)
//        }
//    }
    
    func postDataWithAuth<T: Decodable>(endpoint: Endpoint,type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
           // request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           // print("Token",self.auth_token)
            request.addValue(ApiConstants.apiKey, forHTTPHeaderField: "authentication")
            
            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                        print("NETWORK MANAGER Data:",jsonObj)
                    }catch{ print("erroMsg in serializing data") }
                   
                    
                     let httpResponse = response as? HTTPURLResponse
                    
                    if((httpResponse?.statusCode ?? -1) >= 200 && (httpResponse?.statusCode ?? -1) <= 299) {
                        return data
                    } else {
                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
                        
                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
                    }
                    
//                    if (httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201)
//                    {
//                        return data
//                    }
//                    else
//                    {
//                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
//                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
//
//                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
//
//                    }
                   
                   
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
    
    func postDataWithAuth<T: Decodable>(endpoint: Endpoint, params:Data, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
            var request = URLRequest(url: url)
            request.httpBody = params
            request.httpMethod = "POST"
           // request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // print("Token",self.auth_token)
             request.addValue(ApiConstants.apiKey, forHTTPHeaderField: "authentication")
            
            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                        print("NETWORK MANAGER Data:",jsonObj)
                    }catch{ print("erroMsg in serializing data") }
                   
                    
                     let httpResponse = response as? HTTPURLResponse
                    
                    if((httpResponse?.statusCode ?? -1) >= 200 && (httpResponse?.statusCode ?? -1) <= 299) {
                        return data
                    } else {
                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
                        
                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
                    }
                    
//                    if (httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201)
//                    {
//                        return data
//                    }
//                    else
//                    {
//                        let statusCodeError = jsonObj?["statusCode"] as? Int ?? 0
//                        let statusCodeMsg = jsonObj?["message"] as? String ?? "Error parsing http data"
//
//                        throw ResponseError.init(statusCode: statusCodeError, errorMsg: statusCodeMsg)
//
//                    }
                   
                   
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
    
    
    func postDataWithoutAuth<T: Decodable>(endpoint: Endpoint, params:String, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
            let param = params ?? ""
            let paramData = param.data(using: .utf8)
            var request = URLRequest(url: url)
            request.httpBody = paramData
            request.httpMethod = "POST"
            // request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("lms@321", forHTTPHeaderField: "authentication")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // request.addValue("lms@321", forHTTPHeaderField: "Authentication")

            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    print("Param:\(param)")
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
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
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue + (params ?? "")))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
           // let param = params ?? ""
            //let paramData = param.data(using: .utf8)
            var request = URLRequest(url: url)
           // request.httpBody = paramData
            request.httpMethod = "GET"
            // request.setValue("application/json", forHTTPHeaderField: "Accept")
           // request.addValue("lms@321", forHTTPHeaderField: "authentication")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // print("Token",self.auth_token)
             request.addValue(ApiConstants.apiKey, forHTTPHeaderField: "authentication")

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
 
    func getDataWithAuthnSearchNId<T: Decodable>(endpoint: Endpoint,pListID:String?, params:String?, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue + "?search=" + (params ?? "") + (pListID ?? "")))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
           // let param = params ?? ""
            //let paramData = param.data(using: .utf8)
            var request = URLRequest(url: url)
           // request.httpBody = paramData
            request.httpMethod = "GET"
            // request.setValue("application/json", forHTTPHeaderField: "Accept")
           // request.addValue("lms@321", forHTTPHeaderField: "authentication")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            print("Token",ApiConstants.apiKey)
            request.addValue(ApiConstants.apiKey, forHTTPHeaderField: "authentication")

            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
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
    
    func getDataWithAuthnSearch<T: Decodable>(endpoint: Endpoint, params:String?, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue + "?search=" + (params ?? "")))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
           // let param = params ?? ""
            //let paramData = param.data(using: .utf8)
            var request = URLRequest(url: url)
           // request.httpBody = paramData
            request.httpMethod = "GET"
            // request.setValue("application/json", forHTTPHeaderField: "Accept")
           // request.addValue("lms@321", forHTTPHeaderField: "authentication")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // print("Token",self.auth_token)
             request.addValue(ApiConstants.apiKey, forHTTPHeaderField: "authentication")
          

            URLSession.shared.dataTaskPublisher(for:request)
                .tryMap { (data, response) -> Data in
                    
                    var jsonObj:[String:Any]?
                    print("NETWORK MANAGER Response:",response as? HTTPURLResponse)
                    do{
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
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
    
    func getDataWithAuthnAppendKey<T: Decodable>(endpoint: Endpoint, params:String?, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue + "/" + (params ?? "")))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
           // let param = params ?? ""
            //let paramData = param.data(using: .utf8)
            var request = URLRequest(url: url)
           // request.httpBody = paramData
            request.httpMethod = "GET"
            // request.setValue("application/json", forHTTPHeaderField: "Accept")
           // request.addValue("lms@321", forHTTPHeaderField: "authentication")
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
    
    
    func getDataWithAuth<T: Decodable>(endpoint: Endpoint, params:String?, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: self.baseURL.appending(endpoint.rawValue))
            else {
                return promise(.failure(ResponseError.init(statusCode: -1, errorMsg: "Error in creating url for api")))
            }
            print("URL is \(url.absoluteString)")
            let param = params ?? ""
            let paramData = param.data(using: .utf8)
            var request = URLRequest(url: url)
            request.httpBody = paramData
            request.httpMethod = "GET"
            // request.setValue("application/json", forHTTPHeaderField: "Accept")
           // request.addValue("lms@321", forHTTPHeaderField: "authentication")
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
