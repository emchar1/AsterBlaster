//
//  LaserCannon.swift
//  AsterBlaster
//
//  Created by Eddie Char on 11/2/20.
//

import ARKit

struct LaserCannon {
    var sceneView: ARSCNView!
    
    init(in sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    func fire() {
        guard let pov = sceneView.pointOfView else {
            return
        }
        
        //shared properties
        let power: Float = 50
        let transform = pov.transform
        let orientation = SCNVector3(x: -transform.m31, y: -transform.m32, z: -transform.m33)
        let location = SCNVector3(x: transform.m41, y: transform.m42, z: transform.m43)

        //left cannon
        let cannonL = SCNSphere(radius: 0.05)
        let positionL = SCNVector3(x: orientation.x + location.x - 0.6, y: orientation.y + location.y - 0.5, z: orientation.z + location.z)
        let nodeL = SCNNode(geometry: cannonL)
        let physicsBodyL = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: nodeL))
        cannonL.firstMaterial?.diffuse.contents = UIColor.cyan
        nodeL.name = "cannonL"
        nodeL.position = positionL
        nodeL.physicsBody = physicsBodyL
        nodeL.physicsBody!.categoryBitMask = BitMaskCategory.cannon.rawValue
        nodeL.physicsBody!.collisionBitMask = 0
        nodeL.physicsBody!.contactTestBitMask = BitMaskCategory.asteroid.rawValue
        nodeL.physicsBody!.isAffectedByGravity = false
        nodeL.physicsBody!.applyForce(SCNVector3(x: orientation.x * power + 1,
                                                 y: orientation.y * power,
                                                 z: orientation.z * power),
                                      asImpulse: true)
        sceneView.scene.rootNode.addChildNode(nodeL)
        
        //right cannon
        let cannonR = SCNSphere(radius: 0.05)
        let positionR = SCNVector3(x: orientation.x + location.x + 0.6, y: orientation.y + location.y - 0.5, z: orientation.z + location.z)
        let nodeR = SCNNode(geometry: cannonR)
        let physicsBodyR = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: nodeR))
        cannonR.firstMaterial?.diffuse.contents = UIColor.magenta
        nodeR.name = "cannonR"
        nodeR.position = positionR
        nodeR.physicsBody = physicsBodyR
        nodeR.physicsBody!.categoryBitMask = BitMaskCategory.cannon.rawValue
        nodeR.physicsBody!.collisionBitMask = 0
        nodeR.physicsBody!.contactTestBitMask = BitMaskCategory.asteroid.rawValue
        nodeR.physicsBody!.isAffectedByGravity = false
        nodeR.physicsBody!.applyForce(SCNVector3(x: orientation.x * power - 1,
                                                 y: orientation.y * power,
                                                 z: orientation.z * power),
                                      asImpulse: true)
        sceneView.scene.rootNode.addChildNode(nodeR)
        
        //Remove the bullets after a certain duration.
        let sequence = SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                           SCNAction.removeFromParentNode()])
        nodeL.runAction(sequence)
        nodeR.runAction(sequence)
    }
}
