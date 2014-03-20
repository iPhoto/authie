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
#import "RODResponseMessage.h"
#import "RODHandle.h"
#import "RODThread.h"
#import "RODFollower.h"
#import "RODMessage.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import <MRProgressOverlayView.h>
#import "NavigationViewController.h"
#import "RNCryptor.h"
#import "RNDecryptor.h"
#import "RODChat.h"

@implementation RODItemStore
@synthesize loadedThreadsFromAuthor, hubConnection, hubProxy, mostRecentGroupKey, currentPage, wireThreads, selectedColor;

- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *path = [self itemArchivePath];

        
        currentPage = 1;
        
        selectedColor = [UIColor whiteColor];
        
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
            _authie.privateKey = uuid;
            
            [self saveChanges];
        } else {
            NSLog(@"Loaded authie from file, public/private: %@, %@", self.authie.handle.publicKey, self.authie.handle.privateKey);
                        
        }
        
        NSLog(@"current authie: registered: %i, authieKey: %@, selfies: %lu, id: %@, name: %@", self.authie.registered, self.authie.privateKey, (unsigned long)[self.authie.allSelfies count], self.authie.handle.id, self.authie.handle.name);
        
        // Sets the alias. It will be sent to the server on registration.
        [UAPush shared].alias = self.authie.handle.publicKey;
        [[UAPush shared] updateRegistration];
        
        
        if(!_authie.allContacts) {
            _authie.allContacts = [[NSMutableArray alloc] init];
        }
        
        if(!_authie.allSelfies)
            _authie.allSelfies = [[NSMutableArray alloc] init];
        
        if(!_authie.allThreads)
            _authie.allThreads = [[NSMutableArray alloc] init];
        
        if(!_authie.allMessages)
            _authie.allMessages = [[NSMutableArray alloc] init];
        
        if(!_authie.failedChats)
            _authie.failedChats = [[NSMutableArray alloc] init];
        
        if(!loadedThreadsFromAuthor)
            loadedThreadsFromAuthor = [[NSMutableArray alloc] init];
        
        if(!self.wireThreads) {
            self.wireThreads = [[NSMutableArray alloc] init];
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

- (void) removeContact:(RODHandle *)handle
{
    NSLog(@"Remove contact: %@", handle.name);

    NSError *error = nil;
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSString stringWithFormat:@"=%@",handle.name] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/follower";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"DELETE"];

    if(error == nil) {
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:data];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from delete contact: %@", object);
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            if(response_result == 1) {
                
                [self.authie.allContacts removeObject:handle];
                [self loadContacts];
                
            }
            
            
        }
        
    } else {
        NSLog(@"Error: %@", error);
    }
    
    
    [self saveChanges];
    
}

- (void)removeThread:(RODThread *)thread
{
    
    NSLog(@"Remove thread: %@", thread.groupKey);
    
    NSError *error = nil;
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSString stringWithFormat:@"=%@",thread.groupKey] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/thread";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"DELETE"];
    
    if(error == nil) {
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:data];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from delete: %@", object);
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            if(response_result == 1) {
                
                // remove thread with existing groupKey
                NSMutableArray *tempThreads = [NSMutableArray arrayWithArray:self.authie.allThreads];
                for(RODThread *t in tempThreads) {
                    if([t.groupKey isEqualToString:thread.groupKey]) {
                        NSLog(@"Found the key to remove, threads: %ul", [self.authie.allThreads count]);
                        [self.authie.allThreads removeObject:t];
                        [self saveChanges];
                        [self loadThreads:false];
                        NSLog(@"Found the key to remove, threads: %ul", [self.authie.allThreads count]);
                        break;
                    }
                }
                
            }
            
            
        }
        
    } else {
        NSLog(@"Error: %@", error);
    }

    
    [[RODImageStore sharedStore] deleteImageForKey:thread.groupKey];
    
    [self saveChanges];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (void)sendNotes:(NSString *)groupKey
{
    
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/notification/%@", groupKey];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from sendNotes: %@", object);
            
        }
        
    } else {
        NSLog(@"Error: %@", error);
    }

    
}

- (void)report:(NSString *)groupKey
{
    NSError *error = nil;
    NSData *localData = nil;
    NSURLResponse *response;
    
    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"1", @"id",
                               @"1", @"fromHandleId",
                               @"1", @"toHandleId",
                               groupKey, @"groupKey",
                               @"1", @"active",
                               @"", @"caption",
                               nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSString *url = @"https://authie.me/api/report";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if(deserialize_error == nil) {
            
            NSLog(@"results from report: %@", object);
            
        }
        
    }
    

}

- (void)sendChat:(NSString *)groupKey message:(NSString *)msg  toKey:(NSString *)toKey
{
    
    NSLog(@"SendChat: groupKey=%@, toKey=%@, msg=%@", groupKey, toKey, msg);
    
    // new shit
    //[self.hubProxy invoke:@"Send" withArgs:[NSArray arrayWithObjects: [RODItemStore sharedStore].authie.handle.name, msg, groupKey, toKey, nil]];
    
    // more reliable shit
    
    BOOL start_convo_success = NO;
    
	// Create a new letter and POST it to the server
    
    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               groupKey, @"groupKey",
                               msg, @"message",
                               toKey, @"toKey",
                               nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/message";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if(localData == nil) {
            // somehow send this chat later!!!
            NSLog(@"failedChat error: %@", error);
            
            RODChat *f = [[RODChat alloc] init];
            f.groupKey = groupKey;
            f.toKey = toKey;
            f.message = msg;
            
            [self.authie.failedChats addObject:f];
            
            return;
        }
        
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from sendChat: %@", object);
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            if(response_result == 0) {
                // add it to be resent later?
                start_convo_success = NO;
            } else {
                
                start_convo_success = YES;
                
            }
            
        }
        
    }
    
}


