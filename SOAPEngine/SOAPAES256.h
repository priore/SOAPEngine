//
//  SOAPAES256.h
//  SOAPEngine
//
//  Created by Danilo Priore on 06/08/14.
//  Copyright (c) 2014 Prioregroup.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOAPAES256 : NSObject

+ (NSData*)AES256EncryptData:(NSData*)data withKey:(NSString*)key;
+ (NSData*)AES256DecryptData:(NSData*)data withKey:(NSString*)key;

+ (NSData*)AES256EncryptString:(NSString*)string withKey:(NSString*)key;
+ (NSData*)AES256DecryptString:(NSString*)string withKey:(NSString*)key;

@end
