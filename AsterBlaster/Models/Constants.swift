//
//  Constants.swift
//  AsterBlaster
//
//  Created by Eddie Char on 11/4/20.
//

import Foundation
import CoreHaptics

enum BitMaskCategory: Int {
    case asteroid = 1
    case explosion = 2
    case cannon = 4
    case ship = 8
    case health = 16
    case powerup = 32
}

struct Haptics {
    var engine: CHHapticEngine?
    
    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        }
        catch {
            print("Failed to start engine: \(error.localizedDescription)")
        }
        
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }
        
        engine?.resetHandler = { [self] in
            print("The engine reset")
            
            do {
                try engine?.start()
            }
            catch {
                print("Failed to restart engine: \(error)")
            }
        }
    }
    
    func asteroidStrike() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: i, duration: 0.1)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        }
        catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}
