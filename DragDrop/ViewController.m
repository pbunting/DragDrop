//
//  ViewController.m
//  DragDrop
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
    
    MyObject* placeholder = [[MyObject alloc] init];
    placeholder.beingMoved = YES;

    self.contents = @[[[NSMutableArray alloc] init],
                      [NSMutableArray arrayWithArray:@[a, b, c]]];
    
//    [self.collectionView registerClass:[MyCellCollectionViewCell class] forCellWithReuseIdentifier:@"MyCell"];
    UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longHoldPressAction:)];
    longPressGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
    self.collectionView.delegate = self;
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

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long sec = [indexPath section];
    
    if (sec == 0) {
        return CGSizeMake(250.0f, 150.0f);
    } else {
        return CGSizeMake(75.0f, 50.f);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    if ((section == 0) && ([self.contents[section] count] == 0)) {
        return CGSizeMake(0.0f, 170.0f);
    } else {
        return CGSizeMake(0.0f, 20.f);
    }
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

- (CGPoint)normalize:(CGPoint)point inRectangle:(CGRect)rect
{
    return CGPointMake((point.x / rect.size.width), (point.y / rect.size.height));
}

- (CellProximityEdge)determineProximityEdgeOf:(CGPoint)here From:(CGPoint)there
{
    // if point inside cell then insert new cell at current index of p, shifting p to p+1
    if ((here.x >= 0.0) && (here.x <= 1.0)
        && (here.y >= 0.0) && (here.y <= 1.0)) {
        return CellProximityEdgeLeft;
    }
    // if point |x| > |y| then we are looking at a left right insert
//    else if (ABS(here.x) >= ABS(here.y)) {
    else {
        if (here.x <= there.x) {
            return CellProximityEdgeLeft;
        }
        else {
            return CellProximityEdgeRight;
        }
    }
    // else might need to use:
    // - (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
    // to work out which cells are above or below this cell. If none are aboce or below revert to left and right
//    else {
//        
//    }
    return CellProximityEdgeNone;
}

        
- (void) longHoldPressAction:(UILongPressGestureRecognizer *)sender {
    
    [self unhighlightAll];

    NSIndexPath* p = [self chooseTarget:sender];
    NSLog(@"Nearest is %ld / %ld", p.section, p.item);

    if (([sender state] == UIGestureRecognizerStateEnded) ||
        ([sender state] == UIGestureRecognizerStateCancelled)) {
        [_dView removeFromSuperview];
        _dView = nil;
        id val = nil;
        CellProximityEdge edge = CellProximityEdgeNone;
        NSIndexPath* tp = nil;
        if (p) {
            val = _contents[_gestureStartedFrom.section][_gestureStartedFrom.item];
            MyCellCollectionViewCell* cellView = (MyCellCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:p];
            if (cellView) {
                CGPoint point = [sender locationInView:cellView];
                
                // normalise point by cell width and height
                edge = [self determineProximityEdgeOf:[self normalize:point inRectangle:cellView.contentView.frame] From:[self normalize:[self centreOf:cellView.contentView.frame] inRectangle:cellView.contentView.frame]];
            }
            if (edge == CellProximityEdgeRight) {
                tp = [NSIndexPath indexPathForItem:p.item + 1 inSection:p.section];
            } else {
                tp = p;
            }
        }
        [UIView animateWithDuration:0.25 animations:^{
            _gestureIndicatorView.alpha = 0.0;
            _gestureIndicatorView.transform = CGAffineTransformIdentity;
            if (tp) {
                [self.contents[tp.section] insertObject:val atIndex:tp.item];
                [self.collectionView insertItemsAtIndexPaths:@[tp]];
            }
            _gestureStartedFrom = nil;
        }];
    }
    else {
        CGPoint location = [sender locationInView:self.collectionView];
        [self drawGestureIndicatorAt:location];

        if (p && ([self.contents[p.section] count] > 0)) {
            
            MyCellCollectionViewCell* cellView = (MyCellCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:p];
            // don't need cell centre, point is an offset to cell centre
            CGPoint point = [sender locationInView:cellView];
            
            // normalise point by cell width and height
            
            CellProximityEdge edge = [self determineProximityEdgeOf:[self normalize:point inRectangle:cellView.contentView.frame] From:[self normalize:[self centreOf:cellView.contentView.frame] inRectangle:cellView.contentView.frame]];
            
            cellView.highlightedEdge = edge;
        }
    }
}

- (void)movePlaceholderTo:(NSIndexPath*)ip
{
    NSInteger section = ip.section;
    
    NSMutableArray* ary = self.contents[section];
    
    int placeholderIndex = 0;
    for (int i = 0; i < [ary count]; i++) {
        MyObject* m = ary[i];
        if (m.beingMoved) {
            placeholderIndex = i;
            break;
        }
    }
    MyObject* m = ary[placeholderIndex];
    [ary removeObject:m];
    [ary addObject:m];
    [self.collectionView reloadData];
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

- (CGPoint)centreOf:(CGRect) rect
{
    return CGPointMake(
                       rect.origin.x + (rect.size.width / 2.0),
                       rect.origin.y + (rect.size.height / 2.0));
}

- (CGRect)surrounds:(CGRect)first And:(CGRect)second
{
    CGFloat left = MIN(first.origin.x, second.origin.x);
    CGFloat top = MIN(first.origin.y, second.origin.y);
    CGFloat right = MAX((first.origin.x + first.size.width), (second.origin.x + second.size.width));
    CGFloat bottom = MAX((first.origin.y + first.size.height), (second.origin.y + second.size.height));
    
    return CGRectMake(left, top,
                      (right - left),
                      (bottom - top));
}

- (NSIndexPath*) chooseTarget:(UIGestureRecognizer*)sender
{
    UICollectionViewCell* firstCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_gestureStartedFrom.section]];
    UICollectionViewCell* lastCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:([self.contents[_gestureStartedFrom.section] count] - 1) inSection:_gestureStartedFrom.section]];
    
