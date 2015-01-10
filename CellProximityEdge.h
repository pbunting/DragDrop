//
//  CellProximity.h
//  DragDrop
//
//  Created by Paul Bunting on 1/6/15.
//  Copyright (c) 2015 Paul Bunting. All rights reserved.
//

#ifndef DragDrop_CellProximity_h
#define DragDrop_CellProximity_h

typedef NS_OPTIONS(NSUInteger, CellProximityEdge) {
    CellProximityEdgeNone  = 0,
    CellProximityEdgeLeft   = 1 << 0,
    CellProximityEdgeRight  = 1 << 1,
    CellProximityEdgeTop    = 1 << 2,
    CellProximityEdgeBottom = 1 << 3
};

#endif
