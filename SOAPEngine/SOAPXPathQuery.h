//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSArray *SOAPPerformHTMLXPathQuery(NSData *document, NSString *query);
NSArray *SOAPPerformXMLXPathQuery(NSData *document, NSString *query);
