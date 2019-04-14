//
//  ImageClassificationVC.swift
//  BetterYou
//
//  Created by Zack Aroui on 4/13/19.
//

import Foundation
import UIKit
import CoreML
import Vision
import ImageIO
import VisualRecognition
import TextToSpeech
import AVKit

class ImageClassificationVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var classificationLabel: UILabel!
    var audioPlayer: AVAudioPlayer!
    var visualRecognition: VisualRecognition!
    let textToSpeech = TextToSpeech(apiKey: "saoXu9eZr6zGva_DyV4umFLOfMS441_aPVwnoRK8NNiX")
    var food: UsdaFood!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visualRecognition = VisualRecognition(version: "2018-03-19", apiKey: "YToC1zjehuqmvpGrpv_ez23WtL4JMtSGYWEQB82BgTRU")

    }
    
    func classifyImg(image: UIImage){
        self.classificationLabel.text = "Classifying..."
        
        visualRecognition.classify(image: image, threshold: 0.6, classifierIDs: ["food"]) {
            response, error in
            
            guard let result = response?.result else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }
            
            let classes = result.images[0].classifiers[0].classes
            
            if !classes.isEmpty {
                self.tts(text: classes[0].className, textToSpeech: self.textToSpeech)
                let usdaRc = UsdaRestClient()
                usdaRc.getReport(foodName: "09320", completion: {fd in
                    self.food = fd!
                })
            }
            
            var clsses = ""
            for classRslt in classes {
                clsses += classRslt.className + ", "
            }
            
            self.updateLabels(classes: clsses)
            
            print(clsses)
        }
    }
    
    func updateLabels(classes: String){
        DispatchQueue.main.async {
            self.classificationLabel.text = "Classification: " + classes
        }
        
    }
    
    // MARK: - Image Classification
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Initialize Vision Core ML model from base Watson Visual Recognition model
            
            //  Uncomment this line to use the tools model.
            let model = try VNCoreMLModel(for: watson_tools().model)
            
            //  Uncomment this line to use the plants model.
            // let model = try VNCoreMLModel(for: watson_plants().model)
            
            // Create visual recognition request using Core ML model
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            }
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        tts(text: classificationLabel.text! , textToSpeech: textToSpeech)
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
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
    
    /// Updates the UI with the results of the classification.
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                self.tts(text: self.classificationLabel.text! , textToSpeech: self.textToSpeech)
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Sorry, but I could not recognize the image."
                self.tts(text: self.classificationLabel.text! , textToSpeech: self.textToSpeech)
            } else {
                // Display top classification ranked by confidence in the UI.
                self.classificationLabel.text = "Classification: " + classifications[0].identifier
                self.tts(text: self.classificationLabel.text! , textToSpeech: self.textToSpeech)
            }
        }
    }
    
    // MARK: - Photo Actions
    @IBAction func takePicture() {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
}

extension ImageClassificationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        var image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        image = imageWithImage(image: image, scaledToSize: CGSize(width: 250, height: 250))
        
        imageView.image = image
        
//        updateClassifications(for: image)
        classifyImg(image: image)
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}



// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