- (void)giveLove:(NSString *)groupKey
{
    NSError *error = nil;
    NSData *localData = nil;
    NSURLResponse *response;

    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"1", @"id",
                               @"1", @"fromHandleId",
                               @"1", @"toHandleId",
                               groupKey, @"groupKey",
                               @"1", @"active",
                               @"", @"caption",
                               nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSString *url = @"https://authie.me/api/heart";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    
        
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if(deserialize_error == nil) {
            
            NSLog(@"results from heart: %@", object);
            
            //NSInteger response_result;
            //response_result = [[object objectForKey:@"result"] integerValue];
            
            //NSString *message_result;
            // this will contain our private key if we were successful
            //message_result = [object objectForKey:@"message"];
            
        }
        
    }
    
}


- (NSString *)login:(NSString *)handle privateKey:(NSString *)key;
{
    NSString *logged_in = @"NO";
    
    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"1", @"id",
                               handle, @"name",
                               @"1", @"active",
                               @"lol", @"userGuid",
                               key, @"publicKey",
                               key, @"privateKey",
                               nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/login";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
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

            NSLog(@"results from login: %@", object);
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            NSString *message_result;
            // this will contain our private key if we were successful
            message_result = [object objectForKey:@"message"];
            
            if(response_result == 0) {
                logged_in = message_result;
            } else {
                logged_in = @"YES";
                
                
                [RODItemStore sharedStore].authie.handle.privateKey = message_result;
                [RODItemStore sharedStore].authie.privateKey = message_result;
                [[RODItemStore sharedStore] saveChanges];
                NSLog(@"found key: %@", message_result);
                
                [self getHandleInformation];
            }
            
        }
        
    }
    
    return logged_in;
}

- (void)getPrivateKey
{
    
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/privatekey";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(localData == nil)
        {
            // uhhmm.. what do we do in this situation?
            NSLog(@"getPrivateKey FAILED...");
            return;
        }
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            if(response_result == 1) {
                
                self.authie.privateKey = [object objectForKey:@"message"];
                [self saveChanges];
                
            }
            
        }
        
    }
    
}


- (BOOL)checkLoginStatus
{
    
    BOOL is_logged_in = NO;
    
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/login";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(localData == nil)
        {
            // uhhmm.. what do we do in this situation?
            NSLog(@"checkLoginStatus FAILED...");
            return false;
            
        }
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            if(response_result == 0) {
                is_logged_in = NO;
            } else {
                
                is_logged_in = YES;
                [self loadContacts];
                [self loadMessages:nil];
                [self loadThreads:false];

            }
            
        }
        
    }
    
    return is_logged_in;
    
}

- (BOOL)getHandleInformation
{
    BOOL got = NO;
    
    NSError *error = nil;
    
    NSURLResponse *response;
    
    NSString *url = @"https://authie.me/api/handle";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"GET"];

    NSData *localData = nil;
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        id inner_object = [object objectAtIndex:0];

        if([inner_object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {

            NSLog(@"results from getHandleInformation: %@", object);
            
            NSInteger active_result;
            active_result = [[inner_object objectForKey:@"active"] integerValue];
            
            NSInteger id_result;
            id_result = [[inner_object objectForKey:@"id"] integerValue];
            
            //NSString *privateKey;
            //privateKey = [inner_object objectForKey:@"privateKey"];
            
            NSString *publicKey;
            publicKey = [inner_object objectForKey:@"publicKey"];
            
            NSString *name;
            name = [inner_object objectForKey:@"name"];
            
            NSString *userGuid;
            userGuid = [inner_object objectForKey:@"userGuid"];
            
            if(active_result == 1) {
                got = YES;
                [self.authie setRegistered:1];
                
                self.authie.handle = [[RODHandle alloc] init];
                
                [self.authie.handle setId:[NSNumber numberWithInteger:id_result]];
                [self.authie.handle setName:name];
                [self.authie.handle setActive:[NSNumber numberWithInteger:active_result]];
                [self.authie.handle setUserGuid:userGuid];
                //[self.authie.handle setPrivateKey:privateKey];
                [self.authie.handle setPublicKey:publicKey];
                
                NSLog(@"id: %lu, privateKey: %@, publicKey: %@", [self.authie.handle.id longValue], self.authie.privateKey, self.authie.handle.publicKey);
                
                // Sets the alias. It will be sent to the server on registration.
                [UAPush shared].alias = self.authie.handle.publicKey;
                [[UAPush shared] updateRegistration];

                
                [self saveChanges];
                
                [self loadThreads:false];
                [self loadContacts];

                //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                //[appDelegate.leftDrawer showDashboard];
                
            } else {
                got = NO;
                NSLog(@"bad result: %@", object);
                
            }

            
        } else {
            NSLog(@"bad result: %@", object);
        }
        
    }
    
    
    return got;
}

