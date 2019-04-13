//
//  ViewController.swift
//  BetterYou
//
//  Created by Christian Lopez on 4/12/19.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var displayText: Bool = false
    private var calorieScene: SCNScene = SCNScene(named: "art.scnassets/Scenes/NutritionValue.scn")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        displayDebugInfo()
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene(named: "art.scnassets/Scenes/NutritionFactsScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let hitTestResults = sceneView.hitTest((touches.first?.location(in: sceneView))!, types: [ ARHitTestResult.ResultType.featurePoint ])
        
        
        
        if !hitTestResults.isEmpty{
            guard let hitResult = hitTestResults.first else { return }
            
            if let currentFrame = sceneView.session.currentFrame{
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.x = hitResult.worldTransform.columns.3.x
                translation.columns.3.y = hitResult.worldTransform.columns.3.y
                translation.columns.3.z = hitResult.worldTransform.columns.3.z
                let transform = simd_mul(currentFrame.camera.transform, translation)
                
                let anchor: ARAnchor = ARAnchor(transform: transform)
                displayText = true
                sceneView.session.add(anchor: anchor)
            }
        }
    }

    private func displayDebugInfo(){
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showFeaturePoints]
    }
    
    private func createText(text: String) -> SCNNode {
        /*
        var nodeWidth: CGFloat = 0.03
        var nodeHeight: CGFloat = 0.03
        var nodeDepth: CGFloat = 0.03
        
        
        var textToCreate: SCNText = SCNText(string: text, extrusionDepth: 0)
        
        // textToCreate.flatness = 0.05
        
        textToCreate.firstMaterial?.diffuse.contents = UIColor.blue
        
        var textNode: SCNNode = SCNNode(geometry: textToCreate)
        
        
        textNode.scale = SCNVector3(nodeWidth, nodeHeight, nodeDepth)
         */
        var textNode = self.calorieScene.rootNode.childNode(withName: "Calories", recursively: true )!
        
        return textNode
    }
    
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // let node = SCNNode()
        let textNode = createText(text: "1000 calories")
        
        print("In nodeFor function")
        
        return textNode
    }
 */
 
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if displayText{
            let textNode = createText(text: "1000 Calories")
            
            // Setting the position:
            textNode.position = SCNVector3(anchor.transform.columns.3.x,anchor.transform.columns.3.y,anchor.transform.columns.3.z)
            
            node.addChildNode(textNode)
            print("In the didAdd function")
            displayText = false
        }
    }
    

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
