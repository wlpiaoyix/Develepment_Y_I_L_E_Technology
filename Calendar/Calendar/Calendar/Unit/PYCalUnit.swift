//
//  PYCalUnit.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

public class PYCalUnit: NSObject {
    //计算文字占用的大小
    public class func getBoundSize(#text:NSString, font:UIFont, size:CGSize)->CGSize{
        var attribute = [NSFontAttributeName:font];
        var options = NSStringDrawingOptions.UsesLineFragmentOrigin;
        var _size = text.boundingRectWithSize(size, options: options, attributes: attribute, context: nil).size;
        return _size;
    }

}
