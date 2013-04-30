//
//  HKViewController.m
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

#import "HKViewController.h"
#import "HKRefreshControl.h"

@interface HKViewController ()

@property (nonatomic) NSArray *objects;

- (void)refreshObjects;

@end

@implementation HKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshObjects];
    self.customRefreshControl = [[HKRefreshControl alloc] init];
    [self.customRefreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.customRefreshControl.tintColor = [UIColor magentaColor];
    self.customRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
}

- (void)onRefresh:(HKRefreshControl *)sender
{
    self.customRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self refreshObjects];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *lastUpdated = [NSString stringWithFormat:@"%@ %@",
                                 @"Last update:",
                                 [formatter stringFromDate:[NSDate date]]];
        sender.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [sender endRefreshing];
    });
}

- (void)refreshObjects
{
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger i = 0; i < 20; ++i)
    {
        int num = arc4random() % 100;
        [numbers addObject:[NSNumber numberWithInt:num]];
    }
    self.objects = numbers;

    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *s_cellId = @"HKViewControllerCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:s_cellId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_cellId];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%i", [[self.objects objectAtIndex:indexPath.row] intValue]];

    return cell;
}

@end
