//
//  RootViewController.h
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DetailViewController.h"
#import "Story.h"

@interface RootViewController : UITableViewController {
	
	IBOutlet UITableView * newsTable;
		
	UIActivityIndicatorView * activityIndicator;
	
	CGSize cellSize;
		
	NSMutableArray * stories;
		
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	@protected
	Story *item;
		
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;

	NSMutableString * currentText;
	sqlite3 * database;
	NSDateFormatter *dateFormatter;
@private
	NSArray *desiredElementKeysCache;

}

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)openSafari:(id)sender;
- (IBAction)about:(id)sender;
- (NSString *) supportFolderPath;

+ (NSDate *) oldestStoryDate;
+ (void) setOldestStoryDate:(NSDate *)date;
- (Class) detailControllerClass;
- (Class) storyClass;
- (NSDateFormatter *) dateFormatter;
- (NSArray *) desiredElementKeys;
@end
