//
//  Apfeltalk_MagazinAppDelegate.h
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.//

#import "ApfeltalkMagazinAppDelegate.h"
#import "RootViewController.h"


@implementation ApfeltalkMagazinAppDelegate

@synthesize window;
@synthesize navigationController;


- (id)init {
	if (self = [super init]) {
		// 
	}
	return self;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog (@"We are here!");
	BOOL isFeed = [[url scheme] isEqualToString:@"feed"];
	BOOL isApfeltalk = [[url host] hasSuffix:@"apfeltalk.de"];
	return (isFeed && isApfeltalk);
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
