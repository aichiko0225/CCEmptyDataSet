//
//  CCEmptyDataSetView.h
//  CCEmptyDataSet
//
//  Created by ash on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface CCEmptyDataSetView: UIView

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *detailLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIButton *button;

@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat verticalSpace;

/**
 When need custom constraints space - button to label
 */
@property (nonatomic, assign) CGFloat buttonVerticalSpace;

@property (nonatomic, assign) BOOL fadeInOnDisplay;

- (void)setupConstraints;
- (void)prepareForReuse;

@end

