//
//  NSMutableArray+NSMutableArrayHelpers.m
//  MultipleDetailViews
//
//  Created by Paul Bunting on 12/27/14.
//
//

#import "NSMutableArray+ArrayAppender.h"

@implementation NSMutableArray (NSMutableArrayHelpers)

+ (instancetype)arrayWithObjectsFromArrays:(id)firstObj
, ...
{
    va_list args;
    NSMutableArray* result = [NSMutableArray arrayWithArray:firstObj];
    
    id eachObject;
    va_start(args, firstObj); // Start scanning for arguments after firstObject.
    eachObject = va_arg(args, id);
    while (eachObject) {
        // As many times as we can get an argument of type "id"
        [result addObjectsFromArray:eachObject]; // that isn't nil, add it to self's contents.
        eachObject = va_arg(args, id);
    }
    va_end(args);
    
    
    return result;
}

@end
