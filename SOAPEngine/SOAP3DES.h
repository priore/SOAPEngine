//
//  SOAP3DES.h
//  SOAPEngine
//
//  Created by Priore on 02/09/14.
//  Copyright (c) 2014 Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOAP3DES : NSObject

+ (NSData*)TripleDESEncryptData:(NSData*)data withKey:(NSString*)key;
+ (NSData*)TripleDESEncryptString:(NSString*)string withKey:(NSString*)key;

+ (NSData*)TripleDESDecryptData:(NSData*)data withKey:(NSString*)key;
+ (NSData*)TripleDESDecryptString:(NSString*)string withKey:(NSString*)key;

@end
