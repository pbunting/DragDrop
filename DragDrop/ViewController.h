//
//  ViewController.h
//  DragDrop
//
//  Created by Paul Bunting on 1/4/15.
//  Copyright (c) 2015 Paul Bunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UICollectionViewController
    <UICollectionViewDataSource,
     UIGestureRecognizerDelegate,
     UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)longHoldPressAction:(UILongPressGestureRecognizer *)sender;

@end
