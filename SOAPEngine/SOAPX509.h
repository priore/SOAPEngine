//
//  SOAPX509.h
//  SOAPEngine
//
//  Created by Priore on 03/07/15.
//  Copyright (c) 2015 Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOAPX509 : NSObject

+ (NSDictionary*)getX509InfoWithName:(NSString*)certificateName password:(NSString*)password;

@end
