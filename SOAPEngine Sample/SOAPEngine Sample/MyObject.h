//
//  MyObject.h
//  SOAPEngine Sample
//
//  Created by Danilo Priore on 20/11/12.
//  Copyright (c) 2012 Prioregorup.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyRemider : NSObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *description;

@end

@interface MyObject : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *surname;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) MyRemider *reminder;

@end
