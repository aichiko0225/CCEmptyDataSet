//
//  CCEmptyDataMaskView.m
//  CCEmptyDataSet
//
//  Created by ash on 2018/3/23.
//

#import "CCEmptyDataMaskView.h"



@implementation UIImage (CCNamed)

+ (nullable UIImage *)cc_imageNamed:(NSString *)name {
    static NSBundle *bundle = nil;
    Class class = NSClassFromString(@"CCEmptyDataSet");
    if (class == nil) {
        bundle = [NSBundle mainBundle];
    }else {
        bundle = [NSBundle bundleForClass:class];
    }
    NSString *bundlePath = [bundle.resourcePath stringByAppendingString:@"/Frameworks/CCEmptyDataSet.framework/CCEmptyDataSet.bundle"];
    NSBundle *bundle1 = [NSBundle bundleWithPath:bundlePath];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle1 compatibleWithTraitCollection:nil];
    
    if (image == nil) {
        NSString *bundlePath = [bundle.resourcePath stringByAppendingString:@"/CCEmptyDataSet.bundle"];
        NSBundle *bundle1 = [NSBundle bundleWithPath:bundlePath];
        image = [UIImage imageNamed:name inBundle:bundle1 compatibleWithTraitCollection:nil];
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    
    return image;
}

@end

// static float animationDuration = 1.0f;

@interface CCEmptyDataMaskView ()<CAAnimationDelegate>

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong, readonly) UIImageView *centerImageView;
@property (nonatomic, strong, readonly) UIImageView *animateImageView;

- (void)startAnimation;

@end

@implementation CCEmptyDataMaskView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    if (_activityIndicatorView) {
        self.activityIndicatorView.center = self.center;
    }

    if (_centerImageView && _animateImageView) {
        _centerImageView.center = self.center;
        _animateImageView.center = self.center;
    }
    
    [self startAnimation];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        _HideOnStop = YES;
        _clockwise = YES;
        
        UIImage *animateImage = [UIImage cc_imageNamed:@"cc_loadingShadow"];
        UIImage *centerImage = [UIImage cc_imageNamed:@"cc_loading2_00"];
        
        if (centerImage && animateImage) {
            
            _animateImageView = [[UIImageView alloc] initWithImage:animateImage];
            _centerImageView = [[UIImageView alloc] initWithImage:centerImage];
            
        }else {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            _activityIndicatorView.color = [UIColor colorWithRed:248/255.0 green:110/255.0 blue:80/255.0 alpha:1];
            [self addSubview:_activityIndicatorView];
            _activityIndicatorView.hidesWhenStopped = YES;
            [_activityIndicatorView startAnimating];
        }
        [self addSubview:_animateImageView];
        [self addSubview:_centerImageView];
        CGFloat scrollScale = ([UIScreen mainScreen].bounds.size.width)/375.0;
        CGSize size1 = CGSizeMake(60*scrollScale, 60*scrollScale);
        _animateImageView.frame = CGRectMake(0, 0, size1.width, size1.height);
        _centerImageView.frame = CGRectMake(0, 0, size1.width * 0.8, size1.height * 0.8);
        if (_centerImageView) {
            _centerImageView.center = self.center;
            _animateImageView.center = self.center;
        }
    }
    return self;
}

- (NSArray<UIImage *> *)loadingImageList {
    NSMutableArray<UIImage *> *arrayM = [NSMutableArray array];
    for (int i = 0; i <= 53; i++) {
        UIImage *image = [UIImage cc_imageNamed:[NSString stringWithFormat:@"cc_loading2_%02d",i]];
        if (image) {
            [arrayM addObject:image];
        }
    }
    return arrayM;
}

- (void)startAnimation {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    NSArray<UIImage *> *arrayM = [self loadingImageList];
    NSMutableArray *contents = [NSMutableArray array];
    for(NSUInteger i = 0; i < arrayM.count; i++) {
        UIImage *img = arrayM[i];
        CGImageRef cgimg = img.CGImage;
        [contents addObject:(__bridge UIImage *)cgimg];
    }
    animation.values = contents;
    animation.duration = arrayM.count/50 * 1.6;
    animation.repeatCount = MAXFLOAT;
    animation.delegate = self;
    [_centerImageView.layer addAnimation:animation forKey:@"loadingImageList"];
    
    /*
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:_clockwise ? 0: 2*M_PI];
    animation.toValue = [NSNumber numberWithFloat: _clockwise ? 2.0* M_PI: 0];
    animation.duration = animationDuration;
    animation.repeatCount = ULLONG_MAX;
    animation.delegate = self;
    [_animateImageView.layer addAnimation:animation forKey:@"rotationAnimation"];
     */
}

- (void)animationDidStart:(CAAnimation *)anim {
    if (_delegate && [self.delegate respondsToSelector:@selector(CCEmptyDataMaskViewStartAnimation:)]) {
        [self.delegate CCEmptyDataMaskViewStartAnimation:self];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_delegate && [self.delegate respondsToSelector:@selector(CCEmptyDataMaskViewStopAnimation:)]) {
        [self.delegate CCEmptyDataMaskViewStopAnimation:self];
    }
    if (_HideOnStop) {
        _centerImageView.hidden = YES;
        _animateImageView.hidden = YES;
    }
}

@end
