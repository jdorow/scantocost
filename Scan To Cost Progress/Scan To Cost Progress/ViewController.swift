//  ViewController.swift
//  Scan To Cost Progress
//  Created by Julian Dorow on 03.01.21.

import UIKit
import SceneKit
import ARKit
import SwiftUI

class ViewController: UIViewController, ARSCNViewDelegate {

    // Key Stats
    var isSavingFile = false
    var floorlevel: CGFloat = 0
    var ceilinglevel: CGFloat = 2.5
    var roomheight: CGFloat = 1
    var price: CGFloat = 86
    //Aus BKI Putzträger entfernen/Sandstrahlen/Putzträger verzinkt/ Putz auftragen
    var wallList = [wall]()
    public var completionhandler: ((CGFloat?) -> Void)?
    
    @IBOutlet weak var Reset: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var StartPlaneDetection: UIButton!
    @IBOutlet weak var roomheightbutton: UIButton!
    @IBOutlet weak var TotalArea: UIButton!
    @IBOutlet weak var includingHeight: UIButton!
    @IBOutlet weak var TotalCosts: UIButton!
    @IBOutlet weak var TableCosts: UIButton!
    @IBOutlet weak var CSVExport: UIButton!
    @IBOutlet weak var StandardSwitch: UIButton!
    
    // Array Grids
    var planes = [Grid]()
    var walls = [Grid]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    //anchor.classification.description == "Wall"
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical
        
        else {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal, planeAnchor.classification.description == "Floor" {

                floorlevel = CGFloat(anchor.transform.columns.3.y)
                print("Boden", floorlevel)

            }
            else if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal, planeAnchor.classification.description == "Ceiling" {
                ceilinglevel = CGFloat(anchor.transform.columns.3.y)
            }
            return
            
        }
        
        // Create candidate
        let candidate = Grid(anchor: planeAnchor, floorlevel: floorlevel, ceilinglevel: ceilinglevel, roomheight: roomheight, grids: walls, price: price)
        
        // Append to Array Planes
        self.planes.append(candidate)
        
        // Append to Array Walls
        if planeAnchor.classification.description == "Wall"{
            walls.append(candidate)
        }
        
        node.addChildNode(candidate)
        print(walls)
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical
        
