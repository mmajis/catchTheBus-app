//
//  RestCalls.swift
//  CatchTheBus
//
//  Created by Mika Majakorpi on 29/05/16.
//  Copyright © 2016 Mika Majakorpi. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestCalls: NSObject {
    static let sharedInstance = RestCalls()
    
    let baseURL = "http://10.112.52.116/"
    
    func getConnectionData(onCompletion: (JSON) -> Void) {
        let route = baseURL
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
}