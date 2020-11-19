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

        
        queueAnimation(withKey: "summon1",
                       sceneName: "art.scnassets/Nightshade/summon1Fixed",
                       animationIdentifier: "summon1Fixed-1",
                       repeatCount: 1,
                       speed: 1,
                       fadeInDuration: 1,
                       fadeOutDuration: 0.25)
        queueAnimation(withKey: "summon2",
                       sceneName: "art.scnassets/Nightshade/summon2Fixed",
                       animationIdentifier: "summon2Fixed-1",
                       repeatCount: 1,
                       speed: 0.5,
                       fadeInDuration: 0.25,
                       fadeOutDuration: 0.25)
        queueAnimation(withKey: "summon3",
                       sceneName: "art.scnassets/Nightshade/summon3Fixed",
                       animationIdentifier: "summon3Fixed-1",
                       repeatCount: 1,
                       speed: 0.5,
                       fadeInDuration: 0.25,
                       fadeOutDuration: 1)
        
        loadAnimations(withFile: "art.scnassets/Nightshade/summon0Fixed.dae")


        print("animations: \(animations)")
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
    
    
    
    
    
    
    func loadAnimations(withFile file: String) {
        guard let idleScene = SCNScene(named: file) else {
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
    }
    
    //First, we load the file as an SCNSceneSource, which is used to extract elements of a scene without keeping the entire scene and all the assets it contains. In this case, we use it to extract the animation as a CAAnimation object, on which we set the property repeatCount to only play the animation one time and fadeInDuration and fadeOutDuration to create a smooth transition between this and the idle animation. Finally, the animation is stored for later use.
    func queueAnimation(withKey key: String,
                        sceneName: String,
                        animationIdentifier: String,
                        repeatCount: Float = 1,
                        speed: Float = 1,
                        fadeInDuration: CGFloat = 1,
                        fadeOutDuration: CGFloat = 1) {
        
        guard let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae") else {
            fatalError("sceneName: " + sceneName + " not found.")
        }
        
        guard let sceneSource = SCNSceneSource(url: sceneURL, options: nil) else {
            fatalError("sceneSource failed.")
        }
        
        guard let animationObject = sceneSource.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) else {
            fatalError("animationObject failed.")
        }
            
        animationObject.repeatCount = repeatCount
        animationObject.speed = speed
        animationObject.fadeInDuration = fadeInDuration
        animationObject.fadeOutDuration = fadeOutDuration

        animations[key] = animationObject
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
            playAnimation(key: "summon1", completion: nil)
            playAnimation(key: "summon2", completion: nil)
            playAnimation(key: "summon3", completion: {
                print("Done")
            })
        }
        else {
            stopAnimation(key: "summon1")
            stopAnimation(key: "summon2")
            stopAnimation(key: "summon3")
        }
        
        idle = !idle
    }
    
    func playAnimation(key: String, completion: (() -> ())?) {
        //add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
                
        completion?()
    }
    
    func stopAnimation(key: String) {
        //stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(1))
    }
}


// MARK: - ARSCNDelegate

extension MerlyneController: ARSCNViewDelegate {
    
}
