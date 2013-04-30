//
//  HKRefreshControl.m
//  HKRefreshControl
//
//  Copyright (c) 2013, Panos Baroudjian.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "HKRefreshControl.h"
#import <QuartzCore/QuartzCore.h>
#import <HKCircularProgressView.h>

static CGFloat const kHKAdditionalTopInset = 70.;
static CGFloat const kHKRefreshThreshold = 115.;

typedef NS_ENUM(NSUInteger, HKRefreshControlState)
{
    HKRefreshControlStateDefault = 0,
    HKRefreshControlStateRefreshing,
    HKRefreshControlStateDone,

    HKRefreshControlStateMax
};

@interface HKCircularProgressRefreshView : HKCircularProgressView<HKRefreshControlPullView, HKRefreshControlIndicatorView>


@end

@implementation HKCircularProgressRefreshView

- (id)init
{
    self = [super init];
    if (self)
    {
        self.startAngle = M_PI_2;
        self.fillRadius = .5;
        self.endPoint = [[HKCircularProgressEndPointSpike alloc] init];
    }

    return self;
}

- (void)refreshControl:(HKRefreshControl *)refreshControl
         updatedOffset:(CGFloat)offset
         withThreshold:(CGFloat)max
{
    [self setStartAngle:(offset / max) * M_PI];
    [self setMax:max animated:NO];
    [self setCurrent:offset animated:NO];
}

- (void)startAnimating
{
    [self setCurrent:.3 animated:NO];
    [super startAnimating];
}

- (void)setTintColor:(UIColor *)color
{
    self.progressTintColor = color;
}

@end

@interface HKRefreshControl ()

+ (void)addShadowToView:(UIView *)view;
- (void)lockViewOnTop;
- (void)unlockViewOnTop;
- (void)alwaysOnTop;

@property (nonatomic) CGFloat offset;
@property (nonatomic) HKRefreshControlState refreshState;
@property (nonatomic) BOOL isLockedOnTop;
@property (nonatomic) UILabel *textLabel;

@end

@implementation HKRefreshControl
@synthesize pullView = _pullView;
@synthesize indicatorView = _indicatorView;
@synthesize tintColor = _tintColor;
@synthesize textLabel = _textLabel;

+ (void)addShadowToView:(UIView *)view
{
    [[view layer] setShadowOffset:CGSizeMake(0, 1)];
    [[view  layer] setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [[view  layer] setShadowRadius:.5];
    [[view  layer] setShadowOpacity:0.75f];
}

- (void)setPullView:(UIView<HKRefreshControlPullView> *)pullView
{
    if (_pullView == pullView)
        return;

    if (_pullView)
    {
        [_pullView removeFromSuperview];
    }

    _pullView = pullView;

    [HKRefreshControl addShadowToView:pullView];
    [pullView setTintColor:self.tintColor];
    [self addSubview:pullView];
}

- (UIView<HKRefreshControlPullView> *)pullView
{
    if (!_pullView)
    {
        self.pullView = [[HKCircularProgressRefreshView alloc] init];
    }

    return _pullView;
}

- (void)setIndicatorView:(UIView<HKRefreshControlIndicatorView> *)indicatorView
{
    if (_indicatorView == indicatorView)
        return;

    if (_indicatorView)
    {
        [_indicatorView removeFromSuperview];
    }

    _indicatorView = indicatorView;
    [HKRefreshControl addShadowToView:indicatorView];
    [indicatorView setTintColor:self.tintColor];
    [self addSubview:indicatorView];
}

- (UIView<HKRefreshControlIndicatorView> *)indicatorView
{
    if (!_indicatorView)
    {
        self.indicatorView = [[HKCircularProgressRefreshView alloc] init];
    }

    return _indicatorView;
}

- (UILabel *)textLabel
{
    if (!_textLabel)
    {
        self.textLabel = [[UILabel alloc] init];
    }

    return _textLabel;
}

- (void)setTextLabel:(UILabel *)textLabel
{
    if (_textLabel == textLabel)
        return;

    if (_textLabel)
    {
        [_textLabel removeFromSuperview];
    }
    
    _textLabel = textLabel;
    textLabel.font = [UIFont boldSystemFontOfSize:12];
    textLabel.textColor = self.tintColor;
    textLabel.text = self.attributedTitle.string;
    [self addSubview:textLabel];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    if ([_attributedTitle isEqualToAttributedString:attributedTitle])
        return;

    _attributedTitle = [attributedTitle copy];
    self.textLabel.attributedText = attributedTitle;
    
    [self setNeedsLayout];
}

- (BOOL)refreshing
{
    return self.refreshState == HKRefreshControlStateRefreshing;
}

- (UIColor *)tintColor
{
    if (!_tintColor)
        _tintColor = [UIColor lightGrayColor];

    return _tintColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if ([tintColor isEqual:_tintColor])
        return;

    _tintColor = tintColor;
    [self.indicatorView setTintColor:tintColor];
    [self.pullView setTintColor:tintColor];
    [self.textLabel setTextColor:tintColor];
}

- (void)layoutSubviews
{
    CGFloat width = self.frame.size.width;
    self.indicatorView.frame = CGRectMake(width * .5 - 15., 10., 30., 30.);
    self.pullView.frame = self.indicatorView.frame;
    CGSize size = [self.textLabel sizeThatFits:CGSizeZero];
    self.textLabel.frame = (CGRect)
    {
        .origin = { width * .5 - size.width * .5, self.pullView.frame.origin.y + self.pullView.frame.size.height + 3},
        .size = size
    };
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        [self.superview removeObserver:self
                            forKeyPath:@"contentOffset"];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        [self.superview addObserver:self
                         forKeyPath:@"contentOffset"
                            options:0
                            context:NULL];
        self.frame = CGRectMake(0, -kHKAdditionalTopInset,
                                self.superview.frame.size.width,
                                kHKAdditionalTopInset);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setNeedsLayout];
    }
}

