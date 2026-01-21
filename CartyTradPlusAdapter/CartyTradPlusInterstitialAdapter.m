//
//  CartyTradPlusInterstitialAdapter.m
//  CartyTradPlus
//
//  Created by GZTD-03-01959 on 2026/1/12.
//

#import "CartyTradPlusInterstitialAdapter.h"

@interface CartyTradPlusInterstitialAdapter()<CTInterstitialAdDelegate>

@property (nonatomic,strong)CTInterstitialAd *interstitialAd;
@end

@implementation CartyTradPlusInterstitialAdapter

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
    self.interstitialAd = [[CTInterstitialAd alloc] init];
    self.interstitialAd.placementid = pid;
    self.interstitialAd.delegate = self;
    NSDictionary *localParams= item.extraInfoDictionary[@"localParams"];
    if(localParams && [localParams valueForKey:@"Carty_isMute"])
    {
        self.interstitialAd.isMute = [localParams[@"Carty_isMute"] boolValue];
    }
    [self.interstitialAd loadAd];
}

- (BOOL)isReady
{
    return [self.interstitialAd isReady];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitialAd showAd:rootViewController];
}

- (void)CTInterstitialAdDidLoad:(nonnull CTInterstitialAd *)ad
{
    [self AdLoadFinsh];
}

- (void)CTInterstitialAdLoadFail:(nonnull CTInterstitialAd *)ad withError:(nonnull NSError *)error
{
    [self AdLoadFailWithError:error];
}

- (void)CTInterstitialAdDidShow:(nonnull CTInterstitialAd *)ad
{
    [self AdShow];
}

- (void)CTInterstitialAdShowFail:(nonnull CTInterstitialAd *)ad withError:(nonnull NSError *)error
{
    [self AdShowFailWithError:error];
}

- (void)CTInterstitialAdDidClick:(nonnull CTInterstitialAd *)ad
{
    [self AdClick];
}

- (void)CTInterstitialAdDidDismiss:(nonnull CTInterstitialAd *)ad
{
    [self AdClose];
}
@end
