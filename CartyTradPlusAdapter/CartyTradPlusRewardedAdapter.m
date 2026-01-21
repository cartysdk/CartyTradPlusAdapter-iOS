//
//  CartyTradPlusRewardedAdapter.m
//  CartyTradPlus
//
//  Created by GZTD-03-01959 on 2026/1/12.
//

#import "CartyTradPlusRewardedAdapter.h"

@interface CartyTradPlusRewardedAdapter()<CTRewardedVideoAdDelegate>

@property (nonatomic,strong)CTRewardedVideoAd *rewardedVideoAd;
@end

@implementation CartyTradPlusRewardedAdapter

- (void)loadAdWithWaterfallItem:(TradPlusAdWaterfallItem *)item
{
    NSString *appid = item.config[@"appid"];
    NSString *pid = item.config[@"pid"];
    if(appid == nil || pid == nil)
    {
        //配置错误
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
    [self AdLoadFinsh];
}


- (void)CTRewardedVideoAdLoadFail:(nonnull CTRewardedVideoAd *)ad withError:(nonnull NSError *)error
{
    [self AdLoadFailWithError:error];
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
