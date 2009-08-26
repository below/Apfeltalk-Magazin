//
//  RootViewController.m
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.
//


#import "PodcastController.h"
#import "DetailPodcast.h"


@implementation PodcastController

- (UIViewController *) detailViewControllerForItem:(NSDictionary *)story {
	NSString *selectedCountry = [story valueForKey: @"title"];
	NSString *selectedSumary = [story valueForKey: @"summary"];
	NSString *selecteddate = [story valueForKey: @"date"];
	NSString *link = [story valueForKey:@"link"];
	
	DetailPodcast *dvController = [[DetailPodcast alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	dvController.selectedCountry = selectedCountry;
	dvController.selecteddate = selecteddate;
	dvController.selectedSumary = selectedSumary;
	// This is really the only change. We might change that later
	dvController.selectedLink = link;
	
	return [dvController autorelease];
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

