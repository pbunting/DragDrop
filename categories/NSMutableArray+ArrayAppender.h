//
//  NSMutableArray+NSMutableArrayHelpers.h
//  MultipleDetailViews
//
//  Created by Paul Bunting on 12/27/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (NSMutableArrayHelpers)

+ (instancetype)arrayWithObjectsFromArrays:(id)firstObj
, ...;

@end
