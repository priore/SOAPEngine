//
//  SOAPSHA1.h
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOAPSHA1 : NSObject

+ (NSData*)getSHA1WithData:(NSData*)data;
+ (NSData*)getSHA1WithString:(NSString*)string;
+ (NSData*)getSHA1WithCertificate:(SecCertificateRef)certificate;


@end
