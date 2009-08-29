//
//  DetailNews.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "DetailNews.h"

@implementation DetailNews
@synthesize showSave, story;

// This is the new designated initializer for the class
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle story:newStory];
	if (self != nil) {
		showSave = YES;
	}
	return self;
}

- (NSString *) storyTitle {
	return [story title];
}

- (NSString *) selectedSumary {
	return [story summary];
}
- (NSDate *) date {
	return [story date];
}
- (NSString *) author {
	return [story author];
}

@end
