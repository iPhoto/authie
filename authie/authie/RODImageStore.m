//
//  RODImageStore.m
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODImageStore.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "RODItemStore.h"
#import "RODAuthie.h"

@implementation RODImageStore

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
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    }
    return self;
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
    
    NSString *imagePath = [self imagePathForKey:s];
    
    NSData *d = UIImageJPEGRepresentation(i, 1);

    NSLog(@"Image written to disk: %@", s);
    [d writeToFile:imagePath atomically:YES];
    
}

-(UIImage *) getSnapFromWebsite:(NSString *)groupKey {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://selfies.io/api/snap/500/%@", groupKey]]];
    result = [UIImage imageWithData:data];
    
    [self setImage:result forKey:groupKey];
    
    return result;
}

-(void)preloadImageAndShowScreen:(int)row
{

    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    UIImage *result = [dictionary objectForKey:thread.groupKey];
    
    if(result) {

        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate.threadViewController loadThread:row];
        
        //    NavigationController *navigationController = appDelegate.masterViewController.navigationController;
        [appDelegate.masterViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
        
        
    } else {
        
        NSLog(@"ok, downloadImageAndShowScreen");
        downloadingSnapRow = row;
        downloadingSnapKey = thread.groupKey;
        
        [self downloadImageAndShowScreen:thread.groupKey];
    }
    

    
}

- (void)downloadImageAndShowScreen:(NSString *)groupKey
{
    
    NSString *websiteUrl = [NSString stringWithFormat:@"http://selfies.io/api/snap/500/%@", groupKey];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:websiteUrl]];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (UIImage *)imageForKey:(NSString *)s
{

    NSLog(@"Image for key: %@", s);
    UIImage *result = [dictionary objectForKey:s];
        
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
    
    NSLog(@"connecitonDidFinishLoading.");
    
    UIImage *result;
    result = [UIImage imageWithData:_downloadingSnap];
    
    [self setImage:result forKey:downloadingSnapKey];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.threadViewController loadThread:downloadingSnapRow];
    
    NSLog(@"pushing...");
    [appDelegate.masterViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];

    
}

@end
