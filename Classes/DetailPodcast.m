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
	if ([urlString rangeOfString:@"apfeltalk.de"].location !=NSNotFound){
		[self playMovieAtURL:[NSURL URLWithString:selectedLink]];
	}    
	return YES;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	webview.delegate = self;
	
	NSString *nui = [NSString stringWithFormat:@"<center><b>%@</b></center>%@ " , selectedCountry,selectedSumary];
	NSString *link = selecteddate;
	NSRange myRange = NSMakeRange(0,16);
	datum.text = [selecteddate substringWithRange:myRange];
	titel.text = selectedCountry;
	link = [link stringByReplacingOccurrencesOfString:@"#comments" withString:@"?onlycomments=yes"];
//	NSArray *tags = [NSArray arrayWithObjects: @"a", @"b", @"p", @"br", @"img", @"div",@"li", nil];
//	nui = [self strip_tags:nui :tags];
	nui = [nui stringByReplacingOccurrencesOfString:@"Miniaturansicht angehängter Grafiken" withString:@""];
	
	NSString *name2 = [NSString stringWithFormat:@"<head> <title>Kommentare</title> <style type=\"text/css\"> body		{font-family: \"Helvetica\", sans-serif; font-size:13px; margin: 0; padding: 0; background: url(http://touch-mania.com/wp-content/plugins/wptouch/themes/default/images/blank.gif) repeat scroll 0 0;} div.button 	{border:1px solid #B1B1B1;cursor:pointer;font-weight:bold;margin-left:10px;margin-right:10px; background-color: white; padding-bottom:10px; padding-left:10px;padding-top:10px;text-shadow:0 1px 0 #FFFFFF; margin-top: 10px;} div#frame	{padding: 0; margin: 0;} iframe		{padding: 0; margin: 0; border: 0;} </style> <script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\" /> <script type=\"text/javascript\"> $(document).ready(function() { $(\"div#frame\").hide(); $(\"div#show\").click(function(){ $(\"div#frame\").slideToggle(); }); }); </script> </div> <meta name=\"viewport\" content=\"maximum-scale=1.0 width=device-width initial-scale=1.0 user-scalable=no\" /> </head> <body>   <div id=\"wrapper\"> <div class=\"button\" onclick=\"window.location.href='%@'\"><center>Play Podcast</center></div>  </div> </div> </body> ", selectedLink];
	
	[webview loadHTMLString:[NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ %@  %@",nui, name2] 
					baseURL:nil];
	//Set the title of the navigation bar
	//-150x150
	
	UIBarButtonItem *speichernButton = [[UIBarButtonItem alloc]
										initWithTitle:@"Speichern"
										style:UIBarButtonItemStyleBordered
										target:self
										action:@selector(speichern:)];
	self.navigationItem.rightBarButtonItem = speichernButton;
	[speichernButton release];
	[webview release];
}

- (void)dealloc {
	[selectedLink release];
	[super dealloc];
}


@end
