//
//  FUDLaunchAdView.h
//  FUDLaunchImageAd
//
//  Created by fudo on 2017/6/29.
//  Copyright © 2017年 fudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FUDLaunchAdView : UIView

@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) UIButton    *skipButton;
@property (nonatomic, assign) NSInteger    adDuration;
@property (nonatomic, copy)   NSString    *imgUrl;
@property (nonatomic, copy)   void(^completeBlock)();

- (instancetype)initWithImageUrl:(NSString *)imgUrl;
- (void)showWithDuration:(NSInteger)duration completeBlock:(void(^)())block;

@end
