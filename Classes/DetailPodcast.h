//
//  DetailViewController.h
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface DetailPodcast : DetailViewController <UIWebViewDelegate> {
	NSString *selectedLink;
}
@property (nonatomic, retain) NSString *selectedLink;

@end
