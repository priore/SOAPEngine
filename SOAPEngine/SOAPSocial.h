//
//  SOAPSocial.h
//  SOAPEngine
//
//  Created by Danilo Priore on 12/05/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//
#if !TARGET_OS_TV

#import <Foundation/Foundation.h>

#if __has_include(<Accounts/Accounts.h>)
#import <Accounts/Accounts.h>
#endif

@interface SOAPSocial : NSObject

+ (void)accountInfoWithSocial:(NSString*)social
                     appIdKey:(NSString*)appIdKey
                   completion:(void(^)(BOOL granted, ACAccount *account, NSError *error))completion;

+ (void)attemptRenewCredentialsWithAccount:(ACAccount*)account
                                completion:(void(^)(ACAccountCredentialRenewResult renewResult, NSError *error))completion;
@end

#endif