        else {
            return
        }
        let grid = self.planes.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            
            }.first

        guard let foundGrid = grid else {
            return
        }

        // Later identification
        let oldclassification = foundGrid.classificationString
        let currentclassfication = planeAnchor.classification.description
        
        // Later appendation to Array Walls
        if currentclassfication == "Wall" {
        
            if oldclassification != currentclassfication {
                
                foundGrid.newid = walls.count
                walls.append(foundGrid)
            }
            
            foundGrid.update(anchor: planeAnchor)
        }
        
    }
    
    // MARK: - Buttons
    
    @IBAction func Reset(_ sender: Any){
        if let configuration = sceneView.session.configuration {
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if node.name == "node"{
                    node.removeFromParentNode()
                }
            }
            planes = []
            walls = []
            sceneView.session.run(configuration, options:[.removeExistingAnchors, .resetTracking])
        }
    }
    
    @IBAction func TogglePlaneDetection(_ button: UIButton) {
        guard let configuration = sceneView.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        if configuration.planeDetection == [] {
            configuration.planeDetection = [.horizontal, .vertical]
            button.setTitle("Stop Wall Detection", for: [])
        } else {
            configuration.planeDetection = []
            button.setTitle("Start Wall Detection", for: [])
        }
        sceneView.session.run(configuration)
        
    }
    
    @IBAction func roomheightpressed(_ button: UIButton) {
        roomheight = ceilinglevel - floorlevel
        button.setTitle("Height: " + String(format: "%.2fm", roomheight), for: [])
    }
    
    
    @IBAction func TotalArea(_ button: UIButton) {
        var Gesamt: CGFloat = 0
        for item in walls{
            let A = item.planeGeometry.width * item.planeGeometry.height
            Gesamt = Gesamt + A
        }
        button.setTitle("Total: " + String(format: "%.2fm²", Gesamt), for: [])
    }
    
    @IBAction func TotalCosts(_ button: UIButton) {
        var Gesamt2: CGFloat = 0
        for item in walls{
            let A = item.planeGeometry.width * item.planeGeometry.height
            Gesamt2 = Gesamt2 + A
        }
        let costs = Gesamt2 * price
        button.setTitle("Costs: " + String(format: "%.1f€", costs), for: [])
    }
    
    
    @IBAction func IncludingHeight(_ button: UIButton) {
        var Gesamt3: CGFloat = 0
        for item in walls{
            let AH = item.planeGeometry.width * roomheight
            Gesamt3 = Gesamt3 + AH
        }
        let costs = Gesamt3 * price
        button.setTitle("incl. H: " + String(format: "%.1f€", costs), for: [])
    }
    
    @IBAction func TableCosts(_ button: UIButton) {
        wallList.removeAll()
        var TotalArea: CGFloat = 0
        var TotalAreaH: CGFloat = 0
        var TotalWidth: CGFloat = 0
        for item in walls {
            let A = item.planeGeometry.width * item.planeGeometry.height
            let AH = item.planeGeometry.width * roomheight
            let costs = A * price
            let wa = wall(id: String(wallList.count + 1), name: "Wall", width: String(format: "%.1fm", item.planeGeometry.width), area: String(format: "%.1fm²", A), price: String(format: "%.1f€", costs), color: .black)
            TotalArea = TotalArea + A
            TotalAreaH = TotalAreaH + AH
            TotalWidth = TotalWidth + item.planeGeometry.width
            wallList.append(wa)
        }
        // Setup Total
        let TotalCosts = TotalArea * price
        //let IncludingHeight = TotalAreaH * price
        let total = wall(id: "=", name: "Total", width: String(format:"%.1fm", TotalWidth), area: String(format: "%.1fm²", TotalArea), price: String(format: "%.1f€", TotalCosts), color: .red)
        wallList.append(total)
        // Open TableViewController
        let vc = storyboard?.instantiateViewController(identifier: "table_view") as! TrueTableViewController
        // Pass Data to TableViewController
        vc.List = wallList
        
        present(vc, animated: true)
    }
    
    @IBAction func CSVExport(_ button: UIButton) {
        // Setup Date
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = " d-MMM-y, HH-mm"
        
        // FileManager
        /*let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let file = documentsDirectory.appendingPathComponent("ply_\(UUID().uuidString).ply")
        
        guard !self.isSavingFile else { return }
          self.isSavingFile = true
        var fileToWrite = ""
        do {
            
                // 7
                try fileToWrite.write(to: file, atomically: true, encoding: String.Encoding.ascii)
                self.isSavingFile = false
            } catch {
                print("Failed to write PLY file", error)
            }*/

        
        // Setup File
        let sFileName = "Table_File\(formatter1.string(from: today)).csv" //File Name
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let documentURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(sFileName)
        
        let output = OutputStream.toMemory()
        
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        // Header for CSV File
        csvWriter?.writeField("WALL_ID")
        csvWriter?.writeField("TYPE")
        csvWriter?.writeField("WIDTH")
        csvWriter?.writeField("AREA")
        csvWriter?.writeField("COST")
        csvWriter?.finishLine()
        
        // Create Totals
        var TotalArea: CGFloat = 0
        var TotalAreaH: CGFloat = 0
        var TotalWidth: CGFloat = 0
        
        // Create Array
        var ArrayList = [[String]]()
        for item in walls {
            let A = item.planeGeometry.width * item.planeGeometry.height
            let AH = item.planeGeometry.width * roomheight
            let costs = A * price
            let wa = [String(ArrayList.count + 1), "Wand", String(format: "%.1fm", item.planeGeometry.width), String(format: "%.1fm²", A), String(format: "%.1f€", costs)]
            TotalArea = TotalArea + A
            TotalAreaH = TotalAreaH + AH
            TotalWidth = TotalWidth + item.planeGeometry.width
            ArrayList.append(wa)
        }
        let TotalCosts = TotalArea * price
        let total = ["=", "Total", String(format:"%.1fm", TotalWidth), String(format: "%.1fm²", TotalArea), String(format: "%.1f€", TotalCosts)]
        ArrayList.append(total)

        // Write Columns
        for(elements) in ArrayList.enumerated(){
            csvWriter?.writeField(elements.element[0]) // Added ID
            csvWriter?.writeField(elements.element[1]) // Added Type
            csvWriter?.writeField(elements.element[2]) // Added Width
            csvWriter?.writeField(elements.element[3]) // Added Area
            csvWriter?.writeField(elements.element[4]) // Added Cost
            csvWriter?.finishLine()
        }
        csvWriter?.closeStream()
        
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
        
        do{
            try buffer.write(to: documentURL)
        }
        catch
        {
            
        }
        
        // FileWindow
        DispatchQueue.main.async {
          let ac = UIActivityViewController(activityItems: [documentURL], applicationActivities: nil)
             if let popover = ac.popoverPresentationController {
                popover.sourceView = button
          }
          self.present(ac, animated: true)
        }

    }
    
    @IBAction func StandardSwitch(_ button: UIButton) {
        if price == 86 {
            // Reset Scene
            if let configuration = sceneView.session.configuration {
                sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "node"{
                        node.removeFromParentNode()
                    }
                }
                planes = []
                walls = []
                sceneView.session.run(configuration, options:[.removeExistingAnchors, .resetTracking])
            }
            // Button
            price = 39
            button.setTitle("Need: Medium", for: [])
        }
        else if price == 39 {
            // Reset Scene
            if let configuration = sceneView.session.configuration {
                sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "node"{
                        node.removeFromParentNode()
                    }
                }
                planes = []
                walls = []
                sceneView.session.run(configuration, options:[.removeExistingAnchors, .resetTracking])
            }
            // Button
            price = 17
            button.setTitle("Need: Low", for: [])
        }
        else if price == 17 {
            // Reset Scene
            if let configuration = sceneView.session.configuration {
                sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "node"{
                        node.removeFromParentNode()
                    }
                }
                planes = []
                walls = []
                sceneView.session.run(configuration, options:[.removeExistingAnchors, .resetTracking])
            }
            // Reset Button
            price = 86
            button.setTitle("Need: High", for: [])
        }
    }
    
}
