//
//  TestView.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class TestView: UIView {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        var ctx:CGContextRef? = nil//UIGraphicsGetCurrentContext()
        var color = UIColor.greenColor();
        
        var point1 = CGPointMake(30, 30);
        var point2 = CGPointMake(30, 60);
        var point3 = CGPointMake(80, 60);
        var point4 = CGPointMake(80, 30);
        var points = [point1,point2,point3,point4];
        
//        PYCalGraphicsDraw.drawLine(context: ctx, startPoint: CGPointMake(40, 40), endPoint: CGPointMake(100, 100), lineColor: color.CGColor, lineWidth: 2);
//        var color2 = UIColor.blueColor()
//        PYCalGraphicsDraw.drawPolygon(context: ctx, pointer: &points, pointsLength: 4, strokeColor: color2.CGColor, fillColor: nil, lineWidth: 2);
//        PYCalGraphicsDraw.drawCircle(context: nil, pointCenter: CGPointMake(100, 200), strokeColor: UIColor.yellowColor().CGColor, fillColor: nil, lineWidth: 20, startDegree: 0, endDegree: 98, radius: 40);
//        PYCalGraphicsDraw.drawEllipse(context: nil, rect: CGRectMake(150, 150, 50, 80), strokeColor: UIColor.blueColor().CGColor, fillColor: color.CGColor, lineWidth: 0.5)
        PYCalGraphicsDraw.drawText(context: nil, attribute: NSMutableAttributedString(string: "asdfasdf"), rect: CGRectMake(80, 20, 100, 100), y: self.bounds.height, scaleFlag: true)
//        PYCalGraphicsDraw.drawText(context: nil, text: "adfadasdfasdfasdfasdfasdfasdfsaa", attribute: nil, rect:CGRectMake(80, 20, 100, 100), y:self.bounds.height, scaleFlag:true);
//        PYCalGraphicsDraw.drawText(context: nil, text: "我在来看一下", attribute: nil, rect:CGRectMake(80, 80, 100, 100), y:self.bounds.height, scaleFlag:false);
//        PYCalGraphicsDraw.drawText(context: nil, text: "我在来看一下", attribute: nil, rect:CGRectMake(80, 120, 100, 100), y:self.bounds.height, scaleFlag:false);
        
    }


}
