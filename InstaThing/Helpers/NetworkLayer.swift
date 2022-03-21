//
//  NetworkLayer.swift
//  InstaThing
//
//  Created by Ahmadreza on 3/13/22.
//

import RxCocoa
import RxSwift
import Foundation

class NetworkLayer {
    
    static var shared = NetworkLayer()
    lazy var requestObservable = RequestObservable(config: .default)
    
    func searchusers(text: String)-> Observable<UsersRequestData> {
        var request = URLRequest(url: URL(string: "https://www.instagram.com/web/search/topsearch/?query=\(text.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "?")")!)
        request.httpMethod = "GET"
        request.addValue(cookie, forHTTPHeaderField: "Cookie")
        return requestObservable.callAPI(request: request, type: UsersRequestData.self)
    }
}

public class RequestObservable {
    
    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession: URLSession
    public init(config:URLSessionConfiguration) {
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
    }
    public func callAPI<T: Decodable>(request: URLRequest, type: T.Type) -> Observable<T> {
        return Observable.create { observer in
            let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    do {
                        let data = data ?? Data()
                        if (200...399).contains(httpResponse.statusCode) {
                            print("pretty print: ----------------------------------")
                            data.printFormatedJSON()
                            print("pretty print: ----------------------------------")
                            let objs = try self.jsonDecoder.decode(type.self, from: data)
                            observer.onNext(objs)
                        } else {
                            observer.onError(error!)
                        }
                    } catch {
                        if httpResponse.url?.absoluteString.contains("login") ?? false {
                            NotificationCenter.default.post(name: StrigKeys.challenge.getNotificationName(), object: nil)
                            print("******* Insta Challenge! *******")
                        } else {
                            NotificationCenter.default.post(name: StrigKeys.block.getNotificationName(), object: nil)
                            print("******* Insta Block! *******")
                        }
                        observer.onError(error)
                    }
                }
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension Data {
    
    func printFormatedJSON() {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            pringJSONData(jsonData)
        } else {
            print("Malformed JSON")
        }
    }
    
    func printJSON() {
        pringJSONData(self)
    }
    
    private func pringJSONData(_ data: Data) {
        print(String(decoding: data, as: UTF8.self))
    }
}
