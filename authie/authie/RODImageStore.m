//
//  RODImageStore.m
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODImageStore.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "RODItemStore.h"
#import "RODAuthie.h"

@implementation RODImageStore
@synthesize showThreadAfterDownload;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedStore];
}

+ (RODImageStore *)sharedStore
{
    static RODImageStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

- (id)init {
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
        
        showThreadAfterDownload = YES;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    }
    return self;
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    
    if(i != nil) {
        [dictionary setObject:i forKey:s];
        
        NSString *imagePath = [self imagePathForKey:s];
        
        NSData *d = UIImageJPEGRepresentation(i, 1);
        
        [d writeToFile:imagePath atomically:YES];
    }
    
}

-(UIImage *) getSnapFromWebsite:(NSString *)groupKey {
    
    
    UIImage * result;
    
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    //dispatch_async(queue, ^{
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://authie.me/api/snap/500/%@", groupKey]]];
        result = [UIImage imageWithData:data];
        
        //dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [self setImage:result forKey:groupKey];
        //});
    //});

    
    return result;
}

-(void)preloadImageAndShowScreen:(int)row
{

    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    UIImage *result = [dictionary objectForKey:thread.groupKey];
    
    if(!result) {
        
        downloadingSnapRow = row;
        downloadingSnapKey = thread.groupKey;
        
        [self downloadImageAndShowScreen:thread.groupKey];
    }
    
}

- (void)downloadImage:(NSString *)groupKey
{
    showThreadAfterDownload = NO;
    [self downloadImageAndShowScreen:groupKey];
}

- (void)downloadImageAndShowScreen:(NSString *)groupKey
{
    
    NSString *websiteUrl = [NSString stringWithFormat:@"http://authie.me/api/snap/640/%@", groupKey];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:websiteUrl] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:5];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [conn start];
    
    [[RODItemStore sharedStore] loadMessagesForThread:groupKey];

}

- (UIImage *)imageForKey:(NSString *)s
{
    
    UIImage __block *result;

    
    NSLog(@"Image for key: %@", s);
    result = [dictionary objectForKey:s];
    
    if (!result) {
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
        
        if (result) {
            [dictionary setObject:result forKey:s];
        } else {
            NSLog(@"Unable to load image, loading from website");
            
            result = [self getSnapFromWebsite:s];
            
            if(result) {
                [self setImage:result forKey:s];
                NSLog(@"Called setImage after downloading...");
            }
            
        }
    }
    
    return result;

}

- (void)deleteImageForKey:(NSString *)s
{
    if (!s)
        return;
    [dictionary removeObjectForKey:s];
    
    NSString *path = [self imagePathForKey:s];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", [dictionary count]);
    [dictionary removeAllObjects];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _downloadingSnap = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_downloadingSnap appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    UIImage *result;
    result = [UIImage imageWithData:_downloadingSnap];
    
    [self setImage:result forKey:downloadingSnapKey];

    if(showThreadAfterDownload == YES) {
        //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //[appDelegate.threadViewController loadThread:downloadingSnapRow];
        //[appDelegate.masterViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
    }

    showThreadAfterDownload = YES;
}

@end
