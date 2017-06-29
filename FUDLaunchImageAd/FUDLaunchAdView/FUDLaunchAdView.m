//
//  FUDLaunchAdView.m
//  FUDLaunchImageAd
//
//  Created by fudo on 2017/6/29.
//  Copyright © 2017年 fudo. All rights reserved.
//

#import "FUDLaunchAdView.h"
#import "UIImageView+WebCache.h"

#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)

@interface FUDLaunchAdView ()

@property (nonatomic, strong) NSTimer *countTimer;

@end

@implementation FUDLaunchAdView

- (instancetype)initWithImageUrl:(NSString *)imgUrl {
    if (self = [super init]) {
        [self setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:imgUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            self.adImageView.image = image;
        }];
    }
    
    return self;
}

- (void)showWithDuration:(NSInteger)duration completeBlock:(void(^)())block {
    
    self.adDuration = duration;
    self.completeBlock = block;
    
    [self addSubview:self.adImageView];
    [self addSubview:self.skipButton];
    
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadImageWithURL:[NSURL URLWithString:self.imgUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        self.adImageView.image = image;
//    }];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window makeKeyAndVisible];
    [window addSubview:self];
    
    __weak typeof(self)weakself = self;
    
    [self startAnimation];
    
    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakself.adDuration < 0) {
            [weakself onHitSkipButton:weakself.skipButton];
        } else {
            [weakself.skipButton setTitle:[NSString stringWithFormat:@"跳过 %ld", (long)weakself.adDuration--] forState:UIControlStateNormal];
        }
    }];
}

- (void)invalidateTimer {
    if ([self.countTimer isValid]) {
        [self.countTimer invalidate];
        self.countTimer = nil;
    }
}

- (void)startAnimation {
    [UIView animateWithDuration:self.adDuration-1 animations:^{
        self.adImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

- (UIButton *)skipButton {
    if (_skipButton == nil) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.backgroundColor = [UIColor grayColor];
        [_skipButton setFrame:CGRectMake(screenWidth-20-50, 20, 50, 30)];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_skipButton.bounds cornerRadius:_skipButton.bounds.size.height/2];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = _skipButton.bounds;
        layer.path = path.CGPath;
        _skipButton.layer.mask = layer;
        
        [_skipButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_skipButton addTarget:self action:@selector(onHitSkipButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _skipButton;
}

- (void)onHitSkipButton:(UIButton *)sender {
    [self invalidateTimer];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.adImageView setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.completeBlock();
    }];
}

- (UIImageView *)adImageView {
    if (_adImageView == nil) {
        _adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        CGSize viewSize = CGSizeMake(screenWidth, screenHeight);
        NSString *viewOrientation = @"Portrait";
        NSArray *launchImages = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UILaunchImages"];
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        __block NSString *imageName = nil;
        [launchImages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGSize imageSize = CGSizeFromString(obj[@"UILaunchImageSize"]);
            if (CGSizeEqualToSize(viewSize, imageSize) && [viewOrientation isEqualToString:obj[@"UILaunchImageOrientation"]]) {
                imageName = obj[@"UILaunchImageName"];
            }
        }];
        
        _adImageView.image = [UIImage imageNamed:imageName];
    }
    
    return _adImageView;
}

- (void)dealloc {
    [self invalidateTimer];
    
    NSLog(@"%@, %s", [self class], __FUNCTION__);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
