//
//  UsdaRestClient.swift
//  BetterYou
//
//  Created by Zack Aroui on 4/13/19.
//

import Foundation
import Alamofire

class UsdaRestClient {
    
    let usdaSearch1: String = "https://api.nal.usda.gov/ndb/search/?format=json&"
    let usdaSearch2: String = "&sort=n&max=25&offset=0&api_key=NLciqcwTewbTVBcQBN66fdk8a1gqiBukNBJ7CmlV"
    
    let usdaReeport1: String = "https://api.nal.usda.gov/ndb/V2/reports?"
    let usdaReport2: String = "&type=f&format=json&api_key=NLciqcwTewbTVBcQBN66fdk8a1gqiBukNBJ7CmlV"
    
    func getReport(foodName: String, completion: @escaping (UsdaFood?) -> Void){
        let reportUrl = usdaReeport1 + "ndbno=" + foodName + usdaReport2
        Alamofire.request(reportUrl, method: .get)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("couldn't get /search.json")
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let results = value["foods"] as? [[String: Any]] else {
                        print("Malformed data received from /reports.json service")
                        return
                }
                
                guard let fd = results[0]["food"] as? [String: Any] else {
                        print("Malformed data received from /reports.json service")
                        return
                }
                
                let food = UsdaFood(jsonData: fd)
                
                completion(food)
        }
        
    }
    
    func getSearch(keyword: String, completion: @escaping ([UsdaSearchResponse]?) -> Void){
        let searchUrl = usdaSearch1 + "ndbno=" + keyword + usdaSearch2
        Alamofire.request(searchUrl, method: .get)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("couldn't get /search.json")
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let results = value["list"] as? [String: Any] else {
                        print("Malformed data received from /search service")
                        return
                }
                
                guard let items = results["item"] as? [[String: Any]] else {
                    print("Malformed data received from /search service")
                    return
                }
                
                let rsps = items.compactMap { item in
                    return UsdaSearchResponse(jsonData: item) }
                
                completion(rsps)
        }
        
    }
    
}
