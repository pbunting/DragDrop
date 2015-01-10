//
//  MyCellCollectionViewCell.h
//  DragAndDrop
//
//  Created by Paul Bunting on 12/31/14.
//  Copyright (c) 2014 Paul Bunting. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CellProximityEdge.h"

@interface MyCellCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString* displayValue;
@property BOOL beingMoved;

@property (nonatomic)CellProximityEdge highlightedEdge;

@end
