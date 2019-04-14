//
//  FoodInformationViewController.swift
//  BetterYou
//
//  Created by Christian Lopez on 4/14/19.
//

import Foundation
import UIKit

class FoodDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var nutrientLbl: UILabel!
}

class FoodDetailsTableVC: UITableViewController {
    var nutrientList: [UsdaFoodNutrient] = []
    var food: UsdaFood!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usdaRc = UsdaRestClient()
        usdaRc.getReport(foodName: "09320", completion: {fd in
            self.food = fd!
            self.nutrientList = self.food.nutrients
            self.tableView.reloadData()
        })
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nutrientList.count
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        switch(segue.identifier ?? "") {
//        case "ShowSocialWeb":
//            print("inside ShowSocialWebSegue")
//            let webViewVC : WebViewVC = segue.destination as! WebViewVC;
//
//            guard let selectedSocialCell = sender as? TeamSocialTableViewCell else {
//                fatalError("Unexpected sender: \(sender)")
//            }
//
//            guard let indexPath = tableView.indexPath(for: selectedSocialCell) else {
//                fatalError("The selected cell is not being displayed by the table")
//            }
//
//            let selectedSocial = teamSocialList[indexPath.row]
//            webViewVC.sourceVc = WebViewSource.social
//            webViewVC.teamSocial = selectedSocial
//
//        default:
//            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
//        }
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodDetailsCell", for: indexPath) as! FoodDetailsTableViewCell
        
        let nutrient = nutrientList[indexPath.row]
        cell.nutrientLbl?.text = nutrient.name
        cell.valueLbl?.text = String(nutrient.value)
        cell.unitLbl?.text = nutrient.unit
        
        return cell
    }
}

