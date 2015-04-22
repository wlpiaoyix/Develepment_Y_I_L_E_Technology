//
//  UIFont+PYCalExpand.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

extension UIFont {
    /**
    计算指定字体对应的高度
    */
    func getTextHeight()->CGFloat{
        var customFont = CGFontCreateWithFontName(self.fontName as CFStringRef)
        var bbox = CGFontGetFontBBox(customFont);
        var units = CGFontGetUnitsPerEm(customFont);
        var height = CGFloat(bbox.size.height) / CGFloat(units) * self.pointSize;
        return height;
    }
    
}