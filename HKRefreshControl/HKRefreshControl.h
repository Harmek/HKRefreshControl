//
//  HKRefreshControl.h
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

#import <UIKit/UIKit.h>
#import "UITableViewController+RefreshControl.h"

@class HKRefreshControl;

@protocol HKRefreshControlPullView <NSObject>

- (void)refreshControl:(HKRefreshControl *)refreshControl
         updatedOffset:(CGFloat)offset
         withThreshold:(CGFloat)max;

- (void)setTintColor:(UIColor *)color;

@end

@protocol HKRefreshControlIndicatorView <NSObject>

- (void)startAnimating;
- (void)stopAnimating;

- (void)setTintColor:(UIColor *)color;

@end

@interface HKRefreshControl : UIControl

/**
 * Tells the control that a refresh operation was started programmatically.
 *
 * Call this method when an external event source triggers a programmatic refresh of your table. For example, if you use an NSTimer object to refresh the contents of the table view periodically, you would call this method as part of your timer handler. This method updates the state of the refresh control to reflect the in-progress refresh operation. When the refresh operation ends, be sure to call the endRefreshing method to return the control to its default state.
 *
 */
- (void)beginRefreshing;

/**
 * Tells the control that a refresh operation has ended.
 *
 * Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user) to return the refresh control to its default state. If the refresh control is at least partially visible, calling this method also hides it. If animations are also enabled, the control is hidden using an animation.
 *
 */
- (void)endRefreshing;

@property (nonatomic) UIColor    *tintColor     UI_APPEARANCE_SELECTOR;

/**
 * The View that is shown and updated when the control is being pulled. Must conform to the HKRefreshControlPullView protocol.
 */
@property (nonatomic) UIView<HKRefreshControlPullView> *pullView;

/**
 * The View that is shown and updated when the control is updating. Must conform to the HKRefreshControlIndicatorView protocol.
 */
@property (nonatomic) UIView<HKRefreshControlIndicatorView> *indicatorView;

/**
 * A Boolean value indicating whether a refresh operation has been triggered and is in progress. (read-only)
 */
@property (nonatomic, readonly) BOOL refreshing;

/**
 * The styled title text to display in the refresh control.
 */
@property (nonatomic) NSAttributedString *attributedTitle;

@end
