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
        prettyTimestamp = @"1m";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%dm", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"1h";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%dh", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {
        prettyTimestamp = @"1d";
    } else if (delta < ( 86400 * 3 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%dd ", (int) floor(delta/86400.0) ];
    } else {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M.d.yyyy"];
        
        prettyTimestamp = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self]];
    }
    
    return prettyTimestamp;
}

@end