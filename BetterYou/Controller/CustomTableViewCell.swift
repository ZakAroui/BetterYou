//
//  customTableViewCell.swift
//  BetterYou
//
//  Created by Christian Lopez on 4/14/19.
//

import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell{
    @IBOutlet weak var NutrientData: UILabel!
    @IBOutlet weak var UnitData: UILabel!
    @IBOutlet weak var ValuePer100g: UILabel!
    
    
    func SetDataValues(Nutrient: String, Unit: String, Value: String){
        NutrientData.text = Nutrient
        UnitData.text = Unit
        ValuePer100g.text = Value 
    }
    
}
