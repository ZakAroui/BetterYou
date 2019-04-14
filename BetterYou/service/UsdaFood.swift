//
//  UsdaReportResponse.swift
//  BetterYou
//
//  Created by Zack Aroui on 4/13/19.
//

import Foundation

class UsdaFood: NSObject {
    
    var desc: UsdaFoodDesc
    var nutrients: [UsdaFoodNutrient]
    
    init(jsonData: [String: Any]) {
        self.desc = UsdaFoodDesc(jsonData: jsonData["desc"] as! [String : Any])
        
        let sList = jsonData["nutrients"] as? [[String: Any]] ?? []
        self.nutrients = sList.compactMap { s in
            return UsdaFoodNutrient(jsonData: s) }
        
    }
    
    
}