- (BOOL)uploadSnap:(NSString *)key
{
    BOOL upload_success = NO;

    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/upload/postfile?key=%@", key];

    NSLog(@"ok, about to upload snap: %@", key);
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];

    // ??????
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];

    // add image data
    NSData *imageData = UIImageJPEGRepresentation([[RODImageStore sharedStore] imageForKey:key], 0.25);
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"groupKey"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set URL
    [request setURL:[NSURL URLWithString:url]];
    
    if(error == nil) {
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        
        if(localData != nil) {

            id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
            if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
                
                NSLog(@"results from postfile: %@", object);
                
                [self loadThreads:false];
                upload_success = YES;
                
            }
            
        } else {
            NSLog(@"uploadSnap timed out.");
            
            UIAlertView *upload_failed = [[UIAlertView alloc] initWithTitle:@"upload failed :(" message:@"oh no, the snap didn't make it to the server. do you want to try to upload this again?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"try upload again", nil];
            [upload_failed show];
            
        }
        
    }
    
    NSLog(@".. and we done");
    
    return upload_success;
}

- (BOOL)startThread:(NSString *)toHandle forKey:(NSString *)key withCaption:(NSString *)caption withLocation:(NSString *)location withFont:(NSString *)font withTextColor:(NSString *)textColor
{
    
    BOOL start_convo_success = NO;
    
	// Create a new letter and POST it to the server
    
    
    
    
    NSDictionary *checkDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               toHandle, @"toGuid",
                               key, @"groupKey",
                               caption, @"caption",
                               location, @"location",
                               font, @"font",
                               textColor, @"textColor",
                               nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:checkDict options:kNilOptions error:&error];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/thread";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
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
            
            NSLog(@"results from startConvo: %@", object);
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"result"] integerValue];
            
            if(response_result == 0) {
                start_convo_success = NO;
            } else {
                start_convo_success = YES;
                
                [self uploadSnap:key];
                
            }
            
        }
        
    }
    
    return start_convo_success;
}

- (BOOL)addContact:(NSString *)handle
{
    NSLog(@"Add contact: %@", handle);
    
    BOOL added_contact = NO;
    
    NSError *error = nil;
    
    NSData *jsonData;
    [jsonData setValue:handle forKey:@""];
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSString stringWithFormat:@"=%@",handle] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/follower";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    
    if(error == nil) {
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:data];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from add_contact: %@", object);
            
            NSInteger result = [[object objectForKey:@"result"] integerValue];
            
            if(result == 1) {

                RODHandle *new_contact = [[RODHandle alloc] init];
                new_contact.publicKey = [object objectForKey:@"message"];
                new_contact.name = handle;
                
                // okay, now we show create screen
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.selectContactViewController setSelected:new_contact];
                [appDelegate.selectContactViewController showAuthorizationRequestImagePicker];
                
                
            } else {
                
                NSString *message = [object objectForKey:@"message"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
            }

        }
        
    } else {
        NSLog(@"Error: %@", error);
    }
    
    return added_contact;
}


- (void) authorizeContact:(NSString *)publicKey;
{
    NSLog(@"authorizeContact: %@", publicKey);
    
    NSError *error = nil;
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSString stringWithFormat:@"=%@", publicKey] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/authorize";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    
    if(error == nil) {
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:data];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from authorizeContact: %@", object);
            
            NSInteger result = [[object objectForKey:@"result"] integerValue];
            
            if(result == 1) {

                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];
                
                [self loadThreads:false];
                [self loadContacts];
                
            } else {
                
                NSString *message = [object objectForKey:@"message"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
            }
            
        }
        
    } else {
        NSLog(@"Error: %@", error);
    }
    
}

- (void)addBlock:(NSString *)publicKey
{
    
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/block/%@", publicKey];
    NSLog(@"addBlock: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    
    if(error == nil) {
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingAllowFragments error:&deserialize_error];
        
        if([object isKindOfClass:[NSDictionary class]] && deserialize_error == nil) {
            
            NSLog(@"results from block: %@", object);
            
            NSInteger response_result;
            response_result = [[object objectForKey:@"active"] integerValue];
            
            if(response_result == 1) {

                NSMutableArray *tempContacts = [NSMutableArray arrayWithArray:self.authie.allContacts];
                for(RODHandle *r in tempContacts) {
                    if([r.publicKey isEqualToString:publicKey]) {
                        [self.authie.allContacts removeObject:r];
                        [self saveChanges];
                        NSLog(@"Contact found and removed.");
                        break;
                    }
                    
                }
                
                [self loadContacts];
                
            }
            
            
        }
        
    } else {
        NSLog(@"Error: %@", error);
    }
    
    [self saveChanges];
    
}

- (void)loadBlocks
{
    NSLog(@"loadBlocks called.");
}

- (int)unreadMessagesFor:(NSString *)thread handle:(NSString *)contactHandle
{

    // time to count the unread messages...
    NSArray *tempMessages = [NSArray arrayWithArray:[RODItemStore sharedStore].authie.allMessages];
    NSArray *tempContacts = [NSArray arrayWithArray:[RODItemStore sharedStore].authie.allContacts];
    
    int unread = 0;
    
    NSString *contactPublicKey;
    for(RODHandle *h in tempContacts) {
        if([h.name isEqualToString:contactHandle]) {
            contactPublicKey = h.publicKey;
            break;
        }
    }
    
    for (int x = 0; x<[tempMessages count]; x++) {
        
        RODMessage *m = [tempMessages objectAtIndex:x];
        

        if([m.thread.groupKey isEqualToString:thread] && [m.fromHandle.name isEqualToString:contactHandle] && [m.toKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey]) {
        
            //NSLog(@"read: %@, %@", m.messageText, [m.seen stringValue]);
            
            if([m.seen isEqualToNumber:[NSNumber numberWithInt:0]]) {
                //NSLog(@"Unread: %@", m.messageText);
                unread++;
            }
            
            if([m.localNotificationSent isEqualToNumber:[NSNumber numberWithInt:0]]) {
                [self sendLocalNotification:m];
                RODMessage *updateMessage = [[RODItemStore sharedStore].authie.allMessages objectAtIndex:x];
                [updateMessage setLocalNotificationSent:[NSNumber numberWithInt:1]];
            }
            
        }
    }

    return unread;
    
}

