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

- (Class) detailControllerClass {
	return [DetailPodcast self];
}

- (NSString *) documentPath {
	return @"http://feeds2.feedburner.com/apfeltalk-small";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{      
	if ([elementName isEqualToString:@"enclosure"]) {
		currentElement = [elementName copy];
		NSString *link = [attributeDict valueForKey:@"url"];
		[item setLink:link];
	}
	else
		[super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
}
@end

