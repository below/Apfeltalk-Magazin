//
//  Story.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "Story.h"


@implementation Story
@synthesize title, summary, date, author, link;

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
