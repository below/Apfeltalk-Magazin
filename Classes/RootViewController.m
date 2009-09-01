//
//  RootViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Jesper (Graphics),
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

#import "RootViewController.h"

@interface RootViewController (private)
- (BOOL) openDatabase;
- (NSString *) readDocumentsFilename; 
@end

static NSDate *oldestStoryDate = nil;

@implementation RootViewController
#pragma mark Class Methods
+ (NSDate *) oldestStoryDate {
	return oldestStoryDate;
}	

+ (void) setOldestStoryDate:(NSDate *)date {
	[oldestStoryDate release];
	oldestStoryDate = [date copy];
}

#pragma mark Instance Methods
//- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
//	if (( self = [super initWithNibName:nibName bundle:nibBundle] )) {
//		oldestStoryDate = [[NSDate distantPast] retain];
//	}
//	return self;
//}
//
//- (void)viewDidLoad {
	// Add the following line if you want the list to be editable
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
//}

- (IBAction)openSafari:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
}

- (IBAction)about:(id)sender {
	[newsTable reloadData];
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Credits" // oder einfach Wilkommen in der Touch-Mania.com Applikation?
						  message:@"Apfeltalk.de App \n \nIdee: Stephan König \nProgrammierung: Alexander von Below, Andreas Rami, Stefan Kofler, Michael Fenske und Stephan König \nSplashcreen: Patrick Rollbis \n Icons: Jesper Frommherz \n\nMit freundlicher Unterstützung der Apfeltalk GmbH"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:@"Kontakt"
						  ,nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:info@apfeltalk.de"]];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [stories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    
	// Configure the cell.
	
	int storyIndex = [indexPath row];
	// Everything below here is customization
		
	NSString * link = [[stories objectAtIndex: indexPath.row] link];
	BOOL read = [self databaseContainsURL:link];

	if (read){
		cell.imageView.image = [UIImage imageNamed:@"thread_dot.gif"];
	} else {
		cell.imageView.image = [UIImage imageNamed:@"thread_dot_hot.gif"];
	}

	cell.textLabel.text = [[stories objectAtIndex: storyIndex] title];

    return cell;
}

/*
 * This funktion checks to see if the given URL is in the database
 */
- (BOOL) databaseContainsURL:(NSString *)link {
	BOOL found = NO;
	
	const char *sql = "select url from read where url=?";
	sqlite3_stmt *statement;
	int error;
	
	error = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
	if (error == SQLITE_OK) {
		error = sqlite3_bind_text (statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT);
		if (error == SQLITE_OK && sqlite3_step(statement) == SQLITE_ROW) {
			found = YES;
		}
	}
	if (error != SQLITE_OK)
		NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
	error = sqlite3_finalize(statement);	
	if (error != SQLITE_OK)
		NSLog (@"An error occurred: %s", sqlite3_errmsg(database));

	return found;
}

- (NSString *) supportFolderPath {
	// This could be static
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	assert ([paths count]);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

- (NSString *) readDocumentsFilename {	 
	return [[self supportFolderPath] stringByAppendingPathComponent:@"gelesen.db"];
}

- (NSDateFormatter *) dateFormatter {
	if (dateFormatter == nil) {
		NSLocale *enLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:enLocale];	
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
	}
	return dateFormatter;
}

- (Class) detailControllerClass {
	return [DetailViewController self];
}

