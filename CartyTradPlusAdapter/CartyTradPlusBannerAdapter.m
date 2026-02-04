
#import "CartyTradPlusBannerAdapter.h"

@interface CartyTradPlusBannerAdapter()<CTBannerAdDelegate>

@property (nonatomic,strong)CTBannerAd *bannerAd;
@end

@implementation CartyTradPlusBannerAdapter

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
        }
        else if([bannerSize isEqualToString:@"320x100"])
        {
            self.bannerAd.bannerSize = CTBannerSizeType320x100;
        }
        else if([bannerSize isEqualToString:@"300x250"])
        {
            self.bannerAd.bannerSize = CTBannerSizeType300x250;
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
            NSString *bannerSize = item.config[@"Carty_BannerSize"];
            if([bannerSize isEqualToString:@"320x50"])
            {
                self.bannerAd.bannerSize = CTBannerSizeType320x50;
            }
            else if([bannerSize isEqualToString:@"320x100"])
            {
                self.bannerAd.bannerSize = CTBannerSizeType320x100;
            }
            else if([bannerSize isEqualToString:@"300x250"])
            {
                self.bannerAd.bannerSize = CTBannerSizeType300x250;
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
    [self AdLoadFinsh];
}

- (void)CTBannerAdLoadFail:(nonnull CTBannerAd *)ad withError:(nonnull NSError *)error
{
    [self AdLoadFailWithError:error];
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
