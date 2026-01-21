
#import <Foundation/Foundation.h>
#import <CartySDK/CartySDK.h>
#import <TradPlusAds/TradPlusAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface CartyTradPlusAdapter : NSObject

+ (void)setUserID:(NSString *)userID;
+ (void)startWithAppID:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
