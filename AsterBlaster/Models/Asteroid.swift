//
//  Asteroid.swift
//  AsterBlaster
//
//  Created by Eddie Char on 10/29/20.
//

import ARKit

struct Asteroid {
    var sceneView: ARSCNView!
        
    init(in sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
        
    func spawn(initialPosition: Float = 100, spawnRange: Int = 5) {
        guard let asteroidScene = SCNScene(named: "art.scnassets/Jellyfish.scn"),
              let node = asteroidScene.rootNode.childNode(withName: "jellyfish", recursively: false) else {
            return
        }

        node.name = "asteroid"
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node))
        node.physicsBody!.isAffectedByGravity = false
        node.physicsBody!.categoryBitMask = BitMaskCategory.asteroid.rawValue
        node.physicsBody!.contactTestBitMask = BitMaskCategory.cannon.rawValue
        node.position = SCNVector3(x: Float(Int.random(in: -spawnRange...spawnRange)),
                                   y: Float(Int.random(in: -spawnRange...spawnRange)),
                                   z: -initialPosition)
        node.opacity = 0.0
        
        sceneView.scene.rootNode.addChildNode(node)
        
        animate(node: node, initialPosition: initialPosition, speed: 24)
    }
    
    private func animate(node: SCNNode, initialPosition: Float, speed: Float) {
        let duration = 1.0
        let count = Int(initialPosition / speed)
        
        let fadeInAction = SCNAction.fadeIn(duration: duration * 2)
        let moveAction = SCNAction.move(by: SCNVector3(x: 0, y: 0, z: speed), duration: duration)
        let groupAction = SCNAction.group([fadeInAction, moveAction])
        node.runAction(SCNAction.repeat(groupAction, count: count)) {
            //completion: - This is what happens when the asteroid reaches the ship and causes damage
            impactOccurred(for: node)
        }
    }
    
    private func impactOccurred(for node: SCNNode) {
        let haptics = Haptics()
        haptics.asteroidStrike()

        node.removeFromParentNode()
        print("Ship damaged!")        
    }
    
    static func despawn(with hitTestResults: [SCNHitTestResult]) {
        guard let result = hitTestResults.first else {
            print("Miss")
            return
        }
        
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let node = result.node
        node.removeAllActions()
        node.categoryBitMask = BitMaskCategory.asteroidDown.rawValue // i.e. prevent tapping once it's dead
        node.runAction(SCNAction.fadeOut(duration: 0.25)) {
            node.removeFromParentNode()
        }

        print("Hit asteroid!")
    }
}
