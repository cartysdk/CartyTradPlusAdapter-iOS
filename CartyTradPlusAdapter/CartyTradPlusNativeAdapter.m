//
//  CartyTradPlusNativeAdapter.m
//  CartyTradPlus
//
//  Created by GZTD-03-01959 on 2026/1/12.
//

#import "CartyTradPlusNativeAdapter.h"

@interface CartyTradPlusNativeAdapter()<CTNativeAdDelegate>

@property (nonatomic,strong)CTNativeAd *nativeAd;
@end

@implementation CartyTradPlusNativeAdapter

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

- (void)CTNativeAdDidLoad:(nonnull CTNativeAd *)ad
{
    TradPlusAdRes *res = [[TradPlusAdRes alloc] init];
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
    self.waterfallItem.adRes = res;
    [self AdLoadFinsh];
}

- (void)CTNativeAdLoadFail:(nonnull CTNativeAd *)ad withError:(nonnull NSError *)error
{
    [self AdLoadFailWithError:error];
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
