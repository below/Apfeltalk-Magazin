//
//  Story.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "Story.h"


@implementation Story
@synthesize title, summary, date, author, link, saved;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		if ([aDecoder allowsKeyedCoding]) {
			[self setTitle:[aDecoder decodeObjectForKey:@"title"]];
			[self setSummary:[aDecoder decodeObjectForKey:@"summary"]];
			[self setDate:[aDecoder decodeObjectForKey:@"date"]];
			[self setAuthor:[aDecoder decodeObjectForKey:@"author"]];
			[self setLink:[aDecoder decodeObjectForKey:@"link"]];
            [self setSaved:[aDecoder decodeBoolForKey:@"saved"]];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[self title] forKey:@"title"];
	[aCoder encodeObject:[self summary] forKey:@"summary"];
	[aCoder encodeObject:[self date] forKey:@"date"];
	[aCoder encodeObject:[self author] forKey:@"author"];
	[aCoder encodeObject:[self link] forKey:@"link"];
    [aCoder encodeObject:[self isSaved] forKey:@"saved"];
}

- (void) dealloc
{
	[title release];
	[summary release];
	[date release];
	[author release];
	[link release];
	[super dealloc];
}

@end