//    NSLog(@"** %f %f / %f %f", firstCell.frame.origin.x, firstCell.frame.origin.y, firstCell.frame.size.width, firstCell.frame.size.height);
//    NSLog(@"** %f %f / %f %f", lastCell.frame.origin.x, lastCell.frame.origin.y, lastCell.frame.size.width, lastCell.frame.size.height);
    CGRect startingRegion = [self surrounds:firstCell.frame And:lastCell.frame];
    // Extend startingRegion to top or bottom of view
    if (_gestureStartedFrom.section == 0) {
        startingRegion = [self surrounds:startingRegion And:CGRectMake(0.0, 0.0, self.collectionView.frame.size.width, 0.0)];
    } else {
        startingRegion = [self surrounds:startingRegion And:CGRectMake(0.0, self.collectionView.frame.size.height, self.collectionView.frame.size.width, 0.0)];
    }
    NSLog(@"** %f %f / %f %f", startingRegion.origin.x, startingRegion.origin.y, startingRegion.size.width, startingRegion.size.height);

    NSIndexPath* closest = nil;

    if (!CGRectContainsPoint(startingRegion, [sender locationInView:self.collectionView])) {
        int targetSection;
        if (_gestureStartedFrom.section == 0) {
            targetSection = 1;
        }
        else {
            targetSection = 0;
        }
        
        UICollectionViewCell* closestCell = nil;
        float minDistance = 99999.9;
        
        NSArray* potentialTargets = self.contents[targetSection];
        
        for (int i = 0; i < [potentialTargets count]; i++) {
            NSIndexPath* ip = [NSIndexPath indexPathForItem:i inSection:targetSection];
            UICollectionViewCell* target = [self.collectionView cellForItemAtIndexPath:ip];
            
            CGPoint targetCentre = [self centreOf:target.contentView.frame];
            CGPoint location = [sender locationInView:target];
            
            // Determine distance
            // This is a bit crude and wont work well for extreme rectangles, works best for squares
            float d = sqrtf(powf((targetCentre.x - location.x), 2.0) + powf((targetCentre.y - location.y), 2.0));
            
//            NSLog(@"chooseTarget %ld/%ld [%f,%f => %f,%f = %f]", ip.section, ip.item, targetCentre.x, targetCentre.y, location.x, location.y,d);
            if (d < minDistance) {
                minDistance = d;
                closest = ip;
                closestCell = target;
            }
        }
        if (closest == NULL) {
            closest = [NSIndexPath indexPathForItem:0 inSection:targetSection];
        }
    }
    

//    if (closest.section == _gestureStartedFrom.section) {
//        if (minDistance <= 40.0) {
//            closest = nil;
//        } else {
//            if (_gestureStartedFrom.section == 0) {
//                // Check
//            }
//            closest = [NSIndexPath indexPathForItem:0 inSection:targetSection];
//        }
//    }
    return closest;
    
}

- (void) unhighlightAll {
    int targetSection;
    if (_gestureStartedFrom.section == 0) {
        targetSection = 1;
    }
    else {
        targetSection = 0;
    }
    
    
    NSArray* potentialTargets = self.contents[targetSection];
    for (int i = 0; i < [potentialTargets count]; i++) {
        NSIndexPath* ip = [NSIndexPath indexPathForItem:i inSection:targetSection];
        MyCellCollectionViewCell* target = (MyCellCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:ip];
        
        target.highlightedEdge = CellProximityEdgeNone;
    }
}


@end
