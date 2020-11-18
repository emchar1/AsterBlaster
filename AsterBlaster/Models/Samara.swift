//
//  Samara.swift
//  AsterBlaster
//
//  Created by Eddie Char on 11/6/20.
//

import ARKit
import GLKit

enum HauntStatus: String {
    case safe = "safe"
    case caution = "caution"
    case haunt = "haunt"
}

struct Samara {
    let scarychick: SCNCylinder!
    let bodyNode: SCNNode!
    let scaryFace: SCNBox!
    var faceColor: SCNMaterial!
    let sceneView: ARSCNView!
    
    var samaraPosition: simd_float3 {
        return simd_float3(x: bodyNode.position.x, y: bodyNode.position.y, z: bodyNode.position.z)
    }
    
    var samaraDirection: simd_float3 {
        let samaraNormal = simd_normalize(simd_float3(x: samaraPosition.x, y: 0, z: samaraPosition.z))
        
        return simd_float3(x: samaraNormal.x, y: 0, z: samaraNormal.z)
    }
    
    var playerPosition: simd_float3 {
        guard let currentFrame = sceneView.session.currentFrame else {
            return simd_float3(x: 0, y: 0, z: 0)
        }

        let position = currentFrame.camera.transform.columns.3
        return simd_float3(x: position.x, y: position.y, z: position.z)
    }
        
    var distance: Float {
        return simd_distance(samaraPosition, playerPosition)
    }
        
    var angle: Float {
        let samaraToPlayer = playerPosition - samaraPosition
        let lineOfSight = simd_dot(simd_normalize(samaraDirection), simd_normalize(samaraToPlayer))
        let angle = GLKMathRadiansToDegrees(acos(lineOfSight))

        return angle
    }
    
    var samaraSight: HauntStatus {
        let status: HauntStatus
        let fieldOfVision: Float = 140
        let maxDistance: Float = 5

        if angle < fieldOfVision / 2 {
            if distance <= maxDistance { status = .haunt }
            else { status = .caution }
        }
        else { status = .safe }

        return status
    }
    
    
    let wallLength: Float = 3.0
    var isAttacking = false
    
    

    init(in sceneView: ARSCNView) {
        let radius: CGFloat = 0.119
        let height: CGFloat = 1.7
        let initialX: Float = Float.random(in: -wallLength...wallLength)
        let initialZ: Float = Float.random(in: -(wallLength * 2)...(-1.0))
                
        self.sceneView = sceneView
        
        scarychick = SCNCylinder(radius: radius, height: height)
        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = UIColor.black
//        let directionMaterial = SCNMaterial()
//        directionMaterial.diffuse.contents = SCNVector3(simd_float3(x: -1, y: 0, z: 0))
        scarychick.materials = [colorMaterial]//, directionMaterial]
        bodyNode = SCNNode(geometry: scarychick)
        bodyNode.position = SCNVector3(x: initialX, y: -Float(height / 2), z: initialZ)

        //Optional - to remove when use actual samara scene.
        let scaryHead = SCNBox(width: radius * 3, height: radius * 3,  length: radius * 3, chamferRadius: radius)
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = UIColor.black
        scaryHead.materials = [headMaterial]
        let headNode = SCNNode(geometry: scaryHead)
        headNode.position = SCNVector3(x: 0, y: Float(height / 2), z: 0)

        scaryFace = SCNBox(width: 0.01, height: radius * 3, length: radius * 3, chamferRadius: 0)
        faceColor = SCNMaterial()
        faceColor.diffuse.contents = UIColor.green
        scaryFace.materials = [faceColor]
//        samaraDirection = simd_float3(x: initialX / abs(initialX), y: 0, z: 0)
        let faceNode = SCNNode(geometry: scaryFace)
        faceNode.position = SCNVector3(x: samaraDirection.x * Float(radius * 3), y: 0, z: samaraDirection.z * Float(radius * 3))
        
        
        headNode.addChildNode(faceNode)
        bodyNode.addChildNode(headNode)

//        bodyNode.eulerAngles.y = GLKMathRadiansToDegrees(atan2(initialZ, initialX))
//        print("euler.y = \(bodyNode.eulerAngles.y)")


        sceneView.scene.rootNode.addChildNode(bodyNode)
    }
    
