//
//  SOAPX509.h
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOAPX509 : NSObject

+ (NSDictionary*)getX509InfoWithName:(NSString*)certificateName password:(NSString*)password;

@end
