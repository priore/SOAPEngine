//
//  SOAPSHA1.m
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import "SOAPSHA1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SOAPSHA1

+ (NSData*)getSHA1WithData:(NSData*)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    return [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

+ (NSData*)getSHA1WithString:(NSString*)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self getSHA1WithData:data];
}

+ (NSData*)getSHA1WithCertificate:(SecCertificateRef)certificate
{
    NSData *data = (__bridge_transfer NSData *)SecCertificateCopyData(certificate);
    return [self getSHA1WithData:data];
}

@end
