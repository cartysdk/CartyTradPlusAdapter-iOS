
#import "CartyTradPlusBannerAdapter.h"

@interface CartyTradPlusBannerAdapter()<CTBannerAdDelegate>

@property (nonatomic,strong)CTBannerAd *bannerAd;
@property (nonatomic, assign) BOOL isC2SBidding;
@end

@implementation CartyTradPlusBannerAdapter

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
            NSError *loadError = [NSError errorWithDomain:@"ct" code:402 userInfo:@{NSLocalizedDescriptionKey : @"C2S banner not ready"}];
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
    self.bannerAd = [[CTBannerAd alloc] init];
    self.bannerAd.placementid = pid;
    self.bannerAd.delegate = self;
    NSString *bannerSize = item.config[@"bannerSize"];
    if([bannerSize isKindOfClass:[NSString class]])
    {
        if([bannerSize isEqualToString:@"320x50"])
        {
            self.bannerAd.bannerSize = CTBannerSizeType320x50;
            self.bannerAd.frame = CGRectMake(0, 0, 320, 50);
        }
        else if([bannerSize isEqualToString:@"320x100"])
        {
            self.bannerAd.bannerSize = CTBannerSizeType320x100;
            self.bannerAd.frame = CGRectMake(0, 0, 320, 100);
        }
        else if([bannerSize isEqualToString:@"300x250"])
        {
            self.bannerAd.bannerSize = CTBannerSizeType300x250;
            self.bannerAd.frame = CGRectMake(0, 0, 300, 250);
        }
    }
    NSDictionary *localParams= item.extraInfoDictionary[@"localParams"];
    if(localParams)
    {
        if([localParams valueForKey:@"Carty_isMute"])
        {
            self.bannerAd.isMute = [localParams[@"Carty_isMute"] boolValue];
        }
        if([localParams valueForKey:@"Carty_BannerSize"])
        {
            NSString *bannerSize = localParams[@"Carty_BannerSize"];
            if([bannerSize isKindOfClass:[NSString class]])
            {
                if([bannerSize isEqualToString:@"320x50"])
                {
                    self.bannerAd.bannerSize = CTBannerSizeType320x50;
                    self.bannerAd.frame = CGRectMake(0, 0, 320, 50);
                }
                else if([bannerSize isEqualToString:@"320x100"])
                {
                    self.bannerAd.bannerSize = CTBannerSizeType320x100;
                    self.bannerAd.frame = CGRectMake(0, 0, 320, 100);
                }
                else if([bannerSize isEqualToString:@"300x250"])
                {
                    self.bannerAd.bannerSize = CTBannerSizeType300x250;
                    self.bannerAd.frame = CGRectMake(0, 0, 300, 250);
                }
            }
        }
    }
    [self.bannerAd loadAd];
}

- (BOOL)isReady
{
    return (self.bannerAd != nil);
}

- (void)bannerDidAddSubView:(UIView *)subView
{
    if(self.bannerAd.frame.size.width == 0 || self.bannerAd.frame.size.height == 0)
    {
        self.bannerAd.frame = subView.bounds;
    }
    else
    {
        [self setBannerCenterWithBanner:self.bannerAd subView:subView];
    }
}

- (id)getCustomObject
{
    return self.bannerAd;
}

- (void)CTBannerAdDidLoad:(nonnull CTBannerAd *)ad
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

- (void)CTBannerAdLoadFail:(nonnull CTBannerAd *)ad withError:(nonnull NSError *)error
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

- (void)CTBannerAdDidShow:(nonnull CTBannerAd *)ad
{
    [self AdShow];
}

- (void)CTBannerAdShowFail:(nonnull CTBannerAd *)ad withError:(nonnull NSError *)error
{
    [self AdShowFailWithError:error];
}

- (void)CTBannerAdDidClick:(nonnull CTBannerAd *)ad
{
    [self AdClick];
}

- (void)CTBannerAdDidClose:(nonnull CTBannerAd *)ad
{
    [self AdClose];
}

@end
