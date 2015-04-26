//
//  PYGraphicsLayer.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import QuartzCore
import UIKit

class PYGraphicsLayer: CALayer {
    var userInfo:AnyObject?;
    
    private var callback:((CGContextRef,AnyObject?)->Void)?
    private var lock:NSLock = NSLock()
    
    func setCallBackGraphicsLayerDraw(callback:((CGContextRef,AnyObject?)->Void)?){
        self.lock.lock()
        self.callback = callback
        self.lock.unlock()
    }
    override func drawInContext(ctx: CGContext!) {
        self.lock.lock()
        if(self.callback != nil){
            self.callback!(ctx, self.userInfo)
        }
        self.lock.unlock()
    }
}

public class PYGraphicsThumb{
    private var callback:((CGContextRef,AnyObject?)->Void)?
    private var view:UIView?
    
    
    var thumbLayer:CALayer?
    var graphicsLayer:PYGraphicsLayer?
    var thumb = UIImage()
    
    public class func newInstance(#view:UIView, callback:(CGContextRef,AnyObject?)->Void)->PYGraphicsThumb{
        var instance = PYGraphicsThumb()
        instance.callback = callback
        instance.graphicsLayer = PYGraphicsLayer()
        instance.graphicsLayer!.removeFromSuperlayer()
        view.layer.addSublayer(instance.graphicsLayer)
        instance.view = view
        return instance
    }
    
    public func executDisplay(userInfo:AnyObject?){
        self.view!.setNeedsDisplay();
        if(self.graphicsLayer != nil){
            self.graphicsLayer!.setCallBackGraphicsLayerDraw(self.callback)
            self.graphicsLayer!.userInfo = userInfo
            self.graphicsLayer!.contentsScale = UIScreen.mainScreen().scale
            self.graphicsLayer!.frame = view!.bounds
            self.graphicsLayer!.masksToBounds = false
            self.graphicsLayer!.backgroundColor = UIColor.clearColor().CGColor
            self.graphicsLayer!.displayIfNeeded()
            self.graphicsLayer!.setNeedsDisplay()
        }
    }
    
    
}

