//
//  NewsController.h
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface NewsController : RootViewController {
	@private
	NSMutableArray *savedStories;
}

- (void) addSavedStory:(Story *)newStory;
@end
