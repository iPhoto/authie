//
//  RODItemStore.m
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODItemStore.h"
#import "RODImageStore.h"
#import "RODSelfie.h"

@implementation RODItemStore

- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *path = [self itemArchivePath];
        allSelfies = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if(!allSelfies)
            allSelfies = [[NSMutableArray alloc] init];
        
        NSLog(@"Loaded selfies: %d", [allSelfies count]);

        self.currentSelfieIndex = [allSelfies count] - 1;
        NSLog(@"currentSelfieIndex init: %d", self.currentSelfieIndex);
        
        self.recentSelfie = [allSelfies lastObject];
    }
    
    return self;
}

- (NSArray *)allSelfies
{
    return allSelfies;
}

- (RODSelfie *)createSelfie:(NSString *)key
{
    RODSelfie *s = [[RODSelfie alloc] init];
    [s setSelfieKey:key];
    
    [allSelfies addObject:s];
    
    [self saveChanges];
    
    return s;
}

- (void)removeSelfie:(NSInteger)index
{
    NSString *key = [(RODSelfie *)[allSelfies objectAtIndex:index] selfieKey];
    [[RODImageStore sharedStore] deleteImageForKey:key];
    
    [allSelfies removeObjectAtIndex:index];
    
    [self saveChanges];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)saveChanges
{    
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:allSelfies toFile:path];
}

+ (RODItemStore *)sharedStore
{
    static RODItemStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedStore];
}



@end
