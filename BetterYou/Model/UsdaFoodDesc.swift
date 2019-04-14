//
//  UsdaReportResponse.swift
//  BetterYou
//
//  Created by Zack Aroui on 4/13/19.
//

import Foundation

class UsdaFoodDesc: NSObject {
    
    var ndbno: String
    var name: String
    var sd: String
    var fg: String
    var ru: String
    
    init(jsonData: [String: Any]) {
        self.ndbno = jsonData["ndbno"] as? String ?? ""
        self.name = jsonData["name"] as? String ?? ""
        self.sd = jsonData["sd"] as? String ?? ""
        self.fg = jsonData["fg"] as? String ?? ""
        self.ru = jsonData["ru"] as? String ?? ""
    }
    
}


