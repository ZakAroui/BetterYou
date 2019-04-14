//
//  GoalsViewController.swift
//  BetterYou
//
//  Created by Christian Lopez on 4/14/19.
//

import Foundation
import UIKit
import TextToSpeech
import SpeechToText
import AVFoundation

class GoalsViewController: UIViewController {
    
    var food: UsdaFood!
    var sItems: [UsdaSearchResponse]!
    var audioPlayer: AVAudioPlayer!
    var speechToText: SpeechToText!
    var isStreaming = false
    var accumulator = SpeechRecognitionResultsAccumulator()
    var usdaRc = UsdaRestClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechToText = SpeechToText(
            apiKey: "8-mX4iVPs26X_wAWz4Ab6hf6JvkfT_LXf1NxTq3wWzDH"
        )
        
    }
    
    @IBAction func Mic(_ sender: UIButton) {
        if !isStreaming {
            isStreaming = true
            sender.backgroundColor = GoalsViewController.hexStringToUIColor(hex: "CC645C", alpha: 0.4)
            var settings = RecognitionSettings(contentType: "audio/ogg;codecs=opus")
            settings.interimResults = true
            var recognizeCallback = RecognizeCallback()
            recognizeCallback.onResults = {
                response in
                
                self.accumulator.add(results: response)
                print(self.accumulator.bestTranscript)
                let transcript = self.accumulator.bestTranscript
                let transcriptArr = transcript.components(separatedBy: " ")
                let food = transcriptArr[0]
                
                self.usdaRc.getSearch(keyword: food, completion: {items in
                    self.sItems = items!
                    
                    self.usdaRc.getReport(foodName: "09320", completion: {fd in
                        self.food = fd!
                        
                        
                    })
                })
            }
            
            recognizeCallback.onError = {
                error in
                print(error)
            }
            
            speechToText.recognizeMicrophone(settings: settings, callback: recognizeCallback)
        } else {
            isStreaming = false
            sender.backgroundColor = nil
            speechToText.stopRecognizeMicrophone()
            self.showTableDetails()
        }
        
    }
    
    func showTableDetails() {
//        let foodDetailsTableVC = FoodDetailsTableVC()
//        self.navigationController?.pushViewController(foodDetailsTableVC, animated: true)
        
        let storyBoard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let foodDetailsTableVC = storyBoard.instantiateViewController(withIdentifier: "foodDetailsTVC") as! FoodDetailsTableVC
        self.present(foodDetailsTableVC, animated: true, completion: nil)
        
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "foodDetailsTVC") as! UITableViewController
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    static func hexStringToUIColor (hex:String, alpha: Float) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.white
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    
}
