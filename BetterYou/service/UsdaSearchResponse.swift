//
//  UsdaSearchResponse.swift
//  BetterYou
//
//  Created by Zack Aroui on 4/13/19.
//

import Foundation


class UsdaSearchResponse: NSObject {
    
    var offset: Int
    var group: String
    var name: String
    var ndbno: String
    var ds: String
    var manu: String
    
    
    init(jsonData: [String: Any]) {
        self.offset = jsonData["offset"] as? Int ?? 0
        self.group = jsonData["group"] as? String ?? ""
        self.name = jsonData["name"] as? String ?? ""
        self.ndbno = jsonData["ndbno"] as? String ?? ""
        self.ds = jsonData["ds"] as? String ?? ""
        self.manu = jsonData["manu"] as? String ?? ""
    }
    
    
}