- (void)lockViewOnTop
{
    self.isLockedOnTop = YES;
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top += kHKAdditionalTopInset;

    [UIView animateWithDuration:.3
                     animations:^{
                         scrollView.contentInset = inset;
                     }];
}

- (void)unlockViewOnTop
{
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top -= kHKAdditionalTopInset;

    __weak HKRefreshControl *weakSelf = self;
    [UIView animateWithDuration:.3
                     animations:^{
                         scrollView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         weakSelf.isLockedOnTop = NO;
                         UIEdgeInsets contentInset = ((UIScrollView *)self.superview).contentInset;
                         if (weakSelf.offset <= contentInset.top)
                         {
                             weakSelf.refreshState = HKRefreshControlStateDefault;
                         }
                         else
                         {
                             weakSelf.refreshState = HKRefreshControlStateDone;
                         }
                     }];
}

- (void)alwaysOnTop
{
    CGFloat y = MIN(self.offset, -kHKAdditionalTopInset);
    self.frame = (CGRect)
    {
        .origin = { .0, y },
        .size = self.frame.size
    };
}

- (void)beginRefreshing
{
    self.refreshState = HKRefreshControlStateRefreshing;
}

- (void)endRefreshing
{
    if (self.refreshState != HKRefreshControlStateRefreshing)
        return;

    [self.indicatorView stopAnimating];

    if (self.isLockedOnTop)
    {
        [self unlockViewOnTop];
    }
    else
    {
        self.refreshState = HKRefreshControlStateDone;
    }
}

- (void)setRefreshState:(HKRefreshControlState)refreshState
{
    if (_refreshState == refreshState)
        return;

    _refreshState = refreshState;
    switch (refreshState)
    {
        case HKRefreshControlStateDefault:
            self.pullView.hidden = NO;
            self.indicatorView.hidden = YES;
            break;
        case HKRefreshControlStateRefreshing:
            self.pullView.hidden = YES;
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            break;
        case HKRefreshControlStateDone:
            break;
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != self.superview || ![keyPath isEqualToString:@"contentOffset"])
        return;

    UIScrollView *scrollView = (UIScrollView *)self.superview;
    self.offset = scrollView.contentOffset.y;
    CGPoint pullCenter = self.pullView.center;
    [self.pullView refreshControl:self
                    updatedOffset:-self.offset - pullCenter.y
                    withThreshold:kHKRefreshThreshold - pullCenter.y];
    [self alwaysOnTop];

    switch (self.refreshState)
    {
        case HKRefreshControlStateDefault:
        {
            if (self.offset <= -kHKRefreshThreshold && scrollView.isTracking)
            {
                self.refreshState = HKRefreshControlStateRefreshing;
            }
        }
        break;
        case HKRefreshControlStateRefreshing:
        {
            if (!scrollView.isDragging && !self.isLockedOnTop)
            {
                [self lockViewOnTop];
            }
        }
        break;
        case HKRefreshControlStateDone:
        {
            if (self.offset >= scrollView.contentInset.top)
            {
                self.refreshState = HKRefreshControlStateDefault;
            }
        }
        break;
        default:
            break;
    }
}

@end
