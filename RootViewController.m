//
//  RootViewController.m
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.
//


#import "RootViewController.h"
#import "ApfeltalkMagazinAppDelegate.h"
#import "DetailViewController.h"

@interface RootViewController (private)
- (BOOL) openDatabase;
- (BOOL) databaseContainsURL:(NSString *)link;
@end

@implementation RootViewController

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
						  message:@"Apfeltalk.de App \n \nIdee: Stephan König \nProgrammierung: Stefan Kofler und Stephan König \nSplashcreen: Stefan Meier (Idee) und Patrick Rollbis (Umsetzung) \n Icons: Jesper Frommherz."
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [stories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	
	int storyIndex = [indexPath row];
	// Everything below here is customization
		
	NSString * link = [[stories objectAtIndex: indexPath.row] objectForKey: @"link"];
	BOOL read = [self databaseContainsURL:link];

	if (read){
		cell.imageView.image = [UIImage imageNamed:@"thread_dot.gif"];
	} else {
		cell.imageView.image = [UIImage imageNamed:@"thread_dot_hot.gif"];
	}

	cell.textLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];

    return cell;
}

/*
 * This funktion checks to see if the given URL is in the database
 */
- (BOOL) databaseContainsURL:(NSString *)link {
	BOOL found = NO;
	const char *sql = "select url from read where url=?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) 
		== SQLITE_OK) {
		sqlite3_bind_text (statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			found = YES;
		}
	}
	sqlite3_finalize(statement);	
	return found;
}

- (NSString *) readDocumentsFilename {	 
	// This could be static
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	assert ([paths count]);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"gelesen.db"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 // Navigation logic
	 	 
	 NSString *selectedCountry = [[stories objectAtIndex: indexPath.row] objectForKey: @"title"];
	 NSString *selectedSumary = [[stories objectAtIndex: indexPath.row] objectForKey: @"summary"];
	 NSString *selecteddate = [[stories objectAtIndex: indexPath.row] objectForKey: @"date"];
	 	 
	 // The above appears to be common 
	 
	 // open in Safari
	 DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	 dvController.selectedCountry = selectedCountry;
	 dvController.selecteddate = selecteddate;
	 dvController.selectedSumary = selectedSumary;	 
	 
	 NSString * link = [[stories objectAtIndex: indexPath.row] objectForKey: @"link"];
	if (![self databaseContainsURL:link]) {
		
	//	Tue, 25 Aug 2009 11:18:34 GMT

		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
		NSDate *date = [dateFormatter dateFromString:selecteddate];
		

		const char *sql = "insert into read(url, date) values(?,?)"; 
		sqlite3_stmt *insert_statement;
		sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL); 
		
		sqlite3_bind_text(insert_statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT); 
		sqlite3_bind_double(insert_statement, 2, [date timeIntervalSinceReferenceDate]);
		sqlite3_step(insert_statement); 
		sqlite3_finalize(insert_statement);	
		
		sqlite3_stmt *delete_statement;
		NSDate *oldestDate = [NSDate distantPast]; // Currently, we don't delete anything
		NSString *deleteSql = [NSString stringWithFormat:@"delete from read where date<%f", [oldestDate timeIntervalSinceReferenceDate]];
		sqlite3_prepare_v2(database, [deleteSql UTF8String], -1, &delete_statement, NULL); 
		
		sqlite3_step(delete_statement); 
		sqlite3_finalize(delete_statement);	
		
		[dateFormatter release];

		[newsTable reloadData];
	}

	 [self.navigationController pushViewController:dvController animated:YES];
	 [dvController release];
	 dvController = nil;
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

- (void)viewWillDisappear:(BOOL)animated {
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
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
	stories = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
		
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
	NSLog ([NSString stringWithContentsOfURL:xmlURL]);
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (NSString *) summaryElementName {
	// It should be discussed if the design should be changed. "summary" may not be the right key
	return @"content:encoded";
}

- (NSString *) dateElementname {
	return @"pubDate";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];

	if ([elementName isEqualToString:@"item"])
		item = [[NSMutableDictionary alloc] init];
	else if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"link"]
		|| [elementName isEqualToString:[self summaryElementName]] || [elementName isEqualToString:[self dateElementname]])
		currentText = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	if ([elementName isEqualToString:@"item"]) {
		[stories addObject:[item copy]];
		[item release];
		item = nil;
	}
	else if (currentText) {
		if ([elementName isEqualToString:[self summaryElementName]] )
			[item setObject:currentText forKey:@"summary"];
		else if ([elementName isEqualToString:[self dateElementname]])
			[item setObject:currentText forKey:@"date"];
		else
			[item setObject:currentText forKey:elementName];
		
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


- (void)dealloc {
	
	[currentElement release];
	[rssParser release];
	[stories release];
	[item release];
	[currentText release];
	
	[super dealloc];
}


@end

