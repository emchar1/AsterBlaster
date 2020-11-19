//
//  MerlyneController.swift
//  AsterBlaster
//
//  Created by Eddie Char on 11/18/20.
//

import ARKit

class MerlyneController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    var animations = [String : CAAnimation]()
    var idle = true
    
    override func viewDidLoad() {
        let scene = SCNScene()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene

        
        
//        loadAnimations(sceneName: "art.scnassets/Nightshade/summon0Fixed.dae")
//        loadAnimations(sceneName: "art.scnassets/Nightshade/summon1Fixed.dae")
//        loadAnimations(sceneName: "art.scnassets/Nightshade/summon2Fixed.dae")
//        loadAnimations(sceneName: "art.scnassets/Nightshade/summon3Fixed.dae")

        
        loadAnimations()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    
    // MARK: - This is where the "Magic" a.k.a. animation fun happens....
    
//    func loadAnimations(sceneName: String) {
//        let idleScene = SCNScene(named: sceneName)!
//        let node = SCNNode()
//
//        for child in idleScene.rootNode.childNodes {
//            node.addChildNode(child)
//        }
//
//        node.position = SCNVector3(0, -1, -10)
//        node.scale = SCNVector3(0.02, 0.02, 0.02)
//
//        sceneView.scene.rootNode.addChildNode(node)
//        animateEntireNodeTreeOnce(mostRootNode: node)
//    }
//
//    func animateEntireNodeTreeOnce(mostRootNode node: SCNNode) {
//        if node.animationKeys.count > 0 {
//            for key in node.animationKeys {
//                let animation = node.animation(forKey: key)!
//                animation.repeatCount = 1
//                animation.duration = 5;
//                animation.isRemovedOnCompletion = false
//                node.removeAllAnimations()
//                node.addAnimation(animation, forKey: key)
//            }
//        }
//
//        for childNode in node.childNodes {
//            animateEntireNodeTreeOnce(mostRootNode: childNode)
//        }
//    }
    
    
    
    
    
    
    func loadAnimations() {
        guard let idleScene = SCNScene(named: "art.scnassets/Nightshade/summon0Fixed.dae") else {
            fatalError("idle scene file not found in loadAnimations()")
        }
        
        let node = SCNNode()
        
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        node.position = SCNVector3(x: 0, y: -1, z: -10)
        node.scale = SCNVector3(x: 0.02, y: 0.02, z: 0.02)
        node.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
        
        sceneView.scene.rootNode.addChildNode(node)
        
        loadAnimation(withKey: "summon1", sceneName: "art.scnassets/Nightshade/summon1Fixed", animationIdentifier: "summon1Fixed-1")
        loadAnimation(withKey: "summon2", sceneName: "art.scnassets/Nightshade/summon2Fixed", animationIdentifier: "summon2Fixed-1")
        loadAnimation(withKey: "summon3", sceneName: "art.scnassets/Nightshade/summon3Fixed", animationIdentifier: "summon3Fixed-1")
    }
    
    func loadAnimation(withKey key: String, sceneName: String, animationIdentifier: String) {
        //First, we load the file as an SCNSceneSource, which is used to extract elements of a scene without keeping the entire scene and all the assets it contains. In this case, we use it to extract the animation as a CAAnimation object, on which we set the property repeatCount to only play the animation one time and fadeInDuration and fadeOutDuration to create a smooth transition between this and the idle animation. Finally, the animation is stored for later use.
        guard let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae"),
              let sceneSource = SCNSceneSource(url: sceneURL, options: nil) else {
            fatalError(sceneName + " not found in loadAnimation(withKey:sceneName:animationIdentifier:)")
        }
        
        if let animationObject = sceneSource.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            
            //repeat count of animation
            animationObject.repeatCount = 1
            
            //Creates smooth transition between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(1)
            
            //store animation for later use
            animations[key] = animationObject
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touches.count == 1 else {
            return
        }
        
        let location = touch.location(in: sceneView)
        let hitTestOptions = [SCNHitTestOption.boundingBoxOnly: true]
        let hitResults = sceneView.hitTest(location, options: hitTestOptions)
        
        guard hitResults.count > 0 else {
            return
        }
        
        if idle {
            playAnimation(key: "summon1")
            playAnimation(key: "summon2")
            playAnimation(key: "summon3")
        }
        else {
            stopAnimation(key: "summon1")
            stopAnimation(key: "summon2")
            stopAnimation(key: "summon3")
        }
        
        idle = !idle
    }
    
    func playAnimation(key: String) {
        //add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        //stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
}


// MARK: - ARSCNDelegate

extension MerlyneController: ARSCNViewDelegate {
    
}
