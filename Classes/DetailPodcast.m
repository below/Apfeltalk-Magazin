//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
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

#import "DetailPodcast.h"
#import "RootViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation DetailPodcast

- (void) viewDidLoad {
	[super viewDidLoad];
	NSString *extension = [[[self story] link] pathExtension];
	if ([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"]
	|| [extension isEqualToString:@"mov"])
		[thumbnailButton addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *) rightBarButtonTitle {
	return nil;
}

- (UIImage *) usedimage {
	authorLabel.text = nil;
	return [UIImage imageNamed:@"header.png"];
}

- (UIImage *) thumbimage {
	return [UIImage imageNamed:@"apfelshow.png"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	// :below:20091018 We don't allow any links to be clicked here
	if (navigationType == UIWebViewNavigationTypeOther)
		
		return YES;
	else
		return NO;
}

-(void)playMovieAtURL:(NSURL*)theURL 

{
	[theMovie release];
	// theMovie is an iVar just for the sake of the analyzer...
    theMovie=[[MPMoviePlayerController alloc] initWithContentURL:theURL]; 
    theMovie.scalingMode=MPMovieScalingModeAspectFill; 
	
    // Register for the playback finished notification. 
	
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(myMovieFinishedCallback:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:theMovie]; 
	
    // Movie playback is asynchronous, so this method returns immediately. 
    [theMovie play]; 
} 

// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback:(NSNotification*)aNotification 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:theMovie]; 
	
    // Release the movie instance created in playMovieAtURL
    [theMovie release]; 
	theMovie = nil;
}

- (IBAction) playMovie {
	SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "apfeltalk.de");
	SCNetworkReachabilityFlags flags;
	BOOL success = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
	CFRelease(reachabilityRef);
	if (success == NO || (flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString (@"Mobiles Netzwerk", @"")
														message:NSLocalizedString (@"Videos sind nicht über ein mobiles Netzwerk verfügbar. Bitte verbinden Sie sich mit einem WLAN Netzwerk", @"")
													   delegate:nil cancelButtonTitle:NSLocalizedString (@"OK", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
		[self playMovieAtURL:[NSURL URLWithString:[[self story] link]]];
}

- (void) dealloc
{
	[theMovie release];
	[super dealloc];
}

@end