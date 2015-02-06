//
//  JSONProcessor.h
//  peanut
//
//  Created by Jim Young on 9/10/12.
//  Copyright (c) 2012 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONProcessor : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

// A hash of strings ("user") to Obj-C classes
@property NSMutableDictionary* registeredTypes;
+ (JSONProcessor*) singleton;

- (void) registerType:(NSString*)type forClass:(Class)klass;
- (void) process:(id)obj yieldingEntities:(NSMutableSet*)entities error:(NSError**)error;

@end
