//
//  ViewController.swift
//  AR - Pair
//
//  Created by Kedar Pandya on 04/04/21.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anchor  = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        arView.scene.addAnchor(anchor)
        
        var cards : [Entity] = []
        
        for _ in 1...16 {
            
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            model.generateCollisionShapes(recursive: true)
            
            cards.append(model)
        }
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            
            card.position = [x*0.1,0,z*0.1]
            anchor.addChild(card)
        }
        
        let boxSize : Float = 0.7
        let occlusionBoxMesh = MeshResource.generateBox(size: boxSize)
        let occlusionBox = ModelEntity(mesh: occlusionBoxMesh, materials: [OcclusionMaterial()])
        
        occlusionBox.position.y = -boxSize/2
        
        anchor.addChild(occlusionBox)
        
        
        var canellable : AnyCancellable? = nil
        
        canellable = ModelEntity.loadModelAsync(named: "01")
            .append(ModelEntity.loadModelAsync(named: "02"))
            .append(ModelEntity.loadModelAsync(named: "03"))
            .append(ModelEntity.loadModelAsync(named: "04"))
            .append(ModelEntity.loadModelAsync(named: "05"))
            .append(ModelEntity.loadModelAsync(named: "06"))
            .append(ModelEntity.loadModelAsync(named: "07"))
            .append(ModelEntity.loadModelAsync(named: "08"))
            .collect()
            .sink(receiveCompletion: { error in
                print("Error \(error)")
                canellable?.cancel()
            }, receiveValue: { entities in
                var ojbects: [ModelEntity] = []
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.002,0.002,0.002), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    for _ in 1...2{
                        ojbects.append(entity.clone(recursive: true))
                    }
                }
                ojbects.shuffle()
                
                for (index , object) in ojbects.enumerated(){
                    cards[index].addChild(object)
                    cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
                }
                canellable?.cancel()
            })
    }
    
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        
        if let card = arView.entity(at: tapLocation){
            if card.transform.rotation.angle == .pi {
                var filpDownTransform = card.transform
                filpDownTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
                card.move(to: filpDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
            }else{
                var flipUpTransform = card.transform
                flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
                card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
            }
            
        }
    }
}
