//
//  UsdaReportResponse.swift
//  BetterYou
//
//  Created by Zack Aroui on 4/13/19.
//

import Foundation

class UsdaFoodNutrient: NSObject {
    
    var nutrient_id: Int
    var name: String
    var group: String
    var unit: String
    var value: Int
    
    init(jsonData: [String: Any]) {
        self.nutrient_id = jsonData["nutrient_id"] as? Int ?? 0
        self.name = jsonData["name"] as? String ?? ""
        self.group = jsonData["group"] as? String ?? ""
        self.unit = jsonData["unit"] as? String ?? ""
        self.value = jsonData["value"] as? Int ?? 0
        
    }
    
    
}