    mutating func movement() {
        
        let nextX: Float = Float.random(in: -wallLength...wallLength)
        let nextZ: Float = Float.random(in: -(wallLength * 2)...(-1.0))
        
        var nextPosition: simd_float3 {
            return simd_float3(x: nextX, y: samaraPosition.y, z: nextZ)
        }

        let nextDirection: simd_float3 = simd_normalize(simd_float3(x: nextX, y: 0, z: nextZ))

        var angle: CGFloat {
            let samaraNextToPrev = samaraPosition - nextPosition
            let lineOfSight = simd_dot(simd_normalize(samaraDirection), simd_normalize(samaraNextToPrev))
            
            return CGFloat(acos(lineOfSight))
        }
        
        
        
        print("initial Position: \(samaraPosition)")
        print("initial Normal: \(simd_normalize(simd_float3(x: samaraPosition.x, y: 0, z: samaraPosition.z)))")
        print("next Position: \(nextPosition)")
        print("next Normal: \(simd_normalize(simd_float3(x: nextPosition.x, y: 0, z: nextPosition.z)))")
        print("BA: \(samaraPosition - nextPosition)")
        print("BA normal: \(simd_normalize(samaraPosition - nextPosition))")
        print("direction: \(samaraDirection)")
        print("nextDirection: \(nextDirection)")
        print("Line of sight = simd_dot(normalize(samaraDirection), normalize(BA)): \(simd_dot(simd_normalize(samaraDirection), simd_normalize(samaraPosition - nextPosition)))")
        
        print("angle from init to next: \(GLKMathRadiansToDegrees(Float(angle)))")
        
//        let rotate = SCNAction.rotate(by: angle, around: SCNVector3(x: 0, y: samaraPosition.y, z: 0), duration: TimeInterval.random(in: 2...3))
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi - CGFloat(samaraDirection.x) * angle, z: 0, duration: TimeInterval.random(in: 2...3))
        let roam = SCNAction.move(to: SCNVector3(nextPosition), duration: TimeInterval.random(in: 10...25))
        let group = SCNAction.sequence([rotate, roam])
        let pontificate = SCNAction.wait(duration: TimeInterval.random(in: 5...8))
        
//        samaraDirection = nextDirection
        
        
        

    
      /*
         //OLD WAY
        let roamL = SCNAction.move(to: SCNVector3(x: -3.0, y: bodyNode.position.y, z: bodyNode.position.z), duration: TimeInterval.random(in: 10...30))
        let roamR = SCNAction.move(to: SCNVector3(x: 3.0, y: bodyNode.position.y, z: bodyNode.position.z), duration: TimeInterval.random(in: 10...30))
        let turn = SCNAction.rotateTo(x: 0, y: CGFloat(GLKMathDegreesToRadians(180)), z: 0, duration: TimeInterval.random(in: 2...3))
        let turnBack = SCNAction.rotateTo(x: 0, y: CGFloat(GLKMathDegreesToRadians(0)), z: 0, duration: TimeInterval.random(in: 2...3))
        let pontificate = SCNAction.wait(duration: TimeInterval.random(in: 5...8))
        let sequence = SCNAction.sequence([pontificate, pontificate, pontificate, turn, roamL, pontificate, turnBack, roamR])
        bodyNode.runAction(pontificate, forKey: "wait", completionHandler: nil)
        bodyNode.runAction(SCNAction.repeatForever(sequence), forKey: "move", completionHandler: nil)
*/
        
        
        
        let sequence = SCNAction.sequence(([pontificate, group]))
        
        bodyNode.runAction(SCNAction.repeatForever(sequence))
    }
    
    func getAngle(with direction: simd_float3) {
        
    }
    
    mutating func haunt() {
        guard !isAttacking else {
            return
        }
        
        //Updates as bodyNode turns, assuming haunt() gets called from updateAtTime() method in ViewController.
//        samaraDirection = simd_float3(x: cos(bodyNode.eulerAngles.y), y: 0, z: -sin(bodyNode.eulerAngles.y))
    
        switch samaraSight {
        case .safe:
            faceColor.diffuse.contents = UIColor.green
        case .caution:
            faceColor.diffuse.contents = UIColor.yellow
        case .haunt:
            faceColor.diffuse.contents = UIColor.red
            
            attack()
            
            isAttacking = true
        }
        
        scaryFace.materials = [faceColor]
    }
    
    func attack() {
        guard let cameraNode = sceneView.pointOfView else {
            return
        }
        
        bodyNode.removeAllActions()
                
//        let turn = SCNAction.rotateTo(x: 0, y: <#T##CGFloat#>, z: 0, duration: 0.25)
        let scare = SCNAction.move(to: SCNVector3(x: cameraNode.position.x,
                                                  y: bodyNode.position.y,
                                                  z: cameraNode.position.z - 1), duration: 0.25)
        
        bodyNode.runAction(scare)
    }
}
