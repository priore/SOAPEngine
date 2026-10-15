//
//  NSData+SOAPEngine.h
//  SOAPEngine
//
//  Created by Priore on 03/07/15.
//  Copyright (c) 2015 Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPEngine.h"

@interface NSData (SOAPEngine)

- (NSString*)encryptWithType:(SOAPEnryption)type password:(NSString*)password;
- (NSData*)decryptWithType:(SOAPEnryption)type password:(NSString*)password;

- (NSString*)toString;

@end
