//
//  ImageCache.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
//						Patrick Rollbis (Graphics),
//						
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.//
//

#import "ImageCache.h"
#import "ImageCacheObject.h"

@implementation ImageCache

@synthesize totalSize;

-(id)initWithMaxSize:(NSUInteger) max  {
    if (self = [super init]) {
        totalSize = 0;
        maxSize = max;
        myDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)dealloc {
    [myDictionary release];
    [super dealloc];
}

-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key{
    ImageCacheObject *object = [[ImageCacheObject alloc] initWithSize:sz Image:image];
    while (totalSize + sz > maxSize) {
        NSDate *oldestTime = nil;
        NSString *oldestKey = nil;
        for (NSString *key in [myDictionary allKeys]) {
            ImageCacheObject *obj = [myDictionary objectForKey:key];
            if (oldestTime == nil || [obj.timeStamp compare:oldestTime] == NSOrderedAscending) {
                oldestTime = obj.timeStamp;
                oldestKey = key;
            }
        }
        if (oldestKey == nil) 
            break; // shoudn't happen
        ImageCacheObject *obj = [myDictionary objectForKey:oldestKey];
        totalSize -= obj.size;
        [myDictionary removeObjectForKey:oldestKey];
    }
    [myDictionary setObject:object forKey:key];
    [object release];
}

-(UIImage*)imageForKey:(NSString*)key {
    ImageCacheObject *object = [myDictionary objectForKey:key];
    if (object == nil)
        return nil;
    [object resetTimeStamp];
    return object.image;
}

@end
