//
//  JSONProcessor.m
//  peanut
//
//  Created by Jim Young on 9/10/12.
//  Copyright (c) 2012 Perceptual Networks. All rights reserved.
//

#import "JSONProcessor.h"
#import "App.h"
#import "NSArray+Map.h"

#import "Base.h"
#import "User.h"
#import "SkyMessage.h"
#import "Story.h"
#import "Group.h"
#import "Emoticon.h"
#import "IosPreference.h"
#import "UserPreference.h"
#import "UserGroupPreference.h"
#import "SkyAccount.h"
#import "Configuration.h"
#import "FlagReason.h"

#define kAppCommandNotification @"kAppCommandNotification"

@implementation JSONProcessor

@synthesize registeredTypes = _registeredTypes;

+ (JSONProcessor*) singleton {
    static JSONProcessor *proc = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //
        // NOTE: update [App logout] if you add a data class here
        //

        proc = [[JSONProcessor alloc] init];
        proc.registeredTypes = [[NSMutableDictionary alloc] init];
        [proc registerType:@"user" forClass:[User class]];
        // [proc registerType:@"emoticon" forClass:[Emoticon class]];
        [proc registerType:@"group" forClass:[Group class]];
        [proc registerType:@"one_to_one" forClass:[Group class]];
        [proc registerType:@"message" forClass:[SkyMessage class]];
        [proc registerType:@"story" forClass:[Story class]];
        [proc registerType:@"account" forClass:[SkyAccount class]];
        [proc registerType:@"configuration" forClass:[Configuration class]];
        [proc registerType:@"ios_device_preferences" forClass:[IosPreference class]];
        [proc registerType:@"user_preferences" forClass:[UserPreference class]];
        [proc registerType:@"user_group_preferences" forClass:[UserGroupPreference class]];
        [proc registerType:@"flag_reason" forClass:[FlagReason class]];

        proc.context = [App privateManagedObjectContext];
    });

    return proc;
}

- (NSManagedObjectContext*) _moc {
    return self.context ?: [App moc];
}

- (id) processObject:(id)jsonObject
    yieldingEntities:(NSMutableSet*)entities
               error:(NSError**)error {
    return [self processObject:jsonObject yieldingEntities:entities shouldInstantiate:YES error:error];
}

- (id) processObject:(id)jsonObject
    yieldingEntities:(NSMutableSet*)entities
   shouldInstantiate:(BOOL)instantiate
               error:(NSError**)error {
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSArray* objArray = (NSArray*)jsonObject;
        
        // A dictionary of arrays:
        NSMutableDictionary* objectsSortedByType = [[NSMutableDictionary alloc] initWithCapacity:10];
        NSError* err;
        
        for (id obj in objArray) {
            
            if ([obj isKindOfClass:[NSDictionary class]] && [self.registeredTypes objectForKey:[obj valueForKeyPath:@"object_type"]]) {
                
                NSString* objType = [obj valueForKeyPath:@"object_type"];
                
                NSMutableArray* a = [objectsSortedByType objectForKey:objType];
                if (!a) {
                    a = [[NSMutableArray alloc] initWithCapacity:10];
                    [objectsSortedByType setObject:a forKey:objType];
                }
                
                [a addObject:obj];
                [self processObject:obj yieldingEntities:entities shouldInstantiate:YES error:&err];
                if (err) *error = err;
                
            } else {
                [self processObject:obj yieldingEntities:entities error:&err];
                if (err) *error = err;
            }
        }
        
        for (NSString* objType in objectsSortedByType) {
            Class klass = [self.registeredTypes objectForKey:objType];
            NSArray* dicts = [objectsSortedByType objectForKey:objType];
            [entities addObjectsFromArray:[self instantiateObjects:dicts ofClass:klass]];
        }
        
    }
    else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        id obj;
        NSDictionary* dict = (NSDictionary*) jsonObject;
        
        // Process embedded objects
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                NSError* err;
                [self processObject:obj yieldingEntities:entities error:&err];
                if (err) {
                    *error = err;
                    *stop = YES;
                }
            }
        }];
        
        id objType = [dict objectForKey:@"object_type"];
        if (objType) {
            
            Class klass = [self.registeredTypes objectForKey:(Class)objType];
            if (klass && instantiate) {
                [entities addObjectsFromArray:[self instantiateObjects:@[dict] ofClass:klass]];
                
            } else if ([(NSString *)objType isEqualToString:@"command"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAppCommandNotification object:dict userInfo:nil];
                return nil;
            }
        }
        
        // Look for error in API response:
        id err = [dict objectForKey:@"error"];
        if ([err isKindOfClass:[NSDictionary class]]) {
            NSDictionary* errDict = (NSDictionary*)err;
            *error = [NSError errorWithDomain:@"peanut"
                                         code:[[errDict objectForKey:@"code"] intValue]
                                     userInfo:errDict];
        }
        
        return obj;
    }
    return nil;
}

- (void) process:(id)obj yieldingEntities:(NSMutableSet*)entities error:(NSError**)error {
    NSError* err = nil;
    [self processObject:obj yieldingEntities:entities error:&err];

    [entities enumerateObjectsUsingBlock:^(id entity, BOOL *stop) {
        [entity awakeFromRemoteWithContext:[self _moc]];
    }];
}

- (void) registerType:(NSString*)type forClass:(Class)klass {
    [self.registeredTypes setObject:klass forKey:type];
}

- (NSArray*) instantiateObjects:(NSArray*)jsonObjects ofClass:(Class)klass {
    NSArray* ids = [jsonObjects valueForKey:@"id"];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id IN (%@)", ids];
    NSArray* existingModels = [klass performSelector:@selector(findAllUsingPredicate:inContext:) withObject:predicate withObject:[self _moc]];
    NSArray* existingIds = [existingModels valueForKey:@"id"];
    NSArray* newIds = [ids filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![existingIds containsObject:evaluatedObject];
    }]];
    
    NSMutableArray* resultModels = [existingModels mutableCopy];
    
    // O(n) -- create id=>JSON mapping / process JSON objects with no ID
    NSMutableDictionary *jsonById = [NSMutableDictionary dictionary];
    for (id json in jsonObjects) {

        NSString *jsonId = [json valueForKey:@"id"];
        if(jsonId) {
            [jsonById setObject:json forKey:jsonId];
            
        } else {
            // Special case, if no value for id, treat as a singleton
            Base* model = [klass performSelector:@selector(findOrCreateById:inContext:) withObject:kNullIdString withObject:[self _moc]];
            [model processJSONObject:json];
            [resultModels addObject:model];
        }

    }
    
    // O(n) -- process existing objects
    for (id obj in existingModels) {
        Base* model = (Base*)obj;
        
        NSString *key = [model valueForKey:@"id"];
        if(!key)
            continue;
        
        id json = [jsonById objectForKey:key];
        if (!json)
            continue;
        
        [model processJSONObject:json];
    }

    // O(n) -- create new objects
    for (NSString* newId in newIds) {
        BOOL isNull = [newId isEqual:[NSNull null]];
        if(isNull)
            continue;
        
        id json = [jsonById objectForKey:newId];
        if (!json)
            continue;
        
        Base* model = [klass performSelector:@selector(findOrCreateById:inContext:) withObject:newId withObject:[self _moc]];
        [model processJSONObject:json];
        [resultModels addObject:model];
    }
    
    return resultModels;
}

@end
