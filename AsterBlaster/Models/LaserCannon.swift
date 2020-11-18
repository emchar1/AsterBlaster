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
//        guard let currentFrame = sceneView.session.currentFrame else {
//            return
//        }
        
        guard let pov = sceneView.pointOfView else {
            return
        }
        
        let power: Float = 50
        let transform = pov.transform
        let orientation = SCNVector3(x: -transform.m31, y: -transform.m32, z: -transform.m33)
        let location = SCNVector3(x: transform.m41, y: transform.m42, z: transform.m43)
        let positionL = SCNVector3(x: orientation.x + location.x - 0.6, y: orientation.y + location.y - 0.5, z: orientation.z + location.z)
        let positionR = SCNVector3(x: orientation.x + location.x + 0.6, y: orientation.y + location.y - 0.5, z: orientation.z + location.z)

        let cannonL = SCNSphere(radius: 0.05)//, height: 0.1)
        let cannonR = SCNSphere(radius: 0.05)//, height: 0.1)
        cannonL.firstMaterial?.diffuse.contents = UIColor.cyan
        cannonR.firstMaterial?.diffuse.contents = UIColor.magenta
        
        let nodeL = SCNNode(geometry: cannonL)
        nodeL.name = "cannonL"
        nodeL.position = positionL//SCNVector3(x: -1, y: 0, z: -1)
//        nodeL.eulerAngles = SCNVector3(x: 0, y: 0, z: Float.pi / 2)
//        nodeL.categoryBitMask = CategoryBitMasks.cannon.rawValue
        let nodeR = SCNNode(geometry: cannonR)
        nodeR.name = "cannonR"
        nodeR.position = positionR//SCNVector3(x: 1, y: 0, z: -1)
//        nodeR.eulerAngles = SCNVector3(x: .pi / 2, y: 0, z: 0)
//        nodeR.categoryBitMask = CategoryBitMasks.cannon.rawValue
        
//        let camera = currentFrame.camera.transform
//
//        var translationL = matrix_identity_float4x4
//        translationL.columns.3.z = 1
//        translationL.columns.3.y = -0.07
//        translationL.columns.3.x = 0.1
//
//        nodeL.simdTransform = matrix_multiply(camera, translationL)
        nodeL.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: nodeL))
        nodeL.physicsBody?.categoryBitMask = BitMaskCategory.cannon.rawValue
        nodeL.physicsBody?.contactTestBitMask = BitMaskCategory.asteroid.rawValue
        nodeL.physicsBody?.isAffectedByGravity = false
//        let forceVector = SCNVector3(nodeL.worldFront.x * 50, nodeL.worldFront.y * 50, nodeL.worldFront.z * 50)
        nodeL.physicsBody?.applyForce(SCNVector3(x: orientation.x * power + 2,
                                                 y: orientation.y * power,
                                                 z: orientation.z * power),
                                      asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(nodeL)
        
//        
//        translationL.columns.3.z = 1
//        translationL.columns.3.y = 0.07
//        translationL.columns.3.x = 0.1
//        
//        nodeR.simdTransform = matrix_multiply(camera, translationL)
        nodeR.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: nodeR))
        nodeR.physicsBody?.categoryBitMask = BitMaskCategory.cannon.rawValue
        nodeR.physicsBody?.contactTestBitMask = BitMaskCategory.asteroid.rawValue
        nodeR.physicsBody?.isAffectedByGravity = false
//        let forceVectorR = SCNVector3(nodeR.worldFront.x * 50, nodeR.worldFront.y * 50, nodeR.worldFront.z * 50)
        nodeR.physicsBody?.applyForce(SCNVector3(x: orientation.x * power - 2,
                                                 y: orientation.y * power,
                                                 z: orientation.z * power),
                                      asImpulse: true)

        sceneView.scene.rootNode.addChildNode(nodeR)
        
        
        //Remove the bullet after 2 seconds.
        let sequence = SCNAction.sequence([SCNAction.wait(duration: 3.0),
                                           SCNAction.removeFromParentNode()])
        nodeL.runAction(sequence)
        nodeR.runAction(sequence)

//        nodeL.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: -100), duration: 1.0)))
//        nodeR.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: -100), duration: 1.0)))
    }
    
    
    
}
