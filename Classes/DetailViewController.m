//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at mac dot com), Stefan Kofler
//						Alexander von Below, Michael Fenske, Jesper (Graphics),
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

#import "DetailViewController.h"
#import "RootViewController.h"

@implementation DetailViewController

@synthesize story;

 // This is the new designated initializer for the class
 - (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self != nil) {
		[self setStory:newStory];
	}
	return self;
}

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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{	
    NSURL *loadURL = [ [ request URL ] retain ]; // retain the loadURL for use
    if ( ( [ [ loadURL scheme ] isEqualToString: @"http" ] || [ [ loadURL scheme ] isEqualToString: @"https" ] ) && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) // Check if the scheme is http/https. You can also use these for custom links to open parts of your application.
        return ![ [ UIApplication sharedApplication ] openURL: [ loadURL autorelease ] ]; // Auto release the loadurl because we wont get to release later. then return the opposite of openURL, so if safari cant open the url, open it in the UIWebView.
    [ loadURL release ];
    return YES; // URL is not http/https and should open in UIWebView
}

- (NSString *) htmlString {
	NSString *nui = [NSString stringWithFormat:@"<center><b>%@</b></center>%@ " , [[self story] title], [[self story] summary]];
	
	NSArray *tags = [NSArray arrayWithObjects: @"a", @"b", @"p", @"br", @"img", @"div",@"li", nil];
	nui = [self strip_tags:nui :tags];
	nui = [nui stringByReplacingOccurrencesOfString:@"Miniaturansicht angehängter Grafiken" withString:@""];
	
	NSString *name2 = [NSString stringWithFormat:@"<head> <title>Kommentare</title> <style type=\"text/css\"> \
					   body		{font-family: \"Helvetica\", sans-serif; font-size:13px; margin: 0; padding: 0;\
					   background: url(http://touch-mania.com/wp-content/plugins/wptouch/themes/default/images/blank.gif) \
					   repeat scroll 0 0;} div.button 	{border:1px solid #B1B1B1;cursor:pointer;\
					   font-weight:bold;margin-left:10px;margin-right:10px; background-color: white; \
					   padding-bottom:10px; padding-left:10px;padding-top:10px;text-shadow:0 1px 0 #FFFFFF; \
					   margin-top: 10px;} div#frame	{padding: 0; margin: 0;} iframe		{padding: 0; margin: 0; \
					   border: 0;} </style> <script type=\"text/javascript\" \
					   src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\" /> \
					   <script type=\"text/javascript\"> $(document).ready(function() \
					   { $(\"div#frame\").hide(); $(\"div#show\").click(function(){ $(\"div#frame\").slideToggle();\
					   }); }); </script> </div> <meta name=\"viewport\" \
					   content=\"maximum-scale=1.0 width=device-width initial-scale=1.0 user-scalable=no\" /> \
					   </head> <body>  </div> </body> ", [[[self story] date] description]];
	return [NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;\
			border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ <br> %@ <br>",nui, name2];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	webview.delegate = self;
    [super viewDidLoad];
	
	// Very common
	titleLabel.text = [[self story] title];
	[authorLabel setText:[[self story] author]];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	datum.text = [dateFormatter stringFromDate:[[self story] date]];
	[dateFormatter release];

	//Set the title of the navigation bar
	//-150x150

	if (![[self story] isSaved])
    {
        UIBarButtonItem *speichernButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Speichern"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(speichern:)];
        self.navigationItem.rightBarButtonItem = speichernButton;
        [speichernButton release];
    }

	NSString * htmlString = [self htmlString];
	[webview loadHTMLString:htmlString baseURL:nil];
		
	[webview release];
}


-(IBAction)speichern:(id)sender
{
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
	[story release];
	[lblText release];
	[super dealloc];
}


@end
