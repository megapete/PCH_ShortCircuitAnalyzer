//
//  AppController.swift
//  PCH_ShortCircuitAnalyzer
//
//  Created by Peter Huber on 2018-01-31.
//  Copyright © 2018 Huberis Technologies. All rights reserved.
//

import Cocoa

enum TransformerDataType {
    
    case imperial
    case metric
    
}

class AppController: NSObject, NSOpenSavePanelDelegate
{
    var currentOutputData:PCH_FLD12_OutputData? = nil
    var currentFileName:String? = nil
    var mainViewController:MainViewController? = nil
    
    var scDataArray:[[(x:Double, (radial:Double, spBlk:Double, axial:Double))]] = [[]]
    
    // Variable used to hold the current openPanel so the delegate routine can respond correctly
    var openPanel:NSOpenPanel? = nil
    
    @IBOutlet weak var mainWindow: NSWindow!
    
    func setNewDataForDisplay()
    {
        guard let outputData = self.currentOutputData else
        {
            DLog("Invalid output data!")
            ShowSimpleCriticalPanelWithString("Invalid output data")
            return
        }
        
        guard let inputData:PCH_FLD12_TxfoDetails = outputData.inputData else
        {
            DLog("Invalid input data!")
            ShowSimpleCriticalPanelWithString("Invalid input data")
            return
        }
        
        guard let layers:[PCH_FLD12_Layer] = inputData.layers as? [PCH_FLD12_Layer] else
        {
            DLog("Invalid layer data!")
            ShowSimpleCriticalPanelWithString("Invalid layer data")
            return
        }
        
        self.mainViewController = MainViewController(intoWindow: mainWindow, numLayers:layers.count)
        
        guard let segmentSCdata:[SegmentData] = outputData.segmentData as? [SegmentData] else
        {
            DLog("Invalid output segment data!")
            ShowSimpleCriticalPanelWithString("Invalid output segment data")
            return
        }
        
        // reset the global variable holding the sc data
        self.scDataArray = [[]]
        
        for nextLayer in layers
        {
            var scArray:[(x:Double, y:Double)] = []
            
            guard let segArray:[PCH_FLD12_Segment] = nextLayer.segments as? [PCH_FLD12_Segment] else
            {
                DLog("Invalid input segment data!")
                ShowSimpleCriticalPanelWithString("Invalid input segment data")
                return
            }
            
            for nextSegment in segArray
            {
                var scData:(radial:Double, spBlk:Double, axial:Double) = (0.0, 0.0, 0.0)
                
                for nextSCdata in segmentSCdata
                {
                    if (nextSCdata.number == nextSegment.segmentNumber)
                    {
                        scData = (nextSCdata.scMaxTensionCompression, nextSCdata.scForceInSpacerBlocks, nextSCdata.scCombinedForce)
                        
                        break;
                    }
                }
                
                if segArray.count == 1
                {
                    
                }
                else
                {
                    
                }
                
            }
        }
        
    }
    
    @IBAction func handleOpenFLD12OutputFile(_ sender: Any)
    {
        self.openPanel = NSOpenPanel()
        
        guard let openPanel = self.openPanel else
        {
            return
        }
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.message = "Open FLD12 Output File"
        openPanel.delegate = self
        openPanel.validateVisibleColumns()
        
        if openPanel.runModal() == .OK
        {
            guard let fileURL = openPanel.url else
            {
                DLog("URL not returned!")
                ShowSimpleCriticalPanelWithString("A serious error occurred (could not get file URL).")
                self.openPanel = nil
                return
            }
            
            var outputFileAsString:String = ""
            
            do
            {
                outputFileAsString = try String(contentsOfFile:fileURL.path, encoding:String.Encoding.utf8)
            }
            catch
            {
                // this shouldn't happen, since our filter has already confirmed that this is a text file
                DLog("Could not convert file")
                self.openPanel = nil
                return
            }
            
            guard let outputData = PCH_FLD12_OutputData(outputFile: outputFileAsString) else
            {
                DLog("Bad file format")
                ShowSimpleCriticalPanelWithString("A serious error occurred (the choice is not a valid FLD12 output file).")
                self.openPanel = nil
                return
            }
            
            self.currentOutputData = outputData
            self.currentFileName = fileURL.deletingPathExtension().lastPathComponent
            
        }
        
        self.setNewDataForDisplay()
    
        self.openPanel = nil
    }
    
    func ShowSimpleWarningPanelWithString(_ wString:String)
    {
        let theAlert = NSAlert()
        theAlert.alertStyle = .warning
        theAlert.informativeText = wString
        theAlert.addButton(withTitle: "Ok")
        
        theAlert.runModal()
    }
    
    func ShowSimpleCriticalPanelWithString(_ wString:String)
    {
        let theAlert = NSAlert()
        theAlert.alertStyle = .critical
        theAlert.informativeText = wString
        theAlert.addButton(withTitle: "Ok")
        
        theAlert.runModal()
    }
    
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool
    {
        // Always enable directories so that the user can actually go into them
        if url.hasDirectoryPath
        {
            return true
        }
        
        // We only scan if the sender is actually the currently visible Open Panel. I don't know if this is really required or not.
        if (self.openPanel?.isEqual(sender))!
        {
            do
            {
                let sharedWs = NSWorkspace.shared
                let uti = try sharedWs.type(ofFile: url.path)
                
                // Start out the easy way and hope that the file bing scanned conforms to the "public.text" UTI
                if sharedWs.type(uti, conformsToType: "public.text")
                {
                    return true
                }
                
                // The AndersenFE program defaults to the extension .inp for its input files
                if url.pathExtension == "inp"
                {
                    // DLog("Got a .imp")
                    return true
                }
            }
            catch
            {
                return false
            }
            
            do
            {
                // We get here if the UTI of the file did not conform to public.text -  most probably this will be called a hell of a lot. Note that this will only work if App Sanbox is set to NO in the .entitlements file.
                let _ = try String(contentsOfFile:url.path, encoding:String.Encoding.utf8)
            }
            catch
            {
                return false
            }
            
            return true
        }
        
        return false
    }
}
