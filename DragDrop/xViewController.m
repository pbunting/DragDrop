//
//  ViewController.m
//  DragAndDrop
//
//  Created by Paul Bunting on 12/31/14.
//  Copyright (c) 2014 Paul Bunting. All rights reserved.
//

#import "ViewController.h"

#import "MyCellCollectionViewCell.h"
#import "MyTargetCollectionViewCell.h"

#import "MyObject.h"

#import "DebugView.h"

@interface ViewController ()

@property NSArray* contents;

@property (strong, nonatomic) UIImageView* gestureIndicatorView;
@property (strong, nonatomic) NSIndexPath* gestureStartedFrom;
@property (strong, nonatomic) NSIndexPath* gestureTargetting;

@property CGPoint lastKnownPosition;
@property BOOL lastKnownPositionUsed;

@property (strong, nonatomic) DebugView* dView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    // Initialise - empty section 0
    //              section 1 = "a", "b", "c"
    MyObject* a = [[MyObject alloc] init];
    a.data = @"A";
    MyObject* b = [[MyObject alloc] init];
    b.data = @"B";
    MyObject* c = [[MyObject alloc] init];
    c.data = @"C";
    self.contents = @[[[NSMutableArray alloc] init],
                      [NSMutableArray arrayWithArray:@[a, b, c]]];
    
//    [self.collectionView registerClass:[MyCellCollectionViewCell class] forCellWithReuseIdentifier:@"MyCell"];
    UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longHoldPressAction:)];
    longPressGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
    
    _lastKnownPositionUsed = NO;

}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    _gestureStartedFrom = [self longHoldPressedCell:gestureRecognizer];
    if (_gestureStartedFrom) {
        _gestureTargetting = nil;
        
        MyObject* obj = self.contents[_gestureStartedFrom.section][_gestureStartedFrom.item];
        obj.beingMoved = YES;
        
        int targetSection;
        if (_gestureStartedFrom.section == 0) {
            targetSection = 1;
        }
        else {
            targetSection = 0;
        }
        
        MyObject* placeholder = [[MyObject alloc] init];
        placeholder.beingMoved = YES;
        [self.contents[targetSection] addObject:placeholder];
        
//        [self addPlaceholderCellTo:targetSection];
        _dView = [[DebugView alloc] initWithFrame:self.collectionView.frame];
        _dView.backgroundColor = [UIColor clearColor];
        [self.collectionView addSubview:_dView];

        return YES;
    }
    return NO;
}


