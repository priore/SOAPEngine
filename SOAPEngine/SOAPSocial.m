//
//  SOAPSocial.m
//  SOAPEngine
//
//  Created by Danilo Priore on 12/05/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//
#if !TARGET_OS_TV

#import "SOAPSocial.h"

@implementation SOAPSocial

+ (void)accountInfoWithSocial:(NSString*)social
                     appIdKey:(NSString*)appIdKey
                   completion:(void(^)(BOOL granted, ACAccount *account, NSError *error))completion
{
    ACAccountStore *accountStore = [ACAccountStore new];
    ACAccountType *accountType= [accountStore accountTypeWithAccountTypeIdentifier:social];
    
    NSDictionary *dict = nil;
    
    if (social == ACAccountTypeIdentifierFacebook)
        dict = [NSDictionary dictionaryWithObjectsAndKeys:appIdKey, ACFacebookAppIdKey, @[@"email"], ACFacebookPermissionsKey, nil];
    else if (social == ACAccountTypeIdentifierTencentWeibo)
        dict = [NSDictionary dictionaryWithObjectsAndKeys:appIdKey, ACTencentWeiboAppIdKey, nil];
    
#if !TARGET_IPHONE_SIMULATOR && !TARGET_OS_IOS
    if (social == ACAccountTypeIdentifierLinkedIn)
        dict = [NSDictionary dictionaryWithObjectsAndKeys:appIdKey, ACLinkedInAppIdKey, @[@"email"], ACLinkedInPermissionsKey, nil];
#endif
    
    [accountStore requestAccessToAccountsWithType:accountType options:dict completion:
     ^(BOOL granted, NSError *error) {
         
         ACAccount *account = nil;
         
         if (granted)
         {
             NSArray *accounts = [accountStore accountsWithAccountType:accountType];
             account = [accounts lastObject];
         }
         
         if (completion)
             completion(granted, account, error);
     }];
}

+ (void)attemptRenewCredentialsWithAccount:(ACAccount*)account
                                completion:(void(^)(ACAccountCredentialRenewResult renewResult, NSError *error))completion
{
    ACAccountStore *accountStore = [ACAccountStore new];
    [accountStore renewCredentialsForAccount:(ACAccount *)account completion:completion];
}

@end

#endif
