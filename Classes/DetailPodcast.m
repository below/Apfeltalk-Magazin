//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Jesper (Graphics),
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

@implementation DetailPodcast

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
}

- (NSString *) rightBarButtonTitle {
	return nil;
}

- (UIImage *) usedimage {
	authorLabel.text = nil;
	return [UIImage imageNamed:@"header.png"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{    
	NSString *urlString = [[request URL ] absoluteString];
	if ([urlString rangeOfString:@".m"].location !=NSNotFound){
		[self playMovieAtURL:[NSURL URLWithString:[[self story] link]]];
		return NO;
	}    
	return YES;
}

- (NSString *) htmlString {
	NSString *nui = [NSString stringWithFormat:@"<center><b>%@</b></center>%@ " , [[self story] title], [[self story] summary]];
	
	nui = [nui stringByReplacingOccurrencesOfString:@"Miniaturansicht angehängter Grafiken" withString:@""];
	
	NSURL *playbuttonURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"playbutton" ofType:@"png"]];
	NSURL *bubbleMiddleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"button_middle" ofType:@"png"]];
	// We should check if this exists
	NSString *name2 = [NSString stringWithFormat:@"<style type=\"text/css\"> \
					   body		{font-family: \"Helvetica\", sans-serif; font-size:13px; margin: 0; padding: 0;\
					   background: url(%@) \
					   repeat scroll 0 0;} div.button 	{border:1px solid #B1B1B1;cursor:pointer;\
					   font-weight:bold;margin-left:10px;margin-right:10px; background-color: white; \
					   padding-bottom:10px; padding-left:10px;padding-top:10px;text-shadow:0 1px 0 #FFFFFF; \
					   margin-top: 10px;} div#frame	{padding: 0; margin: 0;} iframe		{padding: 0; margin: 0; \
					   border: 0;} </style> <script type=\"text/javascript\" \
					   src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\" /> body    {font-family: \"Helvetica\", sans-serif; font-size:13px;\
					   </style> </div> <a href=\"%@\"><center><img src=\"%@\" alt=\"Play Podcast\" /></center></a> </div> </body> ", 
					   [bubbleMiddleURL absoluteString], [[self story] link], [playbuttonURL absoluteString]];
	
	return [NSString stringWithFormat:@" %@ %@",nui, name2];
}

- (void) dealloc
{
	[theMovie release];
	[super dealloc];
}

@end