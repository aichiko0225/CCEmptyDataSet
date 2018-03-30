//
//  CCEmptyDataMaskView.h
//  CCEmptyDataSet
//
//  Created by ash on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface UIImage (CCNamed)

+ (nullable UIImage *)cc_imageNamed:(nullable NSString *)name;

@end

@class CCEmptyDataMaskView;
@protocol CCEmptyDataMaskViewDelegate <NSObject>

- (void)CCEmptyDataMaskViewStartAnimation:(CCEmptyDataMaskView * _Nonnull)maskView;

- (void)CCEmptyDataMaskViewStopAnimation:(CCEmptyDataMaskView * _Nonnull)maskView;

@end

@interface CCEmptyDataMaskView : UIView


/**
 animation stop hide imageView
 defualt YES
 */
@property (nonatomic, assign) BOOL HideOnStop;

/**
 animation clockwise rotation
 defualt YES
 */
@property (nonatomic, assign) BOOL clockwise;

@property (nonatomic, weak) _Nullable id <CCEmptyDataMaskViewDelegate> delegate;

@end
