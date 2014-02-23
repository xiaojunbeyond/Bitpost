//
//  BMDatabase.m
//  Bitmessage
//
//  Created by Steve Dekorte on 2/23/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import "BMDatabase.h"

@implementation BMDatabase

- (id)init
{
    self = [super init];
    self.name = @"default";
    return self;
}
// --- read / write ---

- (NSString *)dbKey
{
    return [NSString stringWithFormat:@"BMDB_%@", self.name];
}

- (void)setName:(NSString *)name
{
    _name = name;
    [self read];
}

- (void)read
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:self.dbKey];
    
    if (dict)
    {
        self.dict = [NSMutableDictionary dictionaryWithDictionary:dict]; // WARNING: only works for 1 level
    }
    else
    {
        self.dict = [NSMutableDictionary dictionary];
        
    }
}

- (void)write
{
    [[NSUserDefaults standardUserDefaults] dictionaryForKey:self.dbKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// --- mark ---

- (void)mark:(NSString *)messageId
{
    NSNumber *d = [NSNumber numberWithLong:[[NSDate date] timeIntervalSinceReferenceDate]];
    
    if ([self.dict objectForKey:messageId] == nil)
    {
        [self.dict setObject:d forKey:messageId];
    }
    
    [self write];
}

- (BOOL)isMarked:(NSString *)messageId
{
    return [self.dict objectForKey:messageId] != nil;
}

- (void)removeOldKeys
{
    for (NSString *key in self.dict.allKeys)
    {
        NSNumber *d = [self.dict objectForKey:key];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[d longLongValue]];
        if ([date timeIntervalSinceNow] > 60*60*24*10) // ten days
        {
            [self.dict removeObjectForKey:key];
        }
    }
    [self write];
}

@end
