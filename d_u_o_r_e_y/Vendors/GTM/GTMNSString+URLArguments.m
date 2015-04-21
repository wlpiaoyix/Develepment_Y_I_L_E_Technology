//
//  GTMNSString+URLArguments.m
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMNSString+URLArguments.h"

#import "GTMDefines.h"

@implementation NSString (GTMNSStringURLArgumentsAdditions)

- (NSString*)gtm_stringByEscapingForURLArgument {
  // Encode all the reserved characters, per RFC 3986
  // (<http://www.ietf.org/rfc/rfc3986.txt>)
  CFStringRef escaped = 
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
  return GTMCFAutorelease(escaped);
}

- (NSString*)gtm_stringByUnescapingFromURLArgument {
//  NSMutableString *resultString = [NSMutableString stringWithString:self];
//  [resultString replaceOccurrencesOfString:@"+"
//                                withString:@" "
//                                   options:NSLiteralSearch
//                                     range:NSMakeRange(0, [resultString length])];
//  return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    NSString *result = [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    result = [result stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    result = [result stringByReplacingOccurrencesOfString:@"%28" withString:@"("];
    result = [result stringByReplacingOccurrencesOfString:@"%29" withString:@")"];
    result = [result stringByReplacingOccurrencesOfString:@"%27" withString:@"'"];
    result = [result stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
    result = [result stringByReplacingOccurrencesOfString:@"%22" withString:@"\""];
    result = [result stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
    result = [result stringByReplacingOccurrencesOfString:@"%25" withString:@"%"];
    result = [result stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
    result = [result stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
    result = [result stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    result = [result stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    result = [result stringByReplacingOccurrencesOfString:@"%3B" withString:@";"];
    result = [result stringByReplacingOccurrencesOfString:@"%3C" withString:@"<"];
    result = [result stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    result = [result stringByReplacingOccurrencesOfString:@"%3E" withString:@">"];
    result = [result stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
    result = [result stringByReplacingOccurrencesOfString:@"%4o" withString:@"@"];
    result = [result stringByReplacingOccurrencesOfString:@"%5C" withString:@"\\"];
    result = [result stringByReplacingOccurrencesOfString:@"%7C" withString:@"|"];
    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return result;
}

- (NSString*)gtm_URLByUnescapingFromstringArgument {
    //  NSMutableString *resultString = [NSMutableString stringWithString:self];
    //  [resultString replaceOccurrencesOfString:@"+"
    //                                withString:@" "
    //                                   options:NSLiteralSearch
    //                                     range:NSMakeRange(0, [resultString length])];
    //  return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *resultString = [NSMutableString stringWithString:self];
//    [resultString replaceOccurrencesOfString:@"+"
//                                  withString:@" "
//                                     options:NSLiteralSearch
//                                       range:NSMakeRange(0, [resultString length])];
    NSString *result = [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    result = [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
//    result = [result stringByReplacingOccurrencesOfString:@"(" withString:@"%28"];
//    result = [result stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
//    result = [result stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
//    result = [result stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
//    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
//    result = [result stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
//    result = [result stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
//    result = [result stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
//    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//    result = [result stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
//    result = [result stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
//    result = [result stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
//    result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
//    result = [result stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
//    result = [result stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
//    result = [result stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
//    result = [result stringByReplacingOccurrencesOfString:@"@" withString:@"%4o"];
//    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"];
//    result = [result stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];
//    result = [result stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    return result;
}

@end
