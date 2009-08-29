//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "DetailPodcast.h"
#import "RootViewController.h"

@implementation DetailPodcast

@synthesize selectedLink;

-(void)playMovieAtURL:(NSURL*)theURL 

{
    MPMoviePlayerController* theMovie=[[MPMoviePlayerController alloc] initWithContentURL:theURL]; 
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
    MPMoviePlayerController* theMovie=[aNotification object]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:theMovie]; 
	
    // Release the movie instance created in playMovieAtURL
    [theMovie release]; 
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{    
	NSURL *loadURL = [ [ request URL ] retain ]; // retain the loadURL for use
	NSString *urlString = loadURL.absoluteString;
	if ([urlString rangeOfString:@".m"].location !=NSNotFound){
		[self playMovieAtURL:[NSURL URLWithString:selectedLink]];
	}    
	return YES;
}

- (NSString *) htmlString {
	NSString *nui = [NSString stringWithFormat:@"<center><b>%@</b></center>%@ " , [[self story] title], [[self story] summary]];

	nui = [nui stringByReplacingOccurrencesOfString:@"Miniaturansicht angehängter Grafiken" withString:@""];
	
	NSURL *playbuttonURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"playbutton" ofType:@"png"]];
	// We should check if this exists
	NSString *name2 = [NSString stringWithFormat:@"<style type=\"text/css\"> body		{font-family: \"Helvetica\", sans-serif; font-size:13px; </style> </div> <a href=\"%@\"><center><img src=\"%@\" alt=\"Play Podcast\" /></center></a> </div> </body> ", 
					   selectedLink, [playbuttonURL absoluteString]];
	
	return [NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ %@",nui, name2];
}

- (void)dealloc {
	[selectedLink release];
	[super dealloc];
}


@end
