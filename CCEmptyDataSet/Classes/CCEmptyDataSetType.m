//
//  CCEmptyDataSetType.m
//  CCEmptyDataSet
//
//  Created by ash on 2020/8/27.
//

#import "CCEmptyDataSetType.h"
#import "CCEmptyDataSetView.h"
#import "CCEmptyDataMaskView.h"

@implementation CCEmptyDataSetTypeProvider

+ (BOOL)configureEmptyViewWithType:(EmptyDataSetType)type emptyView:(CCEmptyDataSetView *)emptyView {
    
    if (type < 0) {
        return NO;
    }
    
    NSArray<NSString *> *imageNames = @[@"cc_carts_", @"cc_orders_", @"cc_search_", @"cc_search_", @"cc_activity_", @"cc_coupons_"];
    NSArray<NSString *> *titles = @[@"购物车空空如也", @"您还没有相关订单", @"没有搜索到商品, 换个搜索词试试", @"网络开小差了, 请刷新重试", @"活动暂未开始，敬请期待", @"暂无优惠券"];
    
    NSAttributedString *titleLabelString = [[NSAttributedString alloc] initWithString:[titles objectAtIndex:type] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    
    UIImage *image = [UIImage cc_imageNamed:[imageNames objectAtIndex:type]];
    
    if (image) {
        if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
            emptyView.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else {
            // iOS 6 fallback: insert code to convert imaged if needed
            emptyView.imageView.image = image;
        }
    }
    emptyView.titleLabel.attributedText = titleLabelString;
    
    if (type == EmptyDataSetTypeCarts) {
        emptyView.buttonVerticalSpace = 40;
        [emptyView.button setTitle:@"去首页逛逛" forState:UIControlStateNormal];
        [emptyView.button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        [emptyView.button setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateHighlighted];
        emptyView.button.titleLabel.font = [UIFont systemFontOfSize:15];
        emptyView.button.layer.masksToBounds = YES;
        emptyView.button.layer.cornerRadius = 5.0;
        emptyView.button.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1].CGColor;
        emptyView.button.layer.borderWidth = 0.5;
        emptyView.button.frame = CGRectMake(0, 0, 200, 40);
        
    }else if (type == EmptyDataSetTypeSearchError) {
        emptyView.buttonVerticalSpace = 40;
        
        [emptyView.button setTitle:@"刷新" forState:UIControlStateNormal];
        [emptyView.button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        [emptyView.button setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateHighlighted];
        emptyView.button.titleLabel.font = [UIFont systemFontOfSize:15];
        emptyView.button.layer.masksToBounds = YES;
        emptyView.button.layer.cornerRadius = 5.0;
        emptyView.button.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1].CGColor;
        emptyView.button.layer.borderWidth = 0.5;
        emptyView.button.frame = CGRectMake(0, 0, 200, 40);
        
        UIImage *image = [UIImage cc_imageNamed:@"cc_refresh_button"];
        
        if (image) {
            [emptyView.button setImage:image forState:UIControlStateNormal];
            emptyView.button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        }
    }
    
    return YES;
}

@end
