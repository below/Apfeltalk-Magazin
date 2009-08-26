//
//  RootViewController.m
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.
//


#import "PodcastController.h"
#import "ApfeltalkMagazinAppDelegate.h"
#import "DetailViewController.h"


@implementation PodcastController
@synthesize mynewString;

- (void)viewDidLoad {
	// Add the following line if you want the list to be editable
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
}

- (IBAction)openSafari:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
}

- (IBAction)about:(id)sender {
	[newsTable reloadData];
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Credits" // oder einfach Wilkommen in der Touch-Mania.com Applikation?
						  message:@"Apfeltalk.de App \n \nIdee: Stephan König \nProgrammierung: Stefan Kofler (Hauptentwickler) und Stephan König \nSplashcreen: Stefan Meier (Idee) und Patrick Rollbis (Umsetzung)."
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
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:grafele@gmail.com"]];
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
	
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	NSString *selecteddate = [[stories objectAtIndex: indexPath.row] objectForKey: @"date"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *text = [documentsDirectory stringByAppendingPathComponent:@"gelesen.txt"];
	
	mynewString = [[NSString alloc] initWithContentsOfFile: text encoding:NSUnicodeStringEncoding error: NULL];
	
	if ([mynewString rangeOfString:selecteddate].location !=NSNotFound){
		cell.imageView.image = [UIImage imageNamed:@"thread_dot.gif"];
	} else {
		cell.imageView.image = [UIImage imageNamed:@"thread_dot_hot.gif"];
	}
	cell.textLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];

    return cell;
}


 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 // Navigation logic
	 	 
	 NSString *selectedCountry = [[stories objectAtIndex: indexPath.row] objectForKey: @"title"];
	 NSString *selectedSumary = [[stories objectAtIndex: indexPath.row] objectForKey: @"summary"];
	 NSString *selecteddate = [[stories objectAtIndex: indexPath.row] objectForKey: @"date"];
	 	 
	 // open in Safari
	 DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	 dvController.selectedCountry = selectedCountry;
	 dvController.selecteddate = selecteddate;
	 dvController.selectedSumary = selectedSumary;
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *documentsDirectory = [paths objectAtIndex:0];
	 NSString *text = [documentsDirectory stringByAppendingPathComponent:@"gelesen.txt"];
	 
	 mynewString = [[NSString alloc] initWithContentsOfFile: text encoding:NSUnicodeStringEncoding error: NULL];
	 
	 mynewString = [NSString stringWithFormat:@"%@ -- %@ " , mynewString,selecteddate];
	 
	 NSString *myFilename = [documentsDirectory stringByAppendingPathComponent:@"gelesen.txt"];
	 NSError *error = [[NSError alloc] init];
	 [mynewString writeToFile:myFilename atomically:YES encoding:NSUnicodeStringEncoding error:&error];	
	
	 [self.navigationController pushViewController:dvController animated:YES];
	 [dvController release];
	 dvController = nil;
	 
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([stories count] == 0) {
		NSString * path = @"http://feeds.apfeltalk.de/apfeltalk-magazin";
		[self parseXMLFileAtURL:path];
	}
	
	cellSize = CGSizeMake([newsTable bounds].size.width, 60);
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
	stories = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
		
		[stories addObject:[item copy]];
		NSLog(@"adding story: %@", currentTitle);
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"content:encoded"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
	
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
	[currentTitle release];
	[currentDate release];
	[currentSummary release];
	[currentLink release];
	
	[super dealloc];
}


@end

