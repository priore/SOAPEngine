//
//  SOAPBase64.h
//  SOAPEngine
//
//  Created by Priore on 25/06/13.
//  Copyright (c) 2013 Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOAPBase64 : NSObject

+ (NSString *)base64EncodingWithData:(NSData*)data;
+ (NSString *)base64EncodingWithString:(NSString*)string;

+ (NSData *)base64DecodingWithString:(NSString*)string;
+ (NSString *)stringDecodingBase64WithString:(NSString*)string;

@end
