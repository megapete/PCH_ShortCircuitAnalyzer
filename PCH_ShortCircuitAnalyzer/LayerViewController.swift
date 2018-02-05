//
//  LayerViewController.swift
//  PCH_ShortCircuitAnalyzer
//
//  Created by PeterCoolAssHuber on 2018-02-01.
//  Copyright © 2018 Huberis Technologies. All rights reserved.
//

import Cocoa

class LayerViewController: NSViewController {

    @IBOutlet weak var radialForceView: ForceView!
    @IBOutlet weak var spBlkForceView: ForceView!
    @IBOutlet weak var axialForceView: ForceView!
    
    var viewsAreAvailable = false
    
    private var layerData:[(x:Double, y:(radial:Double, spBlk:Double, axial:Double))]? = nil
    private var inputUnits:TransformerDataType = .imperial
    private var outputUnits:TransformerDataType = .metric
    
    func SetData(data:[(x:Double, (radial:Double, spBlk:Double, axial:Double))], inputUnits:TransformerDataType, outputUnits:TransformerDataType)
    {
        self.layerData = data
        self.inputUnits = inputUnits
        self.outputUnits = outputUnits
        
        if self.viewsAreAvailable
        {
            ShowData()
        }
    }
    
    func ShowData()
    {
        var minRadValue = Double.greatestFiniteMagnitude
        var maxRadValue = -minRadValue
        var minSpBlkValue = minRadValue
        var maxSpBlkValue = maxRadValue
        var minAxialValue = minRadValue
        var maxAxialValue = maxRadValue
        
        var radialData:[(dimn:Double, value:Double)] = []
        var spBlkData:[(dimn:Double, value:Double)] = []
        var axialData:[(dimn:Double, value:Double)] = []
        
        guard let allData = self.layerData else
        {
            DLog("No data available!")
            return
        }
        
        var xMultiplier = 1.0 // for inputUnits == outputUnits
        var yMultiplier = 1.0
        if self.inputUnits != self.outputUnits
        {
            if self.inputUnits == .imperial
            {
                xMultiplier = mmPerInch
                yMultiplier = nmm2PerPsi
            }
            else
            {
                xMultiplier = inchPerMm
                yMultiplier = psiPerNmm2
            }
        }
        
        for nextData in allData
        {
            let nextX = nextData.x * xMultiplier
            var nextY = nextData.y.radial * yMultiplier
            
            minRadValue = min(0.0, (nextY < minRadValue ? nextY : minRadValue))
            maxRadValue = max(0.0, (nextY > maxRadValue ? nextY : maxRadValue))
            radialData.append((nextX, nextY))
            
            nextY = nextData.y.spBlk * yMultiplier
            minSpBlkValue = min(0.0, (nextY < minSpBlkValue ? nextY : minSpBlkValue))
            maxSpBlkValue = max(0.0, (nextY > maxSpBlkValue ? nextY : maxSpBlkValue))
            spBlkData.append((nextX, nextY))
            
            nextY = nextData.y.axial * yMultiplier
            minAxialValue = min(0.0, (nextY < minAxialValue ? nextY : minAxialValue))
            maxAxialValue = max(0.0, (nextY > maxAxialValue ? nextY : maxAxialValue))
            axialData.append((nextX, nextY))
        }
        
        self.radialForceView.SetScaleWithMaxValues(xMax: allData.last!.x, yMax: (maxRadValue - minRadValue))
        self.radialForceView.SetOriginWithActualValues(x: 0.0, y: -minRadValue)
        self.radialForceView.data = radialData
        self.radialForceView.needsDisplay = true
        
    }
    
    override func viewWillAppear()
    {
        // make the view take up the entire bounds of its parent (which should be a tab view)
        guard let tabView = self.view.superview as? NSTabView else
        {
            ALog("The superview MUST be a tab view")
            return
        }
        
        // DLog("Content rect: \(tabView.contentRect)")
        
        self.view.frame = tabView.contentRect
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do view setup here.
        
        self.viewsAreAvailable = true
        
        if self.layerData != nil
        {
            ShowData()
        }
    }
    
}
