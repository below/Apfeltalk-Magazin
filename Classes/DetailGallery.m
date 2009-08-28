//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailGallery.h"
#import "RootViewController.h"

@implementation DetailGallery

@synthesize selectedCountry;
@synthesize selectedSumary;
@synthesize selecteddate;



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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{	
    NSURL *loadURL = [ [ request URL ] retain ]; // retain the loadURL for use
    if ( ( [ [ loadURL scheme ] isEqualToString: @"http" ] || [ [ loadURL scheme ] isEqualToString: @"https" ] ) && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) // Check if the scheme is http/https. You can also use these for custom links to open parts of your application.
        return ![ [ UIApplication sharedApplication ] openURL: [ loadURL autorelease ] ]; // Auto release the loadurl because we wont get to release later. then return the opposite of openURL, so if safari cant open the url, open it in the UIWebView.
    [ loadURL release ];
    return YES; // URL is not http/https and should open in UIWebView
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	webview.delegate = self;
    [super viewDidLoad];
	
	nui = [NSString stringWithFormat:@"<center><b>%@</b></center> ",selectedSumary];
	NSString *link = selecteddate;
	NSRange myRange = NSMakeRange(0,16);
	datum.text = [selecteddate substringWithRange:myRange];
	if (selectedCountry == @"") {
		titel.text = @"--Kein Titel--";
	} else {
		titel.text = selectedCountry;
	}
	link = [link stringByReplacingOccurrencesOfString:@"#comments" withString:@"?onlycomments=yes"];
	NSString *str = selectedSumary;

	NSRange pos1 = [str rangeOfString: @"http://www.apfeltalk.de/gallery/data"]; //-42 .... 
	NSRange pos2 = NSMakeRange(1,2);
	if ([str rangeOfString:@".jpg\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".jpg\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".JPG\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".JPG\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".png\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".png\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".PNG\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".PNG\" alt="]; //+4 ....
	}
	pos2.location = pos2.location + 4;
	NSRange myRange2 = NSMakeRange(pos1.location,pos2.location - pos1.location);
	str = [selectedSumary substringWithRange:myRange2];
	
	str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
	NSArray *tags = [NSArray arrayWithObjects: @"a", @"b", @"p", @"br", @"div",@"li", nil];
	nui = [self strip_tags:nui :tags];
	
	NSString *showpicture = [NSString stringWithFormat:@"<img src=\"%@\" width=\"275\" height=\"181\" alt=\"No Medium Picture.\" /> ", str];
	NSString *name2 = [NSString stringWithFormat:@"<style type=\"text/css\"> body		{font-family: \"Helvetica\", sans-serif; font-size:13px; margin: 0; padding: 0; repeat scroll 0 0;}  </style> </div> </head> </div> ", link];
	[webview loadHTMLString:[NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ %@ <br> %@", showpicture, nui, name2] baseURL:nil];
		
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
	NSString *str = selectedSumary;
	
	NSRange pos1 = [str rangeOfString: @"http://www.apfeltalk.de/gallery/data"]; //-42 .... 
	NSRange pos2 = NSMakeRange(1,2);
	if ([str rangeOfString:@".jpg\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".jpg\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".JPG\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".JPG\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".png\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".png\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".PNG\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".PNG\" alt="]; //+4 ....
	}
	pos2.location = pos2.location + 4;
	NSRange myRange2 = NSMakeRange(pos1.location,pos2.location - pos1.location);
	str = [selectedSumary substringWithRange:myRange2];
	
	str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];	
	UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:str]]];
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Bild gespeichert" message:@"Das Bild wurde erfolgreich in deine Fotogallerie gespeichert." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