- (int)unreadMessages
{
    // time to count the unread messages...
    NSArray *tempMessages = [NSArray arrayWithArray:[RODItemStore sharedStore].authie.allMessages];
    int unread = 0;
    for (int x = 0; x<[tempMessages count]; x++) {
        
        RODMessage *m = [tempMessages objectAtIndex:x];
        if([m.seen isEqualToNumber:[NSNumber numberWithInt:0]]) {
            
            if([m.fromHandle.publicKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey]) {
                // ignore
            } else {
                //NSLog(@"Unread: %@", m.messageText);
                unread++;
            }
        }
        
        if([m.localNotificationSent isEqualToNumber:[NSNumber numberWithInt:0]]) {
            [self sendLocalNotification:m];
            RODMessage *updateMessage = [[RODItemStore sharedStore].authie.allMessages objectAtIndex:x];
            [updateMessage setLocalNotificationSent:[NSNumber numberWithInt:1]];
        }
    }
    
    [[UAPush shared] setBadgeNumber:unread];    
    
    return unread;
}

- (void)sendLocalNotification:(RODMessage *)msg
{
    
    if([msg.fromHandle.name isEqualToString:[RODItemStore sharedStore].authie.handle.name]) {
        
        // don't send local notes if you are the one that sent the message...
        return;
    }
    
    
    if([msg.localNotificationSent isEqualToNumber:[NSNumber numberWithInt:0]]) {
        UILocalNotification *note = [[UILocalNotification alloc] init];
        note.alertBody = [NSString stringWithFormat:@"%@ said: %@", msg.fromHandle.name, msg.messageText];
        note.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:note];
        NSLog(@"Sent note: %@", msg.messageText);
    }
    
}

- (void)markMessageAsRead:(NSNumber *)id
{

    
    // mark the message as read so we do not send another
    // local notification after the fact
    for (RODMessage *m in [RODItemStore sharedStore].authie.allMessages) {
        
        if([m.id isEqualToNumber:id]) {
            
            m.localNotificationSent = [NSNumber numberWithInt:1];
            
        }
    }

    
}

- (void)markRead
{
    // time to count the unread messages...
    for (RODMessage *m in [RODItemStore sharedStore].authie.allMessages) {
        m.seen = [NSNumber numberWithInt:1];
    }
    [[UAPush shared] setBadgeNumber:0];
}


- (BOOL)loadContacts
{
    
    BOOL loaded_contacts = NO;
    
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = @"https://authie.me/api/follower";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(localData == nil) {
            // error
            NSLog(@"loadContacts error: %@", error);
            return false;             
        }
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&deserialize_error];
        
        if([object isKindOfClass:[NSArray self]] && deserialize_error == nil) {
            
            // clear all old contacts
            [self.authie.allContacts removeAllObjects];
            
            for (NSDictionary *result in object) {
                
                RODHandle *followeeHandle = [[RODHandle alloc] init];
                
                NSDictionary *from_result = [result objectForKey:@"followeeHandle"];
                
                followeeHandle.name = [from_result objectForKey:@"name"];
                followeeHandle.publicKey = [from_result objectForKey:@"publicKey"];
                
                NSString *mRS = [result objectForKey:@"mostRecentSnap"];
                
                followeeHandle.mostRecentSnap = mRS;
                                
                [self.authie.allContacts addObject:followeeHandle];
                
            }

            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //[appDelegate.contactsViewController.tableView reloadData];
            //[appDelegate.contactsViewController.refreshControl endRefreshing];
                        
            loaded_contacts = YES;
            
        } else {
            NSLog(@"Not that kind of object: %@, deserialize_error: %@", object, deserialize_error);
        }
        
    }
    
    return loaded_contacts;
}