#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.contents count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.contents[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * newCell = nil;
    
    long sec = [indexPath section];
    long row = [indexPath item];
    
    // In this example both section 0 and section 1 contain only MyObject, this is a simple example.
    if (sec == 1) {
        MyObject* obj = (MyObject*)self.contents[sec][row];
        MyCellCollectionViewCell* newMyCell;
        if (obj.beingMoved) {
            newMyCell = (MyCellCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MyCellPlaceholder" forIndexPath:indexPath];
        } else {
            newMyCell = (MyCellCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
        }
        newMyCell.displayValue = obj.data;
        newCell = newMyCell;
    }
    else {
        MyObject* obj = (MyObject*)self.contents[sec][row];
        MyCellCollectionViewCell* newMyCell;
        if (obj.beingMoved) {
            newMyCell = (MyCellCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MyTargetPlaceholder" forIndexPath:indexPath];
        } else {
            newMyCell = (MyCellCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MyTarget" forIndexPath:indexPath];
        }
        newMyCell.displayValue = obj.data;
        newCell = newMyCell;
    }
    return newCell;
}

- (void) drawGestureIndicatorAt:(CGPoint)location
{
    if (_gestureIndicatorView == NULL) {
        _gestureIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(location.x, location.y, 40.0f, 40.0f)];
        _gestureIndicatorView.backgroundColor = [UIColor lightGrayColor];
        [self.collectionView addSubview:_gestureIndicatorView];
    }
    else {
        _gestureIndicatorView.alpha = 1.0;
        _gestureIndicatorView.frame = CGRectMake(location.x - 20.0f, location.y - 20.0f, 40.0f, 40.0f);
    }
}

- (void) longHoldPressAction:(UILongPressGestureRecognizer *)sender {
    
//    // Get the location of the gesture
//    NSIndexPath* potentialTarget = [self longHoldPressedCell:sender];
//    if (potentialTarget.section != _gestureStartedFrom.section) {
//        
//    }
    
//    NSLog(@">longHoldGestureAction %f,%f", location.x, location.y);
    CGPoint location = [sender locationInView:self.collectionView];
    [self drawGestureIndicatorAt:location];
    
    NSIndexPath* p = [self chooseTarget:sender];
    
    if (([sender state] == UIGestureRecognizerStateEnded) ||
        ([sender state] == UIGestureRecognizerStateCancelled)) {
        _lastKnownPositionUsed = NO;
        [_dView removeFromSuperview];
        _dView = nil;
        [UIView animateWithDuration:0.25 animations:^{
            _gestureIndicatorView.alpha = 0.0;
            _gestureIndicatorView.transform = CGAffineTransformIdentity;
            NSNumber* val = _contents[_gestureStartedFrom.section][_gestureStartedFrom.item];
            [self.contents[p.section] insertObject:val atIndex:p.item];
            [self.collectionView reloadData];
            _gestureStartedFrom = nil;
        }];
    }
    
}

- (NSIndexPath*) longHoldPressedCell:(UIGestureRecognizer *)sender
{
    for (int s = 0; s < [self.contents count]; s++) {
        for (int i = 0; i < [self.contents[s] count]; i++) {
            NSIndexPath* ip = [NSIndexPath indexPathForItem:i inSection:s];
            UICollectionViewCell* cellView = [self.collectionView cellForItemAtIndexPath:ip];
            CGPoint point = [sender locationInView:cellView];
            float minX = cellView.contentView.frame.origin.x - 10.0;
            float maxX = cellView.contentView.frame.origin.x + cellView.frame.size.width + 10.0;
            float minY = cellView.contentView.frame.origin.y - 10.0;
            float maxY = cellView.contentView.frame.origin.y + cellView.frame.size.height + 10.0;
            
            if ((point.x > minX) && (point.x < maxX) &&
                (point.y > minY) && (point.y < maxY)) {
                return ip;
            }
        }
    }
    return nil;
}

- (CGPoint) getCellCentre:(UICollectionViewCell*)cell
{
    CGRect newFrame = [cell.contentView convertRect:cell.contentView.frame toView:self.collectionView];
    return CGPointMake(
                newFrame.origin.x + (newFrame.size.width / 2.0),
                newFrame.origin.y + (newFrame.size.height / 2.0));
}


//- (void)addPlaceholderCellTo:(int)section
//{
//    NSMutableArray* t = self.contents[section];
//    [t addObject:[NSNumber numberWithInt:0]];
//    [self.collectionView reloadData];
//}

- (NSIndexPath*) chooseTarget:(UIGestureRecognizer*)sender
{
    int targetSection;
    if (_gestureStartedFrom.section == 0) {
        targetSection = 1;
    }
    else {
        targetSection = 0;
    }
    
//    NSLog(@"TargetSection = %d", targetSection);
    
    CGPoint newLocation = [sender locationInView:self.collectionView];
    NSArray* potentialTargets = self.contents[targetSection];
//    NSLog(@"#potential targets %lu", (unsigned long)[potentialTargets count]);
    
    NSMutableArray* draws = [NSMutableArray arrayWithObjects:nil];
    NSMutableArray* undraws = [NSMutableArray arrayWithObjects:nil];
    
    for (int i = 0; i < [potentialTargets count]; i++) {
        NSIndexPath* ip = [NSIndexPath indexPathForItem:i inSection:targetSection];
        UICollectionViewCell* target = [self.collectionView cellForItemAtIndexPath:ip];
        
        CGPoint dest = [self getCellCentre:target];
        //TODO remove _lastKnownPosition
        if (_lastKnownPositionUsed) {
            [undraws addObject:[NSNumber numberWithFloat:_lastKnownPosition.x]];
            [undraws addObject:[NSNumber numberWithFloat:_lastKnownPosition.y]];
            [undraws addObject:[NSNumber numberWithFloat:dest.x]];
            [undraws addObject:[NSNumber numberWithFloat:dest.y]];
        }
        [draws addObject:[NSNumber numberWithFloat:newLocation.x]];
        [draws addObject:[NSNumber numberWithFloat:newLocation.y]];
        [draws addObject:[NSNumber numberWithFloat:dest.x]];
        [draws addObject:[NSNumber numberWithFloat:dest.y]];
    }
    _dView.linesToDraw = draws;
    
    [_dView setNeedsDisplay];
    _lastKnownPosition = newLocation;
    _lastKnownPositionUsed = YES;
    // TODO apply left right algorithm
    return [NSIndexPath indexPathForItem:[potentialTargets count] inSection:targetSection];
//    return nil;
}


@end
