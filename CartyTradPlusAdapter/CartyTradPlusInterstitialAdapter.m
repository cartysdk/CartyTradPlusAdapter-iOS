
#import "CartyTradPlusInterstitialAdapter.h"

@interface CartyTradPlusInterstitialAdapter()<CTInterstitialAdDelegate>

@property (nonatomic,strong)CTInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL isC2SBidding;
@property (nonatomic, assign) BOOL didWin;
@end

@implementation CartyTradPlusInterstitialAdapter

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
            NSError *loadError = [NSError errorWithDomain:@"ct" code:402 userInfo:@{NSLocalizedDescriptionKey : @"C2S interstitial not ready"}];
            [self AdLoadFailWithError:loadError];
        }
    }
    else if([event isEqualToString:@"C2SLoss"])
    {
        [self sendC2SLoss:config];
    }
    else
    {
        return NO;
    }
    return YES;
}

- (void)sendC2SLoss:(NSDictionary *)config
{
    if(self.didWin)
    {
        return;
    }
    NSString *topPirce = config[@"topPirce"];
    [self.interstitialAd bidLoss:topPirce];
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

- (void)CTInterstitialAdLoadFail:(nonnull CTInterstitialAd *)ad withError:(nonnull NSError *)error
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

- (void)CTInterstitialAdDidShow:(nonnull CTInterstitialAd *)ad
{
    if(self.isC2SBidding)
    {
        self.didWin = YES;
        [ad bidWin:self.waterfallItem.secondPirce];
    }
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
