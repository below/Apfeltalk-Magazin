//
//  fullscreen.m
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 02.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "fullscreen.h"


@implementation fullscreen

@synthesize string;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	imageview.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:string]]];
	if (imageview.image.size.width > imageview.image.size.height) {
		//imageview.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:string]]];
	}
	if (imageview.image.size.width < imageview.image.size.height) {
		//imageview.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:string]]];
	}
    [super viewDidLoad];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
