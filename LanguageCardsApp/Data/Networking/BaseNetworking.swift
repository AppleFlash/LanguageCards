//
//  BaseNetworking.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 13.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import RxSwift
import RxCocoa

typealias ServerErrorType = Decodable & LocalizedError

struct YandexError: Error, Decodable {
    enum CodingKeys: String, CodingKey {
        case code, message
    }
    
    let code: Int
    let message: String
}

extension YandexError: LocalizedError {
    var errorDescription: String? {
        return "Status: \(code). Reason: \(message)"
    }
}

enum NetworkErrorResponse<Response: ServerErrorType>: Error {
    case noInternet
    case server(Response)
    case unknown
    case parsing(Error)
}

class BaseNetworking {
    typealias NetworkResult<Success: Decodable, Failure: ServerErrorType> = Result<Success, NetworkErrorResponse<Failure>>
    
    private let session: URLSession = .shared
    
    func perform<Success: Decodable, Failure: ServerErrorType>(url: URL) -> Single<NetworkResult<Success, Failure>> {
        let request = URLRequest(url: url)
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    return .success(try JSONDecoder().decode(Success.self, from: data))
                } catch {
                    return .failure(.parsing(error))
                }
            }
            .asSingle()
            .catchError { error -> Single<NetworkResult<Success, Failure>> in
                switch error {
                case let RxCocoaURLError.httpRequestFailed(_, data) where data != nil:
                    do {
                        let parsedError = try JSONDecoder().decode(Failure.self, from: data!)
                        return .just(.failure(.server(parsedError)))
                    } catch {
                        return .just(.failure(.parsing(error)))
                    }
                default:
                    return .just(.failure(.unknown))
                }
            }
    }
}
