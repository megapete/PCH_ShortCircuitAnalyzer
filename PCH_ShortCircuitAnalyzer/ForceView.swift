//
//  ForceView.swift
//  PCH_ShortCircuitAnalyzer
//
//  Created by Peter Huber on 2018-02-01.
//  Copyright © 2018 Huberis Technologies. All rights reserved.
//

import Cocoa

class ForceView: NSView {

    var times:[Double] = []
    var values:[Double] = []
    
    let graphXaxisOffset:CGFloat = 5.0
    let graphYaxisTopOffset:CGFloat = 5.0
    let graphYaxisBottomOffset:CGFloat = 45.0
    
    var graphOrigin:NSPoint = NSPoint(x: 10.0, y: 50.0)
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)

        // Drawing code here.
        
        // Save the upper-right corner of the view because it's handy
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
        
    }
    
}
