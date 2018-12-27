//
//  NetworkManager.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/24/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    // shared session
    var session = URLSession.shared
    
    enum APIType {
        case apiRequest
        case apiImage
    }
    
    
    override init() {
        super.init()
    }
    
    
    class func sharedInstance() -> NetworkManager {
        struct Singleton {
            static var sharedInstance = NetworkManager()
        }
        return Singleton.sharedInstance
    }
    
    func taskForURLRequest(_ urlRequest: URLRequest, apiType: APIType, completionHandlerForRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForRequest(nil, NSError(domain: "taskForURLRequest", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data (happens in completion handler) s
            
            self.convertDataWithCompletionHandler(data, apiType:apiType, completionHandlerForConvertData: completionHandlerForRequest)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    private func convertDataWithCompletionHandler(_ data: Data, apiType: APIType, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            switch apiType {
                case .apiRequest:
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                case .apiImage:
                    parsedResult = data as AnyObject
            }
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

    // create a URL from parameters
    func urlFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.MovieDB.APIScheme
        components.host = Constants.MovieDB.APIHost
        components.path = withPathExtension ?? ""
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func urlForMovieImage(withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.MovieDBImage.APIScheme
        components.host = Constants.MovieDBImage.APIHost
        components.path = withPathExtension ?? ""
        
        return components.url!
    }
    
    
}
