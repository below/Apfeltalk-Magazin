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

@synthesize selectedCountry;
@synthesize selectedSumary;
@synthesize selecteddate;
@synthesize selectedLink;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (NSString *)strip_tags:(NSString *)data :(NSArray *)valid_tags
{
        //use to strip the HTML tags from the data
        NSScanner *scanner;
        NSString *text = nil;
        NSString *tag = nil;
	
        //set up the scanner
        scanner = [NSScanner scannerWithString:data];
	
        while([scanner isAtEnd] == NO) {
		        //find start of tag
		        [scanner scanUpToString:@"<" intoString:NULL];
		
		        //find end of tag
		        [scanner scanUpToString:@">" intoString:&text];
		
		        //get the name of the tag
		        if([text rangeOfString:@"</"].location != NSNotFound)
			            tag = [text substringFromIndex:2]; //remove </
				else {
			            tag = [text substringFromIndex:1]; //remove <
			            //find out if there is a space in the tag
			        if([tag rangeOfString:@" "].location != NSNotFound)
				            //remove text after a space
				            tag = [tag substringToIndex:[tag rangeOfString:@" "].location];
		        }
		
		        //if not a valid tag, replace the tag with a space
		        if([valid_tags containsObject:tag] == NO)
			            data = [data stringByReplacingOccurrencesOfString:
								                  [NSString stringWithFormat:@"%@>", text] withString:@""];
        }
	
        //return the cleaned up data
        return data;
}

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	webview.delegate = self;
    [super viewDidLoad];
	
	nui = [NSString stringWithFormat:@"<center><b>%@</b></center>%@ " , selectedCountry,selectedSumary];
	NSRange myRange = NSMakeRange(0,16);
	datum.text = [selecteddate substringWithRange:myRange];
	titel.text = selectedCountry;
	nui = [nui stringByReplacingOccurrencesOfString:@"Miniaturansicht angehängter Grafiken" withString:@""];
	
	NSString *name2 = [NSString stringWithFormat:@"<style type=\"text/css\"> body		{font-family: \"Helvetica\", sans-serif; font-size:13px; </style> </div> <a href=\"%@\"><center><img src=\"http://www.itouchloads.de/playbutton.png\" alt=\"Play Podcast\" /></center></a> </div> </body> ", selectedLink];
	
	[webview loadHTMLString:[NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ %@  %@",nui, name2] baseURL:nil];
		
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


-(IBAction)speichern:(id)sender
{
	NSString *myString = [NSString stringWithFormat:@"%@", selectedCountry];
	NSString *myString2 = [NSString stringWithFormat:@"%@", selectedSumary];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myFilename = [documentsDirectory stringByAppendingPathComponent:@"Titel.txt"];
	NSString *myFilename2 = [documentsDirectory stringByAppendingPathComponent:@"Text.txt"];
	NSError *error = [[NSError alloc] init];
	[myString writeToFile:myFilename atomically:YES encoding:NSUnicodeStringEncoding error:&error];	
	[myString2 writeToFile:myFilename2 atomically:YES encoding:NSUnicodeStringEncoding error:&error];	
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"News gespeichert" message:@"Die News wurde erfolgreich gespeichert. Du siehst sie beim nächsten Start der Applikation ohne Internetverbindung." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.

}


- (void)dealloc {
	[selectedCountry release];
	[selectedSumary release];
	[selecteddate release];
	[lblText release];
	[super dealloc];
}


@end
