//
//  ViewController.h
//  DragAndDrop
//
//  Created by Paul Bunting on 12/31/14.
//  Copyright (c) 2014 Paul Bunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UICollectionViewController
<UICollectionViewDataSource,
 UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)longHoldPressAction:(UILongPressGestureRecognizer *)sender;

@end

