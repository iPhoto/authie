//
//  RODImageStore.h
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODImageStore : NSObject <NSURLConnectionDelegate>
{
    NSMutableDictionary *dictionary;
    NSMutableData *_downloadingSnap;
    NSString *downloadingSnapKey;
    int downloadingSnapRow;
}

+ (RODImageStore *)sharedStore;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;
-(void)preloadImageAndShowScreen:(int)row;

- (NSString *)imagePathForKey:(NSString *)key;

@end