- (BOOL)loadThreads:(bool)isWire
{
    BOOL loaded_convos = NO;
    
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    
    NSString *url;
    
    if(isWire == NO) {
        url = [NSString stringWithFormat:@"https://authie.me/api/thread/%i", self.currentPage];
    } else {
        url = @"https://authie.me/api/wire";
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(localData == nil) {
            // how do we get out of this gracefully?
            NSLog(@"loadThreads error: %@", error);
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [MRProgressOverlayView dismissAllOverlaysForView:appDelegate.dashViewController.view animated:YES];
            
            return false;
        }
        
        if([localData length] == 0)
        {
            NSLog(@"Length was zero...");
        }

        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&deserialize_error];
        if([object isKindOfClass:[NSArray self]] && deserialize_error == nil) {
            
            if(isWire == YES) {
                [self.wireThreads removeAllObjects];
            } else {
                // lol now we want to clear everything...
                [self.authie.allThreads removeAllObjects];
            }
            
            for (NSDictionary *result in object) {
                
                //NSLog(@"loadThreads: %@", result);
                NSInteger id_result = [[result objectForKey:@"id"] integerValue];
                
                // replace them with the new ones
                RODThread *thready = [[RODThread alloc] init];
                thready.id = [NSNumber numberWithInteger:id_result];
                                
                NSDictionary *inner_result = [result objectForKey:@"toHandle"];
                NSString *to_result = [inner_result objectForKey:@"name"];
                NSString *to_publicKey = [inner_result objectForKey:@"publicKey"];
                
                NSDictionary *from_inner_result = [result objectForKey:@"fromHandle"];
                NSString *from_result = [from_inner_result objectForKey:@"name"];
                NSString *from_publicKey = [from_inner_result objectForKey:@"publicKey"];
                
                NSArray *convos_result = [result objectForKey:@"convos"];
                
                thready.convos = [[NSMutableArray alloc] init];
                
                for(NSDictionary *convo in convos_result) {
                    
                    NSString *name = [convo objectForKey:@"name"];
                    [thready.convos addObject:name];
                    
                }
                
                RODHandle *fromHandle = [[RODHandle alloc] init];
                fromHandle.name = from_result;
                fromHandle.publicKey = from_publicKey;
                
                thready.fromHandle = fromHandle;
                
                RODHandle *toHandle = [[RODHandle alloc] init];
                toHandle.name = to_result;
                toHandle.publicKey = to_publicKey;
                
                thready.toHandle = toHandle;
                
                thready.textColor = [result objectForKey:@"textColor"];
                thready.font = [result objectForKey:@"font"];
                thready.groupKey = [result objectForKey:@"groupKey"];
                thready.toHandleId = to_result;
                thready.fromHandleId = from_result;
                
                NSString *caption_result = [result objectForKey:@"caption"];
                thready.caption = caption_result;
                
                NSString *location_result = [result objectForKey:@"location"];
                thready.location = location_result;
                
                NSInteger uploadSuccessful = [[result objectForKey:@"uploadSuccess"] integerValue];
                
                if(uploadSuccessful == 0) {
                    thready.successfulUpload = NO;
                } else {
                    thready.successfulUpload = YES;
                }
                
                NSInteger hearts = [[result objectForKey:@"hearts"] integerValue];
                NSInteger authorizeRequest = [[result objectForKey:@"authorizeRequest"] integerValue];
                
                id toHandleSeen_result = [result objectForKey:@"toHandleSeen"];
                if(toHandleSeen_result == [NSNull null]) {
                    thready.toHandleSeen = 0;
                } else {
                    thready.toHandleSeen = [NSNumber numberWithInteger:[toHandleSeen_result integerValue]];
                }
                
                
                thready.hearts = [NSNumber numberWithInteger:hearts];
                thready.authorizeRequest = [NSNumber numberWithInteger:authorizeRequest];
                
                NSString *silly_date = [result objectForKey:@"startDate"];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                
                //The Z at the end of your string represents Zulu which is UTC
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                
                thready.startDate = [dateFormatter dateFromString:silly_date];
                
                // remove thread with existing groupKey
                NSMutableArray *tempThreads = [NSMutableArray arrayWithArray:self.authie.allThreads];
                for(RODThread *t in tempThreads) {
                    if([t.groupKey isEqualToString:thready.groupKey]) {
                        
                        if(isWire == YES) {
                            [self.wireThreads removeObject:t];
                        } else {
                            [self.authie.allThreads removeObject:t];
                        }
                        //break;
                    }
                }
                
                NSString *upload = @"";
                if(thready.successfulUpload == NO && [thready.fromHandle.publicKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey]) {
                    
                    // if we're in this situation,
                    // there's a snap that failed to up load
                    [self uploadSnap:thready.groupKey];

                }
                
                NSLog(@"added thread from %@ to %@, %@, %@", thready.fromHandleId, thready.toHandleId, thready.groupKey, upload);

                if(isWire ==  YES) {
                    [self.wireThreads addObject:thready];
                } else {
                    [self.authie.allThreads addObject:thready];
                }
                
            }
            
            [self saveChanges];
            
            // disabling this so entire thread can run on background thread with no black camera issues
            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //[appDelegate.dashViewController populateScrollView];
            
            loaded_convos = YES;
            
        } else {
            NSLog(@"loadThreads: %@, deserialize_error: %@", object, deserialize_error);
        }
        
    }

    return loaded_convos;
}

- (BOOL)getThreadsFromHandle:(NSString *)publicKey
{
    BOOL loaded_threads = NO;

    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/threads/%@", publicKey];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&deserialize_error];
        if([object isKindOfClass:[NSArray self]] && deserialize_error == nil) {
            
            // clear out old threads
            [self.loadedThreadsFromAuthor removeAllObjects];
            
            for (NSDictionary *result in object) {
                
                NSInteger id_result = [[result objectForKey:@"id"] integerValue];
                
                // replace them with the new ones
                RODThread *thready = [[RODThread alloc] init];
                thready.id = [NSNumber numberWithInteger:id_result];
                                
                NSDictionary *inner_result = [result objectForKey:@"toHandle"];
                NSString *to_result = [inner_result objectForKey:@"name"];
                
                NSDictionary *from_inner_result = [result objectForKey:@"fromHandle"];
                NSString *from_result = [NSString stringWithFormat:@"from: %@",[from_inner_result objectForKey:@"name"]];
                
                NSString *caption_result = [result objectForKey:@"caption"];
                thready.caption = caption_result;
                
                NSInteger hearts = [[result objectForKey:@"hearts"] integerValue];
                NSInteger authorizeRequest = [[result objectForKey:@"authorizeRequest"] integerValue];
                
                id toHandleSeen_result = [result objectForKey:@"toHandleSeen"];
                if(toHandleSeen_result == [NSNull null]) {
                    thready.toHandleSeen = 0;
                } else {
                    thready.toHandleSeen = [NSNumber numberWithInteger:[toHandleSeen_result integerValue]];
                }
                
                thready.hearts = [NSNumber numberWithInteger:hearts];
                thready.authorizeRequest = [NSNumber numberWithInteger:authorizeRequest];
                                
                thready.groupKey = [result objectForKey:@"groupKey"];
                thready.toHandleId = to_result;
                thready.fromHandleId = from_result;

                NSString *silly_date = [result objectForKey:@"startDate"];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                
                //The Z at the end of your string represents Zulu which is UTC
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                
                thready.startDate = [dateFormatter dateFromString:silly_date];                
                
                [self.loadedThreadsFromAuthor addObject:thready];
                
                [[RODImageStore sharedStore] downloadImage:thready.groupKey];
                                
            }
            
            loaded_threads = YES;
            
        } else {
            NSLog(@"Not that kind of object: %@, deserialize_error: %@", object, deserialize_error);
        }
        
    }
        
    return loaded_threads;
}

