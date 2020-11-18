//
//  AsterBlasterController.swift
//  AsterBlaster
//
//  Created by Eddie Char on 10/28/20.
//

import ARKit

class AsterBlasterController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!

    var asteroids: Asteroid!
    var crosshairsView: CrosshairsView!
    var cannon: LaserCannon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = true
        sceneView.scene.background.contents = UIImage(named: "art.scnassets/background.jpg")
        sceneView.scene.physicsWorld.contactDelegate = self
        
        crosshairsView = CrosshairsView(frame: CGRect(x: view.frame.width / 2 - 10,
                                                      y: view.frame.height / 2 - 10,
                                                      width: 20,
                                                      height: 20), with: .red)
        view.addSubview(crosshairsView)
        
        asteroids = Asteroid(in: sceneView)
        Timer.scheduledTimer(withTimeInterval: 0.65, repeats: true) { _ in
            self.asteroids.spawn(initialPosition: 100, spawnRange: 5)
        }
        
        cannon = LaserCannon(in: sceneView)
                
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fireTheLaser))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func fireTheLaser(_ recognizer: UITapGestureRecognizer) {
//        let hitResult = sceneView.hitTest(crosshairsView.center, options: [.categoryBitMask: CategoryBitMasks.asteroid.rawValue])
        
        cannon.fire()
        
//        Asteroid.despawn(with: hitResult)
    }
    
    
    // MARK: - UINavigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = UIViewController() as! PortalController
        controller.sceneView = ARSCNView()
    }
 
}


extension AsterBlasterController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        
//        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.asteroid.rawValue {
            nodeA.removeAllActions()
            nodeA.removeFromParentNode()
            
//        }
//        else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.asteroid.rawValue {
            nodeB.removeAllActions()
            nodeB.removeFromParentNode()
//        }
        
//        collision(with: nodeA, onto: nodeB)
    }
    
    private func collision(with nodeCannon: SCNNode, onto nodeAsteroid: SCNNode) {
        nodeCannon.removeAllActions()
        nodeCannon.runAction(SCNAction.fadeOut(duration: 0.25)) {
            nodeCannon.removeFromParentNode()
        }

        nodeAsteroid.removeAllActions()
        nodeAsteroid.runAction(SCNAction.fadeOut(duration: 0.25)) {
            nodeAsteroid.removeFromParentNode()
        }
    }
}
