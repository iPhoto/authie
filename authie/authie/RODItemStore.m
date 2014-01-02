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
#import "RODAuthie.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"
#import <RestKit.h>
#import "RODResponseMessage.h"
#import "RODHandle.h"

@implementation RODItemStore

- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *path = [self itemArchivePath];

        _authie = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if(!_authie) {
            NSLog(@"Generated new authie.");
            _authie = [[RODAuthie alloc] init];
            
            // automatically assume all new apps are not registered,
            // later on we'll need to add the functionality that lets
            // you log in to your account from another account.
            _authie.registered = NO;
            
            // generate a private key for the app/device 8)
            // THIS IS A USER's PASSWORD!
            NSString * uuid = [[NSUUID UUID] UUIDString];
            _authie.authieKey = uuid;
            
            [self saveChanges];
        } else {
            NSLog(@"Loaded authie from file, public/private: %@, %@", self.authie.authiePublicKey, self.authie.authiePrivateKey);
        }
                NSLog(@"current authie: registered: %i, authieKey: %@, selfies: %lu", self.authie.registered, self.authie.authieKey, (unsigned long)[self.authie.allSelfies count]);
        
        if(!_authie.allSelfies)
            _authie.allSelfies = [[NSMutableArray alloc] init];
                
        self.recentSelfie = [_authie.allSelfies lastObject];
        
        if(self.authie.registered == 0) {
            // show register handle screen

            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            
            RegisterViewController *rvc = [[RegisterViewController alloc] init];
            [(UINavigationController *)appDelegate.window.rootViewController presentViewController:rvc animated:NO completion:nil];
        }
        
        
    }
    
    return self;
}

- (RODAuthie *)authie;
{
    return _authie;
}

- (RODSelfie *)createSelfie:(NSString *)key
{
    RODSelfie *s = [[RODSelfie alloc] init];
    [s setSelfieKey:key];
    
    [_authie.allSelfies addObject:s];
    
    [self saveChanges];
    
    return s;
}

- (void)removeSelfie:(NSInteger)index
{
    NSString *key = [(RODSelfie *)[_authie.allSelfies objectAtIndex:index] selfieKey];
    [[RODImageStore sharedStore] deleteImageForKey:key];
    
    [_authie.allSelfies removeObjectAtIndex:index];
    
    [self saveChanges];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)checkHandleAvailability:(NSString *)handle
{
   
    BOOL is_available = NO;
    
	// Create a new letter and POST it to the server
	RODHandle* check_handle = [RODHandle new];
    check_handle.active = [NSNumber numberWithInt:1];
    check_handle.userGuid = @"lol";
    check_handle.name = handle;
    check_handle.id = [NSNumber numberWithInt:1];

    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"1", @"id",
                               handle, @"name",
                               @"1", @"active",
                               @"lol", @"userGuid",
                               nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"http://selfies.io/api/checkhandle";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];

            if(response_result == 0) {
                is_available = NO;
            } else {
                is_available = YES;
            }
            
        }
        
    }
    
    return is_available;
    
}

- (BOOL)registerHandle:(NSString *)handle
{
    bool registered_result = NO;
    
	// Create a new letter and POST it to the server
	RODHandle* check_handle = [RODHandle new];
    check_handle.active = [NSNumber numberWithInt:1];
    check_handle.userGuid = @"lol";
    check_handle.name = handle;
    check_handle.id = [NSNumber numberWithInt:1];
    
    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"1", @"id",
                               handle, @"name",
                               @"1", @"active",
                               @"lol", @"userGuid",
                               nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"http://selfies.io/api/handle";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from registration: %@", object);
            
            NSInteger active_result;
            active_result = [[object objectForKey:@"active"] integerValue];
            
            if(active_result == 1) {
                registered_result = YES;
                [self.authie setRegistered:1];
                [self.authie setAuthiePrivateKey:[object objectForKey:@"privateKey"]];
                [self.authie setAuthiePublicKey:[object objectForKey:@"publicKey"]];
                
                NSLog(@"privateKey: %@, publicKey: %@", self.authie.authiePrivateKey, self.authie.authiePublicKey);
                
                [self saveChanges];
            } else {
                registered_result = NO;
            }
            
        }
        
    }
    
    return registered_result;
    
}

- (BOOL)saveChanges
{    
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:_authie toFile:path];
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
