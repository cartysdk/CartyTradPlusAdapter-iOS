
#import "CartyTradPlusNativeAdapter.h"

@interface CartyTradPlusNativeAdapter()<CTNativeAdDelegate>

@property (nonatomic,strong)CTNativeAd *nativeAd;
@property (nonatomic, assign) BOOL isC2SBidding;
@end

@implementation CartyTradPlusNativeAdapter

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
            [self nativeAdLoadFinish];
        }
        else
        {
            NSError *loadError = [NSError errorWithDomain:@"ct" code:402 userInfo:@{NSLocalizedDescriptionKey : @"C2S native not ready"}];
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
    self.nativeAd = [[CTNativeAd alloc] init];
    self.nativeAd.placementid = pid;
    self.nativeAd.delegate = self;
    NSDictionary *localParams= item.extraInfoDictionary[@"localParams"];
    if(localParams && [localParams valueForKey:@"Carty_isMute"])
    {
        self.nativeAd.isMute = [localParams[@"Carty_isMute"] boolValue];
    }
    [self.nativeAd loadAd];
}

- (BOOL)isReady
{
    return [self.nativeAd isReady];
}

- (UIView *)endRender:(NSDictionary *)viewInfo clickView:(NSArray *)array;
{
    UIView *adView = viewInfo[kTPRendererAdView];
    [self.nativeAd registerContainer:adView withClickableViews:array];
    return nil;
}

- (void)templateRender:(UIView *)subView
{
    self.nativeAd.templateView.frame = subView.bounds;
    [self.nativeAd registerContainer:self.nativeAd.templateView withClickableViews:nil];
}

- (void)nativeAdLoadFinish
{
    TradPlusAdRes *res = [[TradPlusAdRes alloc] init];
    if(self.nativeAd.isTemplate)
    {
        res.adView = self.nativeAd.templateView;
    }
    else
    {
        res.title = self.nativeAd.title;
        res.body = self.nativeAd.desc;
        res.ctaText = self.nativeAd.ctaText;
        res.mediaView = self.nativeAd.mediaView;
        res.iconImageURL = self.nativeAd.iconImageURL;
        res.adChoiceView = self.nativeAd.adChoiceView;
        res.sponsored = self.nativeAd.sponsored;
        res.likes = self.nativeAd.likes;
        if(self.nativeAd.rating != nil)
        {
            res.rating = @([self.nativeAd.rating floatValue]);
        }
    }
    self.waterfallItem.adRes = res;
    [self AdLoadFinsh];
}

- (void)CTNativeAdDidLoad:(nonnull CTNativeAd *)ad
{
    if(self.isC2SBidding)
    {
        NSString *ecpmStr = [NSString stringWithFormat:@"%lf",ad.ecpm];
        NSDictionary *dic = @{@"ecpm":ecpmStr,@"version":[CartyADSDK sdkVersion]};
        [self ADLoadExtraCallbackWithEvent:@"C2SBiddingFinish" info:dic];
    }
    else
    {
        [self nativeAdLoadFinish];
    }
}

- (void)CTNativeAdLoadFail:(nonnull CTNativeAd *)ad withError:(nonnull NSError *)error
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

- (void)CTNativeAdDidShow:(nonnull CTNativeAd *)ad
{
    [self AdShow];
}

- (void)CTNativeAdShowFail:(nonnull CTNativeAd *)ad withError:(nonnull NSError *)error
{
    [self AdShowFailWithError:error];
}

- (void)CTNativeAdDidClick:(nonnull CTNativeAd *)ad
{
    [self AdClick];
}

@end
