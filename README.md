# CCEmptyDataSet

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CCEmptyDataSet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CCEmptyDataSet'
```

## Author

[ash](http://ashless.cc:3333/)
</br>
aichiko66@163.com

## License

CCEmptyDataSet is available under the MIT license. See the LICENSE file for more info.

### UIScrollView 的空视图展示

这个功能其实已经有一个很优秀的库了
[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)  

我重新优化了文件结构，加入了maskView的功能

新增两个代理方法

```objc

/**
return YES to display MaskView
*/
- (BOOL)showMaskViewForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

/**
 Provides 5 empty view display scenarios.
 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟
 * implementation delegate other EmptyDataSetSource will be invalid.
 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟
 */
- (EmptyDataSetType)showTypeForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

```

可以通过设置`EmptyDataSetType`来快速设置空视图的样式，设置`EmptyDataSetType`后`EmptyDataSetSource`的代理方法将会失效。

另外一个则是会在空视图上面默认加入一个`maskView`，重新获取`BOOL`的时机与空视图的时机一致。

### 使用方法

基础方法请参考[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)

快捷用法

```objc
@interface MainViewController : UITableViewController <CCEmptyDataSetSource, CCEmptyDataSetDelegate>

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}

- (EmptyDataSetType)showTypeForEmptyDataSet:(UIScrollView *)scrollView {
    return random()%5;
}

```

使用 showTypeForEmptyDataSet 返回方法可以快速定义emptyView

```objc
@interface MainViewController : UITableViewController <CCEmptyDataSetSource, CCEmptyDataSetDelegate>
{
    CCEmptyDataSetManager *_emptyManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _emptyManager = [CCEmptyDataSetManager emptyDataSetWithImage:nil title:@"11111" message:@"22222" buttonTitle:@"333333"];
    
    self.tableView.emptyDataSetSource = _emptyManager;
    self.tableView.emptyDataSetDelegate = _emptyManager;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}

```

也可以新增一个Manager类来快速定义EmptyView的属性
Manager类可以使用 Appearance 方法全局设置部分属性
具体代码可以查看demo工程中的实现

### 基础用法

### Import

```objc
#import "UIScrollView+EmptyDataSet.h"
```

Unless you are importing as a framework, then do:

```objc
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
```

### Protocol Conformance

Conform to datasource and/or delegate.

```objc
@interface MainViewController : UITableViewController <CCEmptyDataSetSource, CCEmptyDataSetDelegate>

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}
```

### Data Source Implementation

Return the content you want to show on the empty state, and take advantage of NSAttributedString features to customise the text appearance.

The image for the empty state:

```objc
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_placeholder"];
}
```

The attributed string for the title of the empty state:

```objc
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Please Allow Photo Access";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
```

The attributed string for the description of the empty state:

```objc
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"This allows you to share photos from your library and save photos to your camera roll.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];                      
}
```

The attributed string to be used for the specified button state:

```objc
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]};

    return [[NSAttributedString alloc] initWithString:@"Continue" attributes:attributes];
}
```

or the image to be used for the specified button state:

```objc
- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    return [UIImage imageNamed:@"button_image"];
}
```

The background color for the empty state:

```objc
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}
```

If you need a more complex layout, you can return a custom view instead:

```objc
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    return activityView;
}
```

The image view animation

```objc
- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
    
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}
```

Additionally, you can also adjust the vertical alignment of the content view (ie: useful when there is tableHeaderView visible):

```objc
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -self.tableView.tableHeaderView.frame.size.height/2.0f;
}
```

Finally, you can separate components from each other (default separation is 11 pts):

```objc
- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 20.0f;
}
```

