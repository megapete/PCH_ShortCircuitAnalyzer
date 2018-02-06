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
    var scaleBounds:NSRect = NSRect()
    
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
            }
        }
        
        linePath.stroke()
    }
    
    func SetOriginWithActualValues(x:Double, y:Double)
    {
        graphOrigin.x = CGFloat(x) * scale.x + self.graphXaxisOffset + 5.0
        graphOrigin.y = CGFloat(y) * scale.y + self.graphYaxisBottomOffset + 5.0
    }
    
    func SetScaleWithMaxValues(xMax:Double, yMax:Double)
    {
        // DLog("View rect: \(self.bounds)")
        
        let yMaxHeight = self.bounds.height - self.graphYaxisTopOffset - self.graphYaxisBottomOffset - 10.0
        let xMaxWidth = self.bounds.width - self.graphXaxisOffset * 2.0 - 10.0
        
        self.scale.x = xMaxWidth / CGFloat(xMax)
        self.scale.y = yMaxHeight / CGFloat(yMax)
        
        // save the bounds that the scale was calculated with (we'll need it in the event of a resize of the window)
        self.scaleBounds = self.bounds
    }
    
    func ResetDimensionsAfterResize()
    {
        let newMaxWidth = self.bounds.width - self.graphXaxisOffset * 2.0 - 10.0
        let oldMaxWidth = self.scaleBounds.width - self.graphXaxisOffset * 2.0 - 10.0
        let newMaxHeight = self.bounds.height - self.graphYaxisTopOffset - self.graphYaxisBottomOffset - 10.0
        let oldMaxHeight = self.scaleBounds.height - self.graphYaxisTopOffset - self.graphYaxisBottomOffset - 10.0
        
        self.scale.x *= newMaxWidth / oldMaxWidth
        self.scale.y *= newMaxHeight / oldMaxHeight
        
        self.scaleBounds = self.bounds
        
        // fix the origin according to the new scale
        graphOrigin.x = (graphOrigin.x - self.graphXaxisOffset - 5.0) * newMaxWidth / oldMaxWidth + self.graphXaxisOffset + 5.0
        graphOrigin.y = (graphOrigin.y - self.graphYaxisBottomOffset - 5.0) * newMaxHeight / oldMaxHeight + self.graphYaxisBottomOffset + 5.0
    }
    
}
