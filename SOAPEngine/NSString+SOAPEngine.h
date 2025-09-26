//
//  NSString+SOAPEngine.h
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPEngine.h"

@interface NSString (SOAPEngine)

- (NSString*)stringUnescaping;
- (NSStringEncoding)UTFType;

- (NSString*)encryptWithType:(SOAPEnryption)type password:(NSString*)password;
- (NSString*)decryptWithType:(SOAPEnryption)type password:(NSString*)password;

- (NSString*)soap_stringByEscapingForHTML;
- (NSString*)soap_stringByEscapingForAsciiHTML;
- (NSString*)soap_stringByEscapingForXML;
- (NSString*)soap_stringByUnescapingForHTML;

@end
