//
//  RODImageStore.h
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODImageStore : NSObject
{
    NSMutableDictionary *dictionary;
}
+ (RODImageStore *)sharedStore;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;

- (NSString *)imagePathForKey:(NSString *)key;

@end
