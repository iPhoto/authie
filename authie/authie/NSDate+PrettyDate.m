//
//  NSDate+PrettyDate.m
//  authie
//
//  http://stackoverflow.com/questions/5741952/smart-formatting-of-time-span
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "NSDate+PrettyDate.h"

@implementation NSDate (PrettyDate)

- (NSString *)prettyDate
{
    NSString * prettyTimestamp;
    
    float delta = [self timeIntervalSinceNow] * -1;
    
    if (delta < 60) {
        prettyTimestamp = @"just now";
    } else if (delta < 120) {
        prettyTimestamp = @"one minute ago";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%d minutes ago", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"one hour ago";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%d hours ago", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {
        prettyTimestamp = @"one day ago";
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%d days ago", (int) floor(delta/86400.0) ];
    } else {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        prettyTimestamp = [NSString stringWithFormat:@"on %@", [formatter stringFromDate:self]];
    }
    
    return prettyTimestamp;
}

@end