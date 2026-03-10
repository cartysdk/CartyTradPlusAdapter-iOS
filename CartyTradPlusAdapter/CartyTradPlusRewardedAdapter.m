
#import "CartyTradPlusRewardedAdapter.h"

@interface CartyTradPlusRewardedAdapter()<CTRewardedVideoAdDelegate>

@property (nonatomic,strong)CTRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL isC2SBidding;
@end

@implementation CartyTradPlusRewardedAdapter

- (BOOL)extraActWithEvent:(NSString *)event info:(NSDictionary *)config
{
    if([event isEqualToString:@"C2SBidding"])
    {
        self.isC2SBidding = YES;
        [self loadAdWithWaterfallItem:self.waterfallItem];
    }
    else if([event isEqualToString:@"LoadAdC2SBidding"])
    {
        if([self isReady])
        {
            [self AdLoadFinsh];
        }
        else
        {
            NSError *loadError = [NSError errorWithDomain:@"ct" code:402 userInfo:@{NSLocalizedDescriptionKey : @"C2S rewarded not ready"}];
            [self AdLoadFailWithError:loadError];
        }
    }
    else
    {
        return NO;
    }
    return YES;
}

- (void)loadAdWithWaterfallItem:(TradPlusAdWaterfallItem *)item
{
    NSString *appid = item.config[@"appid"];
    NSString *pid = item.config[@"pid"];
    if(appid == nil || pid == nil)
    {
        [self AdConfigError];
        return;
    }
    [CartyTradPlusAdapter startWithAppID:appid];
    self.rewardedVideoAd = [[CTRewardedVideoAd alloc] init];
    self.rewardedVideoAd.placementid = pid;
    self.rewardedVideoAd.delegate = self;
    if(self.waterfallItem.serverSideUserID && self.waterfallItem.serverSideUserID.length > 0)
    {
        [CartyADSDK sharedInstance].userid = self.waterfallItem.serverSideUserID;
    }
    if(self.waterfallItem.serverSideCustomData && self.waterfallItem.serverSideCustomData.length > 0)
    {
        self.rewardedVideoAd.customRewardString = self.waterfallItem.serverSideCustomData;
    }
    NSDictionary *localParams= item.extraInfoDictionary[@"localParams"];
    if(localParams && [localParams valueForKey:@"Carty_isMute"])
    {
        self.rewardedVideoAd.isMute = [localParams[@"Carty_isMute"] boolValue];
    }
    [self.rewardedVideoAd loadAd];
}

- (BOOL)isReady
{
    return [self.rewardedVideoAd isReady];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController
{
    [self.rewardedVideoAd showAd:rootViewController];
}

- (void)CTRewardedVideoAdDidLoad:(nonnull CTRewardedVideoAd *)ad
{
    if(self.isC2SBidding)
    {
        NSString *ecpmStr = [NSString stringWithFormat:@"%lf",ad.ecpm];
        NSDictionary *dic = @{@"ecpm":ecpmStr,@"version":[CartyADSDK sdkVersion]};
        [self ADLoadExtraCallbackWithEvent:@"C2SBiddingFinish" info:dic];
    }
    else
    {
        [self AdLoadFinsh];
    }
}


- (void)CTRewardedVideoAdLoadFail:(nonnull CTRewardedVideoAd *)ad withError:(nonnull NSError *)error
{
    if(self.isC2SBidding)
    {
        NSString *errorStr = [NSString stringWithFormat:@"errCode: %@, errMsg: %@", @(error.code), error.localizedDescription];
        NSDictionary *dic = @{@"error":errorStr};
        [self ADLoadExtraCallbackWithEvent:@"C2SBiddingFail" info:dic];
    }
    else
    {
        [self AdLoadFailWithError:error];
    }
}

- (void)CTRewardedVideoAdDidShow:(nonnull CTRewardedVideoAd *)ad
{
    [self AdShow];
}

- (void)CTRewardedVideoAdShowFail:(nonnull CTRewardedVideoAd *)ad withError:(nonnull NSError *)error
{
    [self AdShowFailWithError:error];
}

- (void)CTRewardedVideoAdDidClick:(nonnull CTRewardedVideoAd *)ad
{
    [self AdClick];
}

- (void)CTRewardedVideoAdDidDismiss:(nonnull CTRewardedVideoAd *)ad
{
    [self AdClose];
}


- (void)CTRewardedVideoAdDidEarnReward:(nonnull CTRewardedVideoAd *)ad rewardInfo:(nonnull NSDictionary *)rewardInfo
{
    [self AdRewardedWithInfo:rewardInfo];
}

@end
