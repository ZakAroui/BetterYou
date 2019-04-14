//
//  FoodDetailsVC.swift
//  BetterYou
//
//  Created by Zak Aroui on 4/12/19.
//

import UIKit
import TextToSpeech
import SpeechToText
import AVFoundation

class FoodDetailsVC: UIViewController {

    var food: UsdaFood!
    var sItems: [UsdaSearchResponse]!
    var audioPlayer: AVAudioPlayer!
    var speechToText: SpeechToText!
    var isStreaming = false
    var accumulator = SpeechRecognitionResultsAccumulator()
    @IBOutlet weak var textLabel: UILabel!
    let textToSpeech = TextToSpeech(apiKey: "saoXu9eZr6zGva_DyV4umFLOfMS441_aPVwnoRK8NNiX")
    
    @IBAction func Mic(_ sender: UIButton) {
        if !isStreaming {
            isStreaming = true
            sender.setTitle("Stop Microphone", for: .normal)
            var settings = RecognitionSettings(contentType: "audio/ogg;codecs=opus")
            settings.interimResults = true
            var recognizeCallback = RecognizeCallback()
            recognizeCallback.onResults = {
                response in
                
                self.accumulator.add(results: response)
                print(self.accumulator.bestTranscript)
                self.textLabel.text = self.accumulator.bestTranscript
            }
            
            recognizeCallback.onError = {
                error in
                
                print(error)

            }
            
            speechToText.recognizeMicrophone(settings: settings, callback: recognizeCallback)
            
        } else {
            isStreaming = false
            sender.setTitle("Start Microphone", for: .normal)
            speechToText.stopRecognizeMicrophone()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechToText = SpeechToText(
            apiKey: "8-mX4iVPs26X_wAWz4Ab6hf6JvkfT_LXf1NxTq3wWzDH"
        )
        
        
        
        let text = "All the problems of the world could be settled easily if dogs were only willing to think."
        
        tts(text: text, textToSpeech: textToSpeech)

        
        let usdaRc = UsdaRestClient()
        usdaRc.getReport(foodName: "01009", completion: {fd in
            self.food = fd!
        })
        
        usdaRc.getSearch(keyword: "kale", completion: {items in
            self.sItems = items!
        })
        
    }
    
    func tts(text: String, textToSpeech: TextToSpeech){
        textToSpeech.synthesize(text: text, accept: "audio/wav", completionHandler: { response,error  in
    
        if let error = error {
        print(error)
        }
    
        guard let data = response?.result else {
        print("Failed to synthesize text")
        return
        }
    
        do {
        self.audioPlayer = try AVAudioPlayer(data: data)
        self.audioPlayer!.play()
        } catch {
        print("Failed to create audio player.")
        }
    
        })
    }

   
}
