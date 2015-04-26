//
//  PYCalGraphicsDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit


//==>角度和弧度之间的转换
func PYCALparseDegreesToRadians(degrees:CGFloat)->CGFloat{
    return degrees * CGFloat(M_PI) / 180.0;
}
func PYCALparseRadiansToDegrees(radian:CGFloat)->CGFloat{
    return radian * 180.0 / CGFloat(M_PI);
}
//<==

public class PYCalGraphicsDraw: NSObject {
    
    /**
    画直线
    */
    public class func drawLine(#context:CGContextRef?, startPoint:CGPoint, endPoint:CGPoint ,strokeColor:CGColorRef, strokeWidth:CGFloat, lengthPointer:UnsafePointer<CGFloat>?, count:Int){
        var ctx = context
        self.startDraw(contextPointer: &ctx)
        //线宽设定
        CGContextSetLineWidth(ctx!, strokeWidth)
        //线的边角样式（圆角型）
        CGContextSetLineCap(ctx, kCGLineCapRound)
        CGContextSetLineJoin(ctx, kCGLineJoinRound)
        if (lengthPointer != nil){
            CGContextSetLineDash(ctx, 0, lengthPointer!, count)
        }else{
            CGContextSetLineDash(ctx, 0, nil, 0)
        }
        
        //线条颜色
        CGContextSetStrokeColorWithColor(ctx, strokeColor)
        
        //移动绘图点
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y)
        //绘制直线
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y)
        self.endDraw(contextPointer: &ctx)
    }
    
    /**
    多边形
    */
    public class func drawPolygon(#context:CGContextRef?, pointer:UnsafeMutablePointer<CGPoint>, pointsLength:UInt?, strokeColor:CGColorRef, fillColor:CGColorRef?, strokeWidth:(CGFloat)) {
        var ctx = context
        self.startDraw(contextPointer: &ctx)
        
        //线宽设定
        CGContextSetLineWidth(ctx, strokeWidth)
        //线的边角样式（圆角型）
        CGContextSetLineCap(ctx, kCGLineCapRound)
        CGContextSetLineJoin(ctx, kCGLineJoinRound)
        //线条颜色
        CGContextSetStrokeColorWithColor(ctx, strokeColor);
        if(fillColor != nil){
            //填充颜色
            CGContextSetFillColorWithColor(ctx, fillColor);
            CGContextDrawPath(ctx, kCGPathFillStroke); //绘制路径加填充
        }
        
        var currentPointer:UnsafeMutablePointer<CGPoint>? = pointer
        var currentPoint:CGPoint? = currentPointer!.memory
        var currentIndex:UInt = 0;
        CGContextMoveToPoint(ctx, currentPoint!.x, currentPoint!.y);
        while(true){
            ++currentIndex;
            if(currentIndex >= pointsLength){
                break;
            }
            currentPointer = currentPointer!.successor()
            if(currentPoint == nil){
                break
            }
            currentPoint = currentPointer!.memory
            if(currentPoint == nil){
                break
            }
            //绘制直线
            CGContextAddLineToPoint(ctx, currentPoint!.x, currentPoint!.y);
        }
        //封闭
        CGContextClosePath(ctx);
        self.endDraw(contextPointer: &ctx);
    }
    /**
    画比例圈
    */
    public class func drawCircle(#context:CGContextRef?, pointCenter:CGPoint,strokeColor:CGColorRef, fillColor:CGColorRef?, strokeWidth:CGFloat, startDegree:CGFloat, endDegree:CGFloat, radius:CGFloat){
        var ctx = context
        self.startDraw(contextPointer: &ctx)
        //（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
        CGContextSetLineDash(ctx, 0, nil, 0);
        CGContextSetLineCap(ctx, kCGLineCapButt);//线的边角样式（直角型）
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineWidth(ctx, strokeWidth);//线的宽度
        
        CGContextSetStrokeColorWithColor(ctx, strokeColor); //线条颜色
        CGContextAddArc(ctx, pointCenter.x, pointCenter.y, radius, PYCALparseDegreesToRadians(startDegree), PYCALparseDegreesToRadians(endDegree), 0); //添加一个圆
        
        if (fillColor != nil) {
            CGContextSetFillColorWithColor(ctx, fillColor);//填充颜色
            CGContextDrawPath(ctx, kCGPathFillStroke); //绘制路径加填充
        }
        self.endDraw(contextPointer: &ctx);
    }
    /**
    画椭圆
    */
    public class func drawEllipse(#context:CGContextRef?, rect:CGRect, strokeColor:CGColorRef, fillColor:CGColorRef?, strokeWidth:CGFloat){
        var ctx = context
        self.startDraw(contextPointer: &ctx)
        //（上下文，起点的偏移量，事例描述的时20像素的虚线10的空格，数组有2个元素）
        CGContextSetLineDash(ctx, 0, nil, 0);
        CGContextSetLineCap(ctx, kCGLineCapButt);//线的边角样式（直角型）
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineWidth(ctx, strokeWidth);//线的宽度
        
        CGContextSetStrokeColorWithColor(ctx, strokeColor); //线条颜色
        CGContextStrokeEllipseInRect(ctx, rect);//添加一个圆
        
        if(fillColor != nil){
            CGContextSetFillColorWithColor(ctx, fillColor);//填充颜色
            CGContextFillEllipseInRect(ctx,rect);//添加一个圆
        }
        CGContextDrawPath(ctx, kCGPathFillStroke); //绘制路径加填充
        self.endDraw(contextPointer: &ctx);
    }
    /**
    画文本
    rect:位置和区域大小
    y:反转位置 :bounds.size.height
    */
    public class func drawText(#context:CGContextRef?, attribute:NSMutableAttributedString!,  rect:CGRect, y:CGFloat, scaleFlag:Bool){
        var ctx = context
        self.startDraw(contextPointer: &ctx)
        if(scaleFlag == true){
            CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);//重置绘图环境矩阵
            CGContextTranslateCTM(ctx, 0, y);//移动绘图环境
            CGContextScaleCTM(ctx, 1.0, -1.0);//翻转绘图环境
        }
        
        var pathRef = CGPathCreateMutable()
        var _rect = rect;
        _rect.origin.y = y - rect.size.height - rect.origin.y
        var rects = [_rect]
        CGPathAddRects(pathRef, nil, &rects, 1)
        
