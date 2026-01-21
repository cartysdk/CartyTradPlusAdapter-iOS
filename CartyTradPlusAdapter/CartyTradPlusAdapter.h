//
//  CartyTradPlusAdapter.h
//  CartyTradPlus
//
//  Created by GZTD-03-01959 on 2026/1/12.
//

#import <Foundation/Foundation.h>
#import <CartySDK/CartySDK.h>
#import <TradPlusAds/TradPlusAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface CartyTradPlusAdapter : NSObject

+ (void)setUserID:(NSString *)userID;
+ (void)startWithAppID:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