- (void)loadMessagesForThread:(NSString *)key;
{
    
    if(key == nil) {
        NSLog(@"loadMessagesForThread tried to load a null key.");
        return;
    }
    
    NSURLResponse *response;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/message/%@", key];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
        
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //send the request and get the response
    NSData *localData = nil;
    NSError *error = nil;

    localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(localData == nil) {
        NSLog(@"loadMessagesForThread error: %@", error);
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [MRProgressOverlayView dismissAllOverlaysForView:appDelegate.dashViewController.view animated:YES];
        return;
    }

    NSError *deserialize_error = nil;
    
    id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&deserialize_error];
    if([object isKindOfClass:[NSArray self]] && deserialize_error == nil) {
        
        // first, we want to remove all messages
        // that do not have an id set, these are messages
        // that are place holders, put there after the
        // message has been sent on the users side
        NSMutableArray *tempMessages = [NSMutableArray arrayWithArray:self.authie.allMessages  ];
        
        for(RODMessage *m in tempMessages) {
            if([m.thread.groupKey isEqualToString:key]) {
                if([m.id isEqualToNumber:[NSNumber numberWithInt:-1]]) {
                    [self.authie.allMessages removeObject:m];
                }
            }
        }
        
        for (NSDictionary *result in object) {
            
            RODMessage *message = [[RODMessage alloc] init];
            
            NSInteger id_result = [[result objectForKey:@"id"] integerValue];
            message.id = [NSNumber numberWithInteger:id_result];
            
            NSDictionary *handle_result = [result objectForKey:@"fromHandle"];
            
            RODHandle *fromHandle = [[RODHandle alloc] init];
            
            NSString *fromHandle_name = [handle_result objectForKey:@"name"];
            
            NSString *fromHandle_publicKey = [handle_result objectForKey:@"publicKey"];
            
            fromHandle.publicKey = fromHandle_publicKey;
            fromHandle.name = fromHandle_name;
            message.fromHandle = fromHandle;
            
            NSString *message_text = [result objectForKey:@"messageText"];
            message.messageText = message_text;
            
            NSString *message_date = [result objectForKey:@"sentDate"];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            
            //The Z at the end of your string represents Zulu which is UTC
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            
            message.sentDate = [dateFormatter dateFromString:message_date];
            
            
            NSDictionary *thread_result = [result objectForKey:@"thread"];
            
            RODThread *thread = [[RODThread alloc] init];
            
            NSString *groupKey = [thread_result objectForKey:@"groupKey"];
            thread.groupKey = groupKey;
            
            NSString *toKey = [result objectForKey:@"toKey"];
            message.toKey = toKey;
            
            message.thread = thread;
            message.seen = [NSNumber numberWithInt:0];
            message.localNotificationSent = [NSNumber numberWithInt:0];
            
            NSLog(@"Loaded message %@: '%@' from %@", message.id, message.messageText, message.fromHandle.name);
            
            NSMutableArray *tempMessages = [NSMutableArray arrayWithArray:self.authie.allMessages];
            
            for(RODMessage *r in tempMessages) {
                if([r.id isEqualToNumber:message.id]) {
                    
                    // we do want to co py whether or not it was seen
                    // before we remove the object
                    message.seen = r.seen;
                    message.localNotificationSent = r.localNotificationSent;
                    
                    NSLog(@"Removed old object, seen was: %@", r.seen);
                    [self.authie.allMessages removeObject:r];
                    break;
                }
                
                // why is it not removing old messages here? hmm
            }

            
            [self.authie.allMessages addObject:message];
            
        }
        
    } else {
        NSLog(@"loadMessagesFromThread error: %@", object);
    }
    
    [self saveChanges];
    
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate.threadViewController reloadThread];
    
}

- (void)testAES
{
    
    NSLog(@"testAES started...");
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/aes"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(localData == nil) {
            // bail out...
            NSLog(@"Error. bail.");
            return;
        }
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&deserialize_error];
        
        if([object isKindOfClass:[NSArray self]] && deserialize_error == nil) {
            NSLog(@"Received: %@", object);
        } else {
            NSLog(@"localData: %@", localData);
            NSLog(@"object: %@", object);
            
            
//            NSString *encryptedText = [object valueForKey:@"message"];
//            
//            NSData *decryptedData = [RNDecryptor decryptData:encryptedText
//                                                withPassword:@"SETHAwQFBgcICQoLDA0ODw=="
//                                                       error:&error];
//            NSString *decrypt = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//            NSLog(@"decrypt: %@", decrypt);
            
        }
    }

}

