//
//  CartyTradPlusAdapter.m
//  CartyTradPlus
//
//  Created by GZTD-03-01959 on 2026/1/12.
//

#import "CartyTradPlusAdapter.h"

@implementation CartyTradPlusAdapter

+ (void)setUserID:(NSString *)userID
{
    [CartyADSDK sharedInstance].userid = userID;
}

+ (void)startWithAppID:(NSString *)appid
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //gdpr
        if([MSConsentManager sharedManager].currentStatus != MSConsentStatusUnknown
           && [MSConsentManager sharedManager].isGDPRApplicable == MSBoolYes)
        {
            [[CartyADSDK sharedInstance] setGDPRStatus:[MSConsentManager sharedManager].currentStatus];
        }
        //COPPA
        int coppa = (int)[[NSUserDefaults standardUserDefaults] integerForKey:gTPCOPPAStorageKey];
        if (coppa != 0)
        {
            NSInteger isChild = (coppa == 2);
            [[CartyADSDK sharedInstance] setCOPPAStatus:isChild];
        }
        //ccpa
        int ccpa = (int)[[NSUserDefaults standardUserDefaults] integerForKey:gTPCCPAStorageKey];
        if (ccpa != 0)
        {
            [[CartyADSDK sharedInstance] setDoNotSell:!(ccpa == 2)];
        }
        //LGPD
        int lgpd = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"tradplus_consent_lgpd"];
        if (lgpd > 0)
        {
            [[CartyADSDK sharedInstance] setLGPDStatus:(lgpd == 2)];
        }
        [[CartyADSDK sharedInstance] start:appid completion:^{
            
        }];
    });
}

@end
