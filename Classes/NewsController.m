//
//  NewsController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Michael Fenske, Jesper (Graphics),
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

#import "NewsController.h"
#import "DetailNews.h"

@interface NewsController (private)
- (NSString *) savedStoryFilepath;
- (BOOL) saveStories;
@end

@implementation NewsController

- (void)viewWillAppear:(BOOL)animated {
	savedStories = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self savedStoryFilepath]] mutableCopy];
	[super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section != 1)
		return [super tableView:tableView numberOfRowsInSection:section];
	return [savedStories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section != 1)
		return @"";
	
	return NSLocalizedString (@"Gespeicherte News", @"");
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
	
	cell.textLabel.text = [[savedStories objectAtIndex: storyIndex] title];
	
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

- (Class) detailControllerClass {
	return [DetailNews self];
}

- (void) addSavedStory:(Story *)newStory {
	if (savedStories == nil)
		savedStories = [NSMutableArray new];
	[savedStories addObject:newStory];
	[self saveStories];
	[newsTable reloadData];
}

- (BOOL)isSavedStory:(Story *)story {
    BOOL result = NO;
    NSString *storyLink = [story link];

    for (Story *savedStory in savedStories)
    {
        if ([storyLink isEqualToString:[savedStory link]])
            result = YES;
    }

    return result;
}

- (NSString *) savedStoryFilepath {
	return [[self supportFolderPath] stringByAppendingPathComponent:@"saved.ATStories"];
}

- (BOOL) saveStories {
	return [NSKeyedArchiver archiveRootObject:savedStories toFile:[self savedStoryFilepath]];
}

- (void) dealloc {
	[savedStories release];
	[super dealloc];
}
@end
