//
//  CartyTradPlusAppOpenAdapter.m
//  CartyTradPlus
//
//  Created by GZTD-03-01959 on 2026/1/12.
//

#import "CartyTradPlusAppOpenAdapter.h"

@interface CartyTradPlusAppOpenAdapter()<CTAppOpenAdDelegate>

@property (nonatomic,strong)CTAppOpenAd *appOpenAd;
@end

@implementation CartyTradPlusAppOpenAdapter

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
    self.appOpenAd = [[CTAppOpenAd alloc] init];
    self.appOpenAd.placementid = pid;
    self.appOpenAd.delegate = self;
    NSDictionary *localParams= item.extraInfoDictionary[@"localParams"];
    if(localParams && [localParams valueForKey:@"Carty_isMute"])
    {
        self.appOpenAd.isMute = [localParams[@"Carty_isMute"] boolValue];
    }
    [self.appOpenAd loadAd];
}

- (BOOL)isReady
{
    return [self.appOpenAd isReady];
}

- (void)showAdInWindow:(UIWindow *)window bottomView:(UIView *)bottomView
{
    [self.appOpenAd showAd:window.rootViewController];
}

- (void)CTOpenAdDidLoad:(nonnull CTAppOpenAd *)ad
{
    [self AdLoadFinsh];
}

- (void)CTOpenAdLoadFail:(nonnull CTAppOpenAd *)ad withError:(nonnull NSError *)error
{
    [self AdLoadFailWithError:error];
}

- (void)CTOpenAdDidShow:(nonnull CTAppOpenAd *)ad
{
    [self AdShow];
}

- (void)CTOpenAdShowFail:(nonnull CTAppOpenAd *)ad withError:(nonnull NSError *)error
{
    [self AdShowFailWithError:error];
}

- (void)CTOpenAdDidClick:(nonnull CTAppOpenAd *)ad
{
    [self AdClick];
}

- (void)CTOpenAdDidDismiss:(nonnull CTAppOpenAd *)ad
{
    [self AdClose];
}

@end
