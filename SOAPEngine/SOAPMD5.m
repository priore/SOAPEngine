//
//  SOAPMD5.m
//  SOAPEngine
//
//  Created by Priore on 04/04/18.
//  Copyright © 2018 Priore. All rights reserved.
//

#import "SOAPMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SOAPMD5

+ (NSString*)getMD5WithString:(NSString*)string
{
    const char *cStr = string.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
