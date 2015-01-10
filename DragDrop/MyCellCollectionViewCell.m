//
//  MyCellCollectionViewCell.m
//  DragAndDrop
//
//  Created by Paul Bunting on 12/31/14.
//  Copyright (c) 2014 Paul Bunting. All rights reserved.
//

#import "MyCellCollectionViewCell.h"

#import "NSMutableArray+ArrayAppender.h"

@interface MyCellCollectionViewCell()

@property (strong, nonatomic) UILabel* contentLabel;
@property (strong, nonatomic) UIView* highlighter;

@end

@implementation MyCellCollectionViewCell

- (void)baseInit
{
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.contentLabel];
    
    self.contentLabel.text = @"?";
    self.beingMoved = NO;
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [UIColor redColor];
    self.backgroundView = backgroundView;
    
    UIView* selectedBGView = [[UIView alloc] initWithFrame:self.bounds];
    selectedBGView.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = selectedBGView;
    
    
    UILabel* l = self.contentLabel;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(l);
    NSArray *constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[l]-8-|"
                                            options:0 metrics:nil views:viewsDictionary];
    // append to cnstraints
    constraints = [constraints arrayByAddingObjectsFromArray:
                               [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[l]-8-|"
                                                                       options:0 metrics:nil views:viewsDictionary]];
    [self.contentView addConstraints:constraints];
}

- (id)init
{
    NSLog(@"MyCellCollectionViewCell.init");
    self = [super init];
    if (self){
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"MyCellCollectionViewCell.initWithCoder");
    self = [super initWithCoder:aDecoder];
    if (self){
        [self baseInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"MyCellCollectionViewCell.initWithFrame");
    self = [super initWithFrame:frame];
    if (self){
        [self baseInit];
    }
    return self;
}

- (void) setDisplayValue:(NSString *)displayValue
{
    _displayValue = displayValue;
    self.contentLabel.text = _displayValue;
}

- (void) setHighlightedEdge:(CellProximityEdge)highlightedEdge
{
    _highlightedEdge = highlightedEdge;
    if (_highlighter) {
        [_highlighter removeFromSuperview];
    }
    if (_highlightedEdge == CellProximityEdgeLeft) {
        _highlighter = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, 4.0, self.contentView.frame.size.height)];
        _highlighter.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:_highlighter];
    }
    if (_highlightedEdge == CellProximityEdgeRight) {
        _highlighter = [[UIView alloc] initWithFrame:CGRectMake((self.contentView.frame.origin.x + self.contentView.frame.size.width - 4.0), self.contentView.frame.origin.y, 4.0, self.contentView.frame.size.height)];
        _highlighter.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:_highlighter];
    }
}

@end
