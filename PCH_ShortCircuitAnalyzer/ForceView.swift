//
//  ForceView.swift
//  PCH_ShortCircuitAnalyzer
//
//  Created by Peter Huber on 2018-02-01.
//  Copyright © 2018 Huberis Technologies. All rights reserved.
//

import Cocoa

class ForceView: NSView {

    var data:[(dimn:Double, value:Double)] = []
    
    let graphXaxisOffset:CGFloat = 5.0
    let graphYaxisTopOffset:CGFloat = 5.0
    let graphYaxisBottomOffset:CGFloat = 45.0
    
    var graphOrigin:NSPoint = NSPoint(x: 10.0, y: 50.0)
    
    var scale:NSPoint = NSPoint(x: 1.0, y: 1.0)
    
    var maxStress:CGFloat = 0.0

    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)

        // Drawing code here.
        
        // Save the upper-right corner of the view because it's handy for subsequent stuff
        let topRightBound = NSPoint(x: self.bounds.origin.x + self.bounds.width, y: self.bounds.origin.y + self.bounds.height)
        // Set the axis color
        NSColor.black.setStroke()
        // draw the x-axis
        let linePath = NSBezierPath(rect: self.bounds)
        linePath.move(to: NSPoint(x: self.graphXaxisOffset, y: self.graphOrigin.y))
        linePath.line(to: NSPoint(x: topRightBound.x - self.graphXaxisOffset, y: self.graphOrigin.y))
        // and the y-axis
        linePath.move(to: NSPoint(x: self.graphOrigin.x, y: self.graphYaxisBottomOffset))
        linePath.line(to: NSPoint(x: self.graphOrigin.x, y: topRightBound.y - self.graphYaxisTopOffset))
        
        linePath.stroke()
        
        guard data.count != 0 else
        {
            return
        }
        
        linePath.removeAllPoints()
        
        if (maxStress > 0.0)
        {
            NSColor.red.setStroke()
            linePath.move(to: NSPoint(x: self.graphOrigin.x, y: maxStress * scale.y))
            linePath.line(to: NSPoint(x: topRightBound.x - self.graphXaxisOffset, y:maxStress * scale.y))
            
            linePath.stroke()
            
            linePath.removeAllPoints()
        }
        
        NSColor.green.setStroke()
        
        var firstPoint = true
        for (x, y) in data
        {
            if (firstPoint)
            {
                linePath.move(to: NSPoint(x:self.graphOrigin.x + CGFloat(x) * self.scale.x, y:self.graphOrigin.y + CGFloat(y) * self.scale.y))
                firstPoint = false
            }
            else
            {
                linePath.line(to: NSPoint(x:self.graphOrigin.x + CGFloat(x) * self.scale.x, y:self.graphOrigin.y + CGFloat(y) * self.scale.y))
                firstPoint = false
            }
        }
        
        linePath.stroke()
    }
    
    func setScaleWithMaxValues(xMax:Double, yMax:Double)
    {
        let yMaxHeight = self.bounds.height - self.graphYaxisTopOffset - self.graphOrigin.y
        let xMaxWidth = self.bounds.width - self.graphXaxisOffset - self.graphOrigin.x
        
        scale.x = xMaxWidth / CGFloat(xMax)
        scale.y = yMaxHeight / max(CGFloat(yMax), self.maxStress)
        
    }
    
}