- (void)loadMessages:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    
    Boolean newData = NO;
    NSError *error = nil;
    
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSString *url = [NSString stringWithFormat:@"https://authie.me/api/message"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [request setHTTPMethod:@"GET"];
    
    if(error == nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //send the request and get the response
        localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(localData == nil) {
            // bail out...
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [MRProgressOverlayView dismissAllOverlaysForView:appDelegate.dashViewController.view animated:YES];
            
            
            if(completionHandler != nil) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            
            return;
        }
        
        NSError *deserialize_error = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&deserialize_error];
        if([object isKindOfClass:[NSArray self]] && deserialize_error == nil) {
            
            // clear out old messages.. is this what we really want to do?
            //[self.authie.allMessages removeAllObjects];
            
            for (NSDictionary *result in object) {
                
                Boolean foundNewThread = true;
                
                RODMessage *message = [[RODMessage alloc] init];
                
                NSInteger id_result = [[result objectForKey:@"id"] integerValue];
                message.id = [NSNumber numberWithInteger:id_result];
                
                NSDictionary *handle_result = [result objectForKey:@"fromHandle"];
                
                RODHandle *fromHandle = [[RODHandle alloc] init];
                
                NSString *fromHandle_name = [handle_result objectForKey:@"name"];
                
                NSString *fromHandle_publicKey = [handle_result objectForKey:@"publicKey"];
                
                fromHandle.publicKey = fromHandle_publicKey;
                fromHandle.name = fromHandle_name;
                message.fromHandle = fromHandle;
                
                NSString *message_text = [result objectForKey:@"messageText"];
                message.messageText = message_text;
                
                NSString *message_date = [result objectForKey:@"sentDate"];
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                
                //The Z at the end of your string represents Zulu which is UTC
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                
                message.sentDate = [dateFormatter dateFromString:message_date];
                
                
                NSDictionary *thread_result = [result objectForKey:@"thread"];
                
                RODThread *thread = [[RODThread alloc] init];
                
                NSString *groupKey = [thread_result objectForKey:@"groupKey"];
                thread.groupKey = groupKey;
                
                NSString *toKey = [result objectForKey:@"toKey"];
                message.toKey = toKey;
                
                message.thread = thread;
                message.seen = [NSNumber numberWithInt:0];
                message.localNotificationSent = [NSNumber numberWithInt:0];
  
                NSLog(@"Loaded message %@: '%@' from %@, to %@, seen: %@, date: %@", message.id, message.messageText, message.fromHandle.name, message.toKey, message.seen, message.sentDate);
                
                // now, efore we add it, we need to check to see if there
                // is an existing message in the database, if so, we want to
                // remove tha tone...
                // first, we want to remove all messages
                // that do not have an id set, these are messages
                // that are place holders, put there after the
                // message has been sent on the users side
                NSMutableArray *tempMessages = [NSMutableArray arrayWithArray:self.authie.allMessages  ];
                
                for(RODMessage *r in tempMessages) {
                    if([r.thread.groupKey isEqualToString:groupKey]) {
                        if([r.id isEqualToNumber:[NSNumber numberWithInt:-1]]) {
                            [self.authie.allMessages removeObject:r];
                            foundNewThread = false;
                            
                            message.seen = [NSNumber numberWithInt:1];
                            message.localNotificationSent = [NSNumber numberWithInt:1];
                            
                            break;
                        }
                    }
                    
                    if([r.id isEqualToNumber:message.id]) {
                        //NSLog(@"Removed old object.");
                        
                        message.seen = r.seen;
                        message.localNotificationSent = r.localNotificationSent;
                        
                        [self.authie.allMessages removeObject:r];
                        foundNewThread = false;
                        break;
                    }
                }

                //NSLog(@"Loaded message %@: '%@' from %@", message.id, message.messageText, message.fromHandle.name);
                
                if(foundNewThread == YES && newData == NO) {
                    newData =  YES;
                }
                
                [self.authie.allMessages addObject:message];
                
            }
            
            // after all the looping,
            // we want to just check real quick to make sure
            // that there are no failed chat messages to be sent
            // as well...
            
            [self retrySendingFailedChats];
            
            
        } else {
            NSLog(@"loadMessages error: %@", object);
            
            if(completionHandler != nil) {
                completionHandler(UIBackgroundFetchResultFailed);
            }

        }
        
        if(completionHandler != nil) {
            
            if(newData == YES) {
                completionHandler(UIBackgroundFetchResultNewData);
                NSLog(@"-- Result is NewData");
            } else {
                completionHandler(UIBackgroundFetchResultNoData);
                NSLog(@"-- Result is NoData");
            }
            
        }
        
        //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate.threadViewController reloadThread];
        
    }
    

    
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
    
    NSString *url = @"https://authie.me/api/checkhandle";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
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
    
    NSString *url = @"https://authie.me/api/handle";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
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
            
            NSInteger id_result;
            id_result = [[object objectForKey:@"id"] integerValue];
            
            NSString *privateKey;
            privateKey = [object objectForKey:@"privateKey"];
            
            NSString *publicKey;
            publicKey = [object objectForKey:@"publicKey"];
            
            NSString *name;
            name = [object objectForKey:@"name"];
            
            NSString *userGuid;
            userGuid = [object objectForKey:@"userGuid"];
                        
            if(active_result == 1) {
                registered_result = YES;
                [self.authie setRegistered:1];
                
                self.authie.handle = [[RODHandle alloc] init];

                [self.authie.handle setId:[NSNumber numberWithInteger:id_result]];
                [self.authie.handle setName:name];
                [self.authie.handle setActive:[NSNumber numberWithInteger:active_result]];
                [self.authie.handle setUserGuid:userGuid];
                [self.authie.handle setPrivateKey:privateKey];
                [self.authie.handle setPublicKey:publicKey];
                
                
                [self.authie setPrivateKey:privateKey];
                
                // Sets the alias. It will be sent to the server on registration.
                [UAPush shared].alias = self.authie.handle.publicKey;
                [[UAPush shared] updateRegistration];
                
                [self loadContacts];
                
                NSLog(@"id: %lu, privateKey: %@, publicKey: %@", [self.authie.handle.id longValue], self.authie.handle.privateKey, self.authie.handle.publicKey);
                
                [self saveChanges];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];
                
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


