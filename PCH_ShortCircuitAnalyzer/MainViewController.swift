//
//  MainViewController.swift
//  PCH_ShortCircuitAnalyzer
//
//  Created by PeterCoolAssHuber on 2018-02-01.
//  Copyright © 2018 Huberis Technologies. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    var tabView:NSTabView? = nil
    var numLayers:Int = 0
    var layerViewControllers:[LayerViewController] = []
    
    // make these private to force the calling routine to call the SetData function
    private var scDataArray:[[(x:Double, (radial:Double, spBlk:Double, axial:Double))]]? = nil
    private var inputUnits:TransformerDataType = .imperial
    private var outputUnits:TransformerDataType = .metric

    func SetData(data:[[(x:Double, (radial:Double, spBlk:Double, axial:Double))]], inputUnits:TransformerDataType, outputUnits:TransformerDataType)
    {
        self.scDataArray = data
        self.inputUnits = inputUnits
        self.outputUnits = outputUnits
        
        if (layerViewControllers.count > 0)
        {
            self.ShowData()
        }
    }
    
    func ShowData()
    {
        guard let data = self.scDataArray else
        {
            DLog("Data cannot be nil when calling ShowData()")
            return
        }
        
        guard self.layerViewControllers.count > 0 else
        {
            DLog("Layer controllers have not been created!")
            return
        }
        
        for layerIndex in 0..<self.layerViewControllers.count
        {
            self.layerViewControllers[layerIndex].SetData(data: data[layerIndex], inputUnits: self.inputUnits, outputUnits: self.outputUnits)
        }
    }
    
    // Initializer to stick the new input file view right into a window
    convenience init(intoWindow:NSWindow, numLayers:Int)
    {
        if !intoWindow.isVisible
        {
            intoWindow.makeKeyAndOrderFront(nil)
        }
        
        // DLog("Is the window visible: \(intoWindow.isVisible)")
        self.init(nibName: nil, bundle: nil)
        
        if let winView = intoWindow.contentView
        {
            if winView.subviews.count > 0
            {
                // DLog("Window already has subview! Removing...")
                winView.subviews = []
            }
            
            self.numLayers = numLayers
            
            winView.addSubview(self.view)
        }
    }
    
    override func viewWillAppear()
    {
        // make the view take up nearly the entire bounds of its parent
        var frameRect = self.view.superview!.bounds
        frameRect.size.height -= 15
        self.view.frame = frameRect
        
        // get the actual tab view
        self.tabView = self.view.subviews[0] as? NSTabView
        
        guard let tabView = self.tabView else
        {
            ALog("No tab view found!")
            return
        }
        
        for i in 0..<self.numLayers
        {
            let newLayerVC = LayerViewController(nibName: nil, bundle: nil)
            
            if i < 2 // the first two tabs are always there, so just set their views
            {
                let iTab = tabView.tabViewItem(at: i)
                iTab.view = newLayerVC.view
            }
            else
            {
                let iTab = NSTabViewItem(viewController: newLayerVC)
                iTab.label = "Layer \(i+1)"
                tabView.addTabViewItem(iTab)
            }
            
            self.layerViewControllers.append(newLayerVC)
        }
        
        if self.scDataArray != nil
        {
            self.ShowData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
