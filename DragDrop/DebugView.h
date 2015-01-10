//
//  DebugView.h
//  DragAndDrop
//
//  Created by Paul Bunting on 1/3/15.
//  Copyright (c) 2015 Paul Bunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugView : UIView

@property (strong, nonatomic) NSArray* linesToDraw;
@property CGPoint from;

@end
