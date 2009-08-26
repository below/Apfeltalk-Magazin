//
//  RootViewController.m
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.
//


#import "PodcastController.h"
#import "ApfeltalkMagazinAppDelegate.h"
#import "DetailPodcast.h"


@implementation PodcastController

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 // Navigation logic
	 	 
	 NSString *selectedCountry = [[stories objectAtIndex: indexPath.row] objectForKey: @"title"];
	 NSString *selectedSumary = [[stories objectAtIndex: indexPath.row] objectForKey: @"summary"];
	 NSString *selecteddate = [[stories objectAtIndex: indexPath.row] objectForKey: @"date"];
	 	 
	 // open in Safari
	 DetailPodcast *dvController = [[DetailPodcast alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	 dvController.selectedCountry = selectedCountry;
	 dvController.selecteddate = selecteddate;
	 dvController.selectedSumary = selectedSumary;
	 
	 // Really, only the follwing is different:
	 NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.itouchloads.de/furserver/%i.txt" , indexPath.row]];
	 dvController.selectedLink = [[[NSString alloc] initWithContentsOfURL:linkURL] autorelease];
	 
	 //This is common again
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *documentsDirectory = [paths objectAtIndex:0];
	 NSString *text = [documentsDirectory stringByAppendingPathComponent:@"gelesen.txt"];
	 
	 NSString *mynewString = [[[NSString alloc] initWithContentsOfFile: text encoding:NSUnicodeStringEncoding error: NULL] autorelease];
	 
	 mynewString = [NSString stringWithFormat:@"%@ -- %@ " , mynewString,selecteddate];
	 
	 NSString *myFilename = [documentsDirectory stringByAppendingPathComponent:@"gelesen.txt"];
	 NSError *error = nil;
	 [mynewString writeToFile:myFilename atomically:YES encoding:NSUnicodeStringEncoding error:&error];	
	
	 [self.navigationController pushViewController:dvController animated:YES];
	 [dvController release];
	 dvController = nil;
	 
}

- (NSString *) documentPath {
	return @"http://feeds2.feedburner.com/apfeltalk-small";
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	
	if ([elementName isEqualToString:@"enclosure"]) {
		currentElement = [elementName copy];
		NSString *link = [attributeDict valueForKey:@"url"];
		[item setObject:link forKey:@"link"];
	}
	else
		[super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
}

@end

