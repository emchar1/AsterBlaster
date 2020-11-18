//
//  PortalController.swift
//  AsterBlaster
//
//  Created by Eddie Char on 11/6/20.
//

import ARKit

class PortalController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var samaraPositionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var samara: Samara!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = .showWorldOrigin
        sceneView.showsStatistics = true

        samara = Samara(in: sceneView)
        samara.movement()
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


    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //samara.haunt()
        
        DispatchQueue.main.async { [self] in
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 1
            let x = formatter.string(from: NSNumber(value: samara.samaraDirection.x))
            let y = formatter.string(from: NSNumber(value: samara.samaraDirection.y))
            let z = formatter.string(from: NSNumber(value: samara.samaraDirection.z))

            
            playerPositionLabel.text = "\(formatter.string(from: NSNumber(value: samara.playerPosition.x)) ?? "0"), \(formatter.string(from: NSNumber(value: samara.playerPosition.y)) ?? "0"), \(formatter.string(from: NSNumber(value: samara.playerPosition.z)) ?? "0")"
            samaraPositionLabel.text = "\(formatter.string(from: NSNumber(value: samara.samaraPosition.x)) ?? "0"), \(formatter.string(from: NSNumber(value: samara.samaraPosition.y)) ?? "0"), \(formatter.string(from: NSNumber(value: samara.samaraPosition.z)) ?? "0")"
            distanceLabel.text = "\(samara.distance)"
            directionLabel.text = "\(x ?? "0"), \(y ?? "0"), \(z ?? "0")"
            angleLabel.text = "\(samara.angle)"
            statusLabel.text = samara.samaraSight.rawValue
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
