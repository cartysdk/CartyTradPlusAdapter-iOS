
#import "CartyTradPlusAppOpenAdapter.h"

@interface CartyTradPlusAppOpenAdapter()<CTAppOpenAdDelegate>

@property (nonatomic,strong)CTAppOpenAd *appOpenAd;
@property (nonatomic, assign) BOOL isC2SBidding;
@property (nonatomic, assign) BOOL didWin;
@end

@implementation CartyTradPlusAppOpenAdapter

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
            NSError *loadError = [NSError errorWithDomain:@"ct" code:402 userInfo:@{NSLocalizedDescriptionKey : @"C2S app open not ready"}];
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
    [self.appOpenAd bidLoss:topPirce];
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

- (void)CTOpenAdLoadFail:(nonnull CTAppOpenAd *)ad withError:(nonnull NSError *)error
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

- (void)CTOpenAdDidShow:(nonnull CTAppOpenAd *)ad
{
    if(self.isC2SBidding)
    {
        self.didWin = YES;
        [ad bidWin:self.waterfallItem.secondPirce];
    }
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