- (UIBarButtonItem *)generateAddPersonMenuItem
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"add-person-v2"] forState:UIControlStateNormal];
    [button_menu addTarget:appDelegate.selectContactViewController action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    
    return leftDrawerButton;
}


- (UIBarButtonItem *)generateMenuItem:(NSString *)image
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button_menu addTarget:appDelegate.navigationViewController action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    
    return leftDrawerButton;
}

-(UIView *)generateHeaderView
{
    UIView *holder = [[UIView alloc] init];
    [holder setFrame:CGRectMake(0, 0, 100, 40)];
    
    UIImage *image = [UIImage imageNamed:@"authie-logo-v5-ocr-a"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    [imageview setFrame:CGRectMake(0, 5, 100, 15)];
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
    
    [holder addSubview:imageview];
    
    UILabel *handleLabel = [[UILabel alloc] init];
    handleLabel.text = [RODItemStore sharedStore].authie.handle.name;
    [handleLabel setFont:[UIFont systemFontOfSize:10]];
    [handleLabel setFrame:CGRectMake(0, 18, 100, 20)];
    [handleLabel setTextAlignment:NSTextAlignmentCenter];
    [handleLabel setTextColor:[UIColor whiteColor]];
    
    [holder addSubview:handleLabel];
    
    return holder;
}

-(UIView *)generateWireHeaderView
{
    UIView *holder = [[UIView alloc] init];
    [holder setFrame:CGRectMake(0, 0, 100, 40)];
    
    UIImage *image = [UIImage imageNamed:@"thewire-logo-v2"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    [imageview setFrame:CGRectMake(0, 5, 100, 15)];
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
    
    [holder addSubview:imageview];
    
    UILabel *handleLabel = [[UILabel alloc] init];
    handleLabel.text = @"recent auth";
    [handleLabel setFont:[UIFont systemFontOfSize:10]];
    [handleLabel setFrame:CGRectMake(0, 18, 100, 20)];
    [handleLabel setTextAlignment:NSTextAlignmentCenter];
    [handleLabel setTextColor:[UIColor whiteColor]];
    
    [holder addSubview:handleLabel];
    
    return holder;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection failed withError: %@", error);
    
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    NSLog(@"SRConnectionDidClose.");
    
}

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    NSLog(@"SRConnectionDidOpen.");
    
    // register with the server for new messages/threads events
    
}

- (void)SRConnectionDidReconnect:(SRConnection *)connection
{
    NSLog(@"SRConnectionDidReconnect");
    
}

- (void)pushThreadWithGroupKey:(NSString *)group_key from:(NSString *)fromKey
{
    NSLog(@"pushThreadWithGroupKey:");
    RODThread *thread;
    
    for(int i = 0; i< [[RODItemStore sharedStore].authie.all_Threads count]; i++)
    {
        thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:i];
        if([thread.groupKey isEqualToString:group_key]) {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            appDelegate.threadViewController = [[ThreadViewController alloc] init];
            
            
            for(RODHandle *r in [RODItemStore sharedStore].authie.allContacts) {
                if([r.publicKey isEqualToString:fromKey]) {
                    appDelegate.threadViewController.toHandle = r;
                    break;
                }
            }
            
            [appDelegate.threadViewController loadThread:i];
            [appDelegate.threadViewController reloadThread];
            [appDelegate.dashViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
            
            break;
        }
    }
    
}

- (void)retrySendingFailedChats
{
    
    NSLog(@"Retrying sending messages...");
    
    NSArray *tempChats = [NSArray arrayWithArray:self.authie.failedChats];
    
    for(RODChat *c in tempChats) {
        
        // remove the item first, if it fails it will go right back in anyway
        [self.authie.failedChats removeObject:c];
        
        NSLog(@"Sending failed message: %@", c.message);
        
        [self sendChat:c.groupKey message:c.message toKey:c.toKey];
        
    }
    
}

- (void)addChat:(NSString *)user message:(NSString *)message groupKey:(NSString *)groupKey toKey:(NSString *)toKey;
{
    RODMessage *msg = [[RODMessage alloc] init];
    
    RODHandle *from = [[RODHandle alloc] init];
    RODHandle *to = [[RODHandle alloc] init];

    msg.id = [NSNumber numberWithInt:-1];
    msg.sentDate = [NSDate date];
    msg.toKey = toKey;
    msg.seen = [NSNumber numberWithInt:1];
    
    RODThread *t;
    for(int i = 0; i<[self.authie.all_Threads count]; i++) {
        t = [self.authie.all_Threads objectAtIndex:i];
        if([t.groupKey isEqualToString:groupKey]) {
            break;
        }
    }
    
    if([user isEqualToString:self.authie.handle.name]) {
        from.name = self.authie.handle.name;
        from.publicKey = self.authie.handle.publicKey;
        to.name = user;
        to.publicKey = toKey;
    } else {
        from.name = user;
        from.publicKey = toKey;
        
        to.publicKey = self.authie.handle.publicKey;
        to.name = self.authie.handle.name;
    }

    
    msg.messageText = message;
    msg.fromHandle = from;
    msg.thread = t;
    
    [self.authie.allMessages addObject:msg];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.threadViewController reloadThread];
    
    NSLog(@"Chat added.");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
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
