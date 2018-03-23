//
//  CCEmptyDataMaskView.m
//  AFNetworking
//
//  Created by ash on 2018/3/23.
//

#import "CCEmptyDataMaskView.h"

@interface CCEmptyDataMaskView ()

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CCEmptyDataMaskView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.activityIndicatorView.center = self.center;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.color = [UIColor colorWithRed:248/255.0 green:110/255.0 blue:80/255.0 alpha:1];
        [self addSubview:_activityIndicatorView];
        _activityIndicatorView.hidesWhenStopped = YES;
        [_activityIndicatorView startAnimating];
    }
    return self;
}

@end
