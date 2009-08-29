//
//  NewsController.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "NewsController.h"
#import "DetailNews.h"

@implementation NewsController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section != 1)
		return [super tableView:tableView numberOfRowsInSection:section];
	return [savedStories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([indexPath section] != 1) 
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	static NSString *CellIdentifier = @"SavedStory";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
   }
    
	
	int storyIndex = [indexPath row];
	// This cries for some more refactoring
	
	cell.textLabel.text = [[savedStories objectAtIndex: storyIndex] objectForKey: @"title"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] != 1) {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
		 return;
	}
		
	// Navigation logic
	
	// Again, this really cries for some more thinking and some more refactoring
	Story *story = [savedStories objectAtIndex: indexPath.row];
	Class detailClass = [self detailControllerClass];
	
	DetailNews *detailController = [[detailClass alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]
																  story:story];
	
	[detailController setShowSave:NO];
	
	[self.navigationController pushViewController:detailController animated:YES];
}

- (BOOL) saveStories {
	NSString *error;
	NSData * data = [NSPropertyListSerialization dataFromPropertyList:savedStories
															   format:NSPropertyListXMLFormat_v1_0
													 errorDescription:&error];
	
	return NO;
}
@end
