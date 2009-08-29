//
//  DetailNews.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "DetailNews.h"
#import "NewsController.h"

@implementation DetailNews
@synthesize showSave;

// This is the new designated initializer for the class
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle story:newStory];
	if (self != nil) {
		showSave = YES;
	}
	return self;
}

-(IBAction)speichern:(id)sender
{
	// This is an ugly hack
	UINavigationController *navController = [self navigationController];
	NSArray *controllers = [navController viewControllers];
	
	NewsController *newsController = (NewsController*) [controllers objectAtIndex:[controllers count] -2];
	[newsController addSavedStory:[self story]];
}

@end
