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
@end

