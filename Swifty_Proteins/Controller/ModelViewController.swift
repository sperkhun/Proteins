//
//  ModelViewController.swift
//  Swifty_Proteins
//
//  Created by Serhii PERKHUN on 10/27/18.
//  Copyright © 2018 Serhii PERKHUN. All rights reserved.
//

import UIKit
import SceneKit

class ModelViewController: UIViewController {
    
    var modelNode = SCNNode()
    var sticksBallsNode = SCNNode()
    var bigBallsNode = SCNNode()
    
    // Screen
    
    @IBAction func screenButton(_ sender: Any) {
        let newImage: UIImage = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let data: [String] = ["Save error", String(error.localizedDescription)]
            performSegue(withIdentifier: "seguePopupFromModel", sender: data)
        } else {
            let data: [String] = ["Saved!", "Your image has been saved to your photos."]
            performSegue(withIdentifier: "seguePopupFromModel", sender: data)
        }
    }

    // Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seguePopupFromModel") {
            let vc = segue.destination as? PopupViewController
            vc?.data = sender as! [String]
        }
    }
    
    // Recognizer
    

    @IBOutlet weak var atomLabel: UILabel! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.clipsToBounds = true
        }
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! SCNView
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        atomLabel.isHidden = true
        if hitResults.count != 0 && hitResults[0].node.name != nil{
            atomLabel.isHidden = false
            atomLabel.text = hitResults[0].node.name!
        }
    }
    
    // Scene View
    
    @IBOutlet weak var sceneView: SCNView! {
        willSet {
            let scene = SCNScene()
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3Make(0, 0, 30)
            scene.rootNode.addChildNode(cameraNode)
            newValue.scene = scene
            newValue.autoenablesDefaultLighting = true
            newValue.allowsCameraControl = true
        }
    }
    @IBAction func rotateModel(_ sender: UIButton) {
        if self.modelNode.isPaused == true {
            self.modelNode.isPaused = false
        }
        else {
            self.modelNode.isPaused = true
            
        }
    }
    
    @IBAction func modelType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sticksBallsNode.isHidden = true
            bigBallsNode.isHidden = false
        }
        else if sender.selectedSegmentIndex == 1 {
            sticksBallsNode.isHidden = false
            bigBallsNode.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawScene()
    }
    
    func drawScene() {
        for atom in Ligands.LigandsGeom {
            let geom = SCNSphere(radius: 0.3)
            geom.firstMaterial?.diffuse.contents = atom.color
            let sphere = SCNNode(geometry: geom)
            sphere.position = SCNVector3Make(atom.x, atom.y, atom.z)
            sphere.name = atom.name
            sticksBallsNode.addChildNode(sphere)
            let bigGeom = SCNSphere(radius: CGFloat(atom.radius))
            bigGeom.firstMaterial?.diffuse.contents = atom.color
            let bigSphere = SCNNode(geometry: bigGeom)
            bigSphere.position = SCNVector3Make(atom.x, atom.y, atom.z)
            bigSphere.name = atom.name
            bigBallsNode.addChildNode(bigSphere)
        }
        for bound in Ligands.boundsGeom {
            let from = Ligands.LigandsGeom[bound.from - 1]
            let to = Ligands.LigandsGeom[bound.to - 1]
            let f_vec = SCNVector3Make(from.x, from.y, from.z)
            let t_vec = SCNVector3Make(to.x, to.y, to.z)
            let f_node = boundNode(from: f_vec, to: (t_vec + f_vec) / 2, col: from.color, nb: bound.number)
            let t_node = boundNode(from: (t_vec + f_vec) / 2, to: t_vec, col: to.color, nb: bound.number)
            sticksBallsNode.addChildNode(f_node)
            sticksBallsNode.addChildNode(t_node)
        }
        self.bigBallsNode.isHidden = true
        self.modelNode.addChildNode(sticksBallsNode)
        self.modelNode.addChildNode(bigBallsNode)
        self.sceneView.scene?.rootNode.addChildNode(modelNode)
        addRotation()
    }
    
    func addRotation() {
        let rot = CABasicAnimation(keyPath: "rotation")
        rot.fromValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0))
        rot.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, 2 * .pi))
        rot.duration = 15
        rot.repeatCount = .infinity
        self.modelNode.addAnimation(rot, forKey: "rotation")
        self.modelNode.isPaused = true
    }
    
    func boundNode(from: SCNVector3, to: SCNVector3, col: UIColor, nb: Int) -> SCNNode{
        if nb == 1 {
            let vec = to - from
            let height = vec.length()
            let caps = SCNCylinder(radius: 0.15, height: CGFloat(height))
            caps.firstMaterial?.diffuse.contents = col
            let node = SCNNode(geometry: caps)
            node.position = (to + from) / 2
            node.eulerAngles = SCNVector3.lineEulerAngles(vector: vec)
            return node
        }
        else {
            let res = SCNNode()
            let vec = to - from
            var perp = SCNVector3Make(1, 0, 0).normalized()
            if vec.x != 0 {
                perp = SCNVector3Make(-((vec.y + vec.z) / vec.x), 1, 1).normalized()
            }
            let height = vec.length()
            let caps = SCNCylinder(radius: 0.08, height: CGFloat(height))
            caps.firstMaterial?.diffuse.contents = col
            let first = SCNNode(geometry: caps)
            first.position = (to + from) / 2
            first.eulerAngles = SCNVector3.lineEulerAngles(vector: vec)
            first.position += perp * 0.1
            let second = SCNNode(geometry: caps)
            second.position = (to + from) / 2
            second.eulerAngles = SCNVector3.lineEulerAngles(vector: vec)
            second.position -= perp * 0.1
            res.addChildNode(first)
            res.addChildNode(second)
            return res
        }
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func normalized() -> SCNVector3 {
        return self / length()
    }
    
    static func lineEulerAngles(vector: SCNVector3) -> SCNVector3 {
        let height = vector.length()
        let lxz = sqrtf(vector.x * vector.x + vector.z * vector.z)
        let pitchB = vector.y < 0 ? Float.pi - asinf(lxz/height) : asinf(lxz/height)
        let pitch = vector.z == 0 ? pitchB : sign(vector.z) * pitchB
        
        var yaw: Float = 0
        if vector.x != 0 || vector.z != 0 {
            let inner = vector.x / (height * sinf(pitch))
            if inner > 1 || inner < -1 {
                yaw = Float.pi / 2
            } else {
                yaw = asinf(inner)
            }
        }
        return SCNVector3(CGFloat(pitch), CGFloat(yaw), 0)
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func += ( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func -= ( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}