//        var attributeString = attribute
//        if(attributeString == nil){
//            
//            var color = UIColor.blueColor()
//            var range = NSMakeRange(0, attribute.length)
//            attributeString = NSMutableAttributedString(string: text as String);//构建文字信息
//            attributeString!.addAttribute(kCTForegroundColorAttributeName as String, value: color, range: range);
//            
//            var font = UIFont.systemFontOfSize(18)
//            attributeString!.addAttribute(kCTFontAttributeName as String, value: font, range: range)
//        }
        //==>根据据attributeString的信息构建所需的空间大小
        var framesetter = CTFramesetterCreateWithAttributedString(attribute);
        var keys:UnsafeMutablePointer<UnsafePointer<Void>> = UnsafeMutablePointer.alloc(1)
        var values:UnsafeMutablePointer<UnsafePointer<Void>> = UnsafeMutablePointer.alloc(1)
        var dicRef = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, nil, nil)
        var frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attribute!.length), pathRef, dicRef);
        //<==
        CTFrameDraw(frameRef, ctx);//一切信息准备就绪，坐等绘图
        self.endDraw(contextPointer: &ctx);
    }
    
    private class func startDraw(#contextPointer:UnsafeMutablePointer<CGContextRef?>?){
        if(contextPointer == nil){
            return
        }
        if(contextPointer!.memory == nil){
            contextPointer!.memory = UIGraphicsGetCurrentContext()
        }
        UIGraphicsPushContext(contextPointer!.memory!)//起一个分支
    }
    private class func endDraw(#contextPointer:UnsafeMutablePointer<CGContextRef?>?){
        if(contextPointer == nil){
            return
        }
        if(contextPointer!.memory == nil){
            return
        }
        UIGraphicsPopContext()//收起分支
        //开始绘制线并在view上显示
        CGContextStrokePath(contextPointer!.memory!)
    }
    
}
