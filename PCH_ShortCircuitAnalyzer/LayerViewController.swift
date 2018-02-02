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
    }
    
}
