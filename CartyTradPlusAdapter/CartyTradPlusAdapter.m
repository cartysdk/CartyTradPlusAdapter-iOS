
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
        if([MSConsentManager sharedManager].currentStatus != MSConsentStatusUnknown
           && [MSConsentManager sharedManager].isGDPRApplicable == MSBoolYes)
        {
            [[CartyADSDK sharedInstance] setGDPRStatus:[MSConsentManager sharedManager].currentStatus];
        }
        int coppa = (int)[[NSUserDefaults standardUserDefaults] integerForKey:gTPCOPPAStorageKey];
        if (coppa != 0)
        {
            NSInteger isChild = (coppa == 2);
            [[CartyADSDK sharedInstance] setCOPPAStatus:isChild];
        }
        int ccpa = (int)[[NSUserDefaults standardUserDefaults] integerForKey:gTPCCPAStorageKey];
        if (ccpa != 0)
        {
            [[CartyADSDK sharedInstance] setDoNotSell:!(ccpa == 2)];
        }
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