- (Class) storyClass {
	return [Story self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic
	
	Story *story = [stories objectAtIndex: indexPath.row];
	Class dvClass = [self detailControllerClass];
	DetailViewController *detailController = [[dvClass alloc] initWithNibName:@"DetailView" 
																	   bundle:[NSBundle mainBundle]
																		story:story];
	
	NSString * link = [story link];

	if ([link length] > 0 && ![self databaseContainsURL:link]) {
		NSDate *date = [[stories objectAtIndex: indexPath.row] date];
		
		const char *sql = "insert into read(url, date) values(?,?)"; 
		sqlite3_stmt *insert_statement;
		int error;
		error = sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL); 
		if (error == SQLITE_OK) {
			sqlite3_bind_text(insert_statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_double(insert_statement, 2, [date timeIntervalSinceReferenceDate]);
			error = (sqlite3_step(insert_statement) != SQLITE_DONE);
		}
		error = sqlite3_finalize(insert_statement);	
		
		/*
		 *	More thinking needs to go into the deletion of reads
		 *
		 sqlite3_stmt *delete_statement;
		 NSString *deleteSql = [NSString stringWithFormat:@"delete from read where date<%f", [[[self class] oldestStoryDate] timeIntervalSinceReferenceDate]];
		 error = sqlite3_prepare_v2(database, [deleteSql UTF8String], -1, &delete_statement, NULL); 
		 if (error != SQLITE_OK)
		 NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
		 
		 error = sqlite3_step(delete_statement); 
		 error = error != SQLITE_DONE;
		 
		 error = sqlite3_finalize(delete_statement);	
		 if (error != SQLITE_OK)
		 NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
		 */	
		[newsTable reloadData];
		
		// update the number of unread messages in Application Badge
		[self updateApplicationIconBadgeNumber];
	}
	
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}

- (BOOL) openDatabase {
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self readDocumentsFilename]])
	{
		NSError *error;
		NSString *dbResourcePath = [[NSBundle mainBundle] pathForResource:@"gelesen" ofType:@"db"];
		[[NSFileManager defaultManager] copyItemAtPath:dbResourcePath toPath:[self readDocumentsFilename] error:&error];
		// Check for errors...
	}
	
	if (sqlite3_open([[self readDocumentsFilename] UTF8String], &database) 
        == SQLITE_OK)
		return true;
	else 
		return false;
}

- (void)viewWillAppear:(BOOL)animated {
	[self openDatabase];
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	int error = sqlite3_close(database);
	assert (error == 0);
}

- (NSString *) documentPath {
	return @"http://feeds.apfeltalk.de/apfeltalk-magazin";
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	if ([stories count] == 0) {
		[self parseXMLFileAtURL:[self documentPath]];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	[desiredElementKeysCache release];
	desiredElementKeysCache = [self desiredElementKeys];
	[desiredElementKeysCache retain];
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
	stories = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
		
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
		
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	// This causes a bug. It has been filed with Apple as Bug ID 7180951    
	[rssParser release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

#pragma mark The things that can/should be subclassed should be grouped somehow
- (NSString *) summaryElementName {
	// It should be discussed if the design should be changed. "summary" may not be the right key
	return @"content:encoded";
}

- (NSString *) dateElementname {
	return @"pubDate";
}

- (NSArray *) desiredElementKeys {
	return [NSArray arrayWithObjects:@"title", @"link", [self summaryElementName], [self dateElementname], 
									  @"dc:creator", nil];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"item"]) {
		Class storyClass = [self storyClass];
		item = [[storyClass alloc] init];
		
	}
	else if ([desiredElementKeysCache containsObject:elementName])
		currentText = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	if ([elementName isEqualToString:@"item"]) {
		[stories addObject:item];
		[item release];
		item = nil;
	}
	else if (currentText) {
		if ([elementName isEqualToString:[self summaryElementName]] )
			[item setSummary:currentText];
		else if ([elementName isEqualToString:[self dateElementname]])
		{
			// Question here is: Should we store the string, or an NSDate object?
			NSDate *date = [[self dateFormatter]  dateFromString:currentText];
			if ([[self class] oldestStoryDate] == nil || [date compare:[[self class] oldestStoryDate]] == NSOrderedAscending) {
				[[self class] setOldestStoryDate:date];
			}
			[item setDate:date];
		}
		else if ([elementName isEqualToString:@"dc:creator"])
			[item setAuthor:currentText];			
		else
			[item setValue:currentText forKey:elementName];
		
		[currentText release];
		currentText = nil;
	}		
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	[currentText appendString:string];
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];

	//update Application Badge
	[self updateApplicationIconBadgeNumber];

	NSLog(@"all done!");
	NSLog(@"stories array has %d items", [stories count]);
	[newsTable reloadData];
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {return YES;
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}*/

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)updateApplicationIconBadgeNumber{
	//logic is now in each Controllers
}

- (void)dealloc {
	
	[currentElement release];
	[desiredElementKeysCache release];
	[stories release];
	[item release];
	[currentText release];
	[dateFormatter release];
	
	[super dealloc];
}

@end