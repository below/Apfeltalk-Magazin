//
//  DetailNews.m
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

#import "DetailNews.h"
#import "NewsController.h"
#import "Apfeltalk_MagazinAppDelegate.h"
#import "TwitterRequest.h"

@interface DetailNews (private)
- (void)createMailComposer;
@end

@implementation DetailNews
@synthesize showSave;

// This is the new designated initializer for the class
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle story:newStory];
	if (self != nil) {
		showSave = YES;
	}
	return self;
}

- (NSString *) Mailsendecode {
	NSArray *controllers = [[self navigationController] viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];
	
    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];
	
    if (![self showSave]) {
		return nil;
	} else {
		return @"Speichern";
	}
}

- (void) postTweet {
	TwitterRequest * t = [[TwitterRequest alloc] init];
	t.username = usernameTextField.text;
	t.password = passwordTextField.text;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *twitter = [documentsDirectory stringByAppendingPathComponent:@"Twitter.plist"];
	NSArray * savedata = [NSArray arrayWithObjects:usernameTextField.text, passwordTextField.text,nil];
	[savedata writeToFile:twitter atomically:YES];
	
	NSString *link = [[self story] link];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest new];
	
	[postRequest setHTTPMethod:@"GET"];
	
	[postRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=apfeltalk&apiKey=R_c9aabb37645e874c9e99aebe9ba12cb8", link]]];
	
	NSData *responseData;
	NSHTTPURLResponse *response;
	
	//==== Synchronous call to upload
	responseData = [ NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:nil];
	[postRequest release];
    postRequest = nil;
    
	NSString *shortLink = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding]
                           autorelease]; // :below:20091218 Do we know if this is ASCII?
	
	NSRange pos1 = [shortLink rangeOfString: @"shortUrl"];
	NSRange pos2 = [shortLink rangeOfString: @"userHash"];
	NSRange range = NSMakeRange(pos1.location + 12,pos2.location - 17 - (pos1.location + 12));
	shortLink = [shortLink substringWithRange:range];
		
	loadingActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString (@"Sende Tweet…", @"") delegate:nil 
											cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[loadingActionSheet showInView:self.view];
	[t statuses_update:[NSString stringWithFormat:NSLocalizedString (@"Newstipp: %@ %@", @""), [[self story] title], shortLink] delegate:self requestSelector:@selector(status_updateCallback:)];
}
- (void) status_updateCallback: (NSData *) content {
	[loadingActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[loadingActionSheet release];
}

-(IBAction)speichern:(id)sender
{
	Apfeltalk_MagazinAppDelegate *appDelegate = (Apfeltalk_MagazinAppDelegate *)[[UIApplication sharedApplication] delegate];
	// :below:20090920 This is only to placate the analyzer
	 myMenu = [[UIActionSheet alloc]
							 initWithTitle: nil
							 delegate:self
							 cancelButtonTitle:@"Abbrechen"
							 destructiveButtonTitle:nil
							 otherButtonTitles: @"Per Mail versenden" , [self Mailsendecode], @"Newstipp twittern", @"Facebook", nil];
	
    [myMenu showFromTabBar:[[appDelegate tabBarController] tabBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{	
	int numberOfButtons = [actionSheet numberOfButtons];
	
	// assume that when we have 3 buttons, the one with idx 1 is the save button
    // :below:20091220 This assumption is not correct, all of this should be done with tags
	if (buttonIdx == 1 && numberOfButtons == 5) {
		UINavigationController *navController = [self navigationController];
		 NSArray *controllers = [navController viewControllers];
		 
		 NewsController *newsController = (NewsController*) [controllers objectAtIndex:[controllers count] -2];
		 [newsController addSavedStory:[self story]];
	}
	NSArray *controllers = [[self navigationController] viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];
	
    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];

	if (buttonIdx == 0) {
		if (TARGET_IPHONE_SIMULATOR) {
			NSLog(@"Keep in mind, that no mail could be send in Simulator mode... just providing the UI");
			[self createMailComposer];
		} else {
			[self createMailComposer];
		}
	}
	
	if (buttonIdx == 2) {
		//Newstipp twittern
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *twitter = [documentsDirectory stringByAppendingPathComponent:@"Twitter.plist"];
		NSArray * savedata = [NSArray arrayWithContentsOfFile:twitter];
		
		UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Gib deine Twitter Daten ein." message:@" \n   " 
															 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
		[usernameTextField setBackgroundColor:[UIColor whiteColor]];
		passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 75.0, 260.0, 25.0)];
		[passwordTextField setBackgroundColor:[UIColor whiteColor]];
		usernameTextField.placeholder = @"Benutzername";
		passwordTextField.placeholder = @"Passwort";
		passwordTextField.secureTextEntry = YES;
		
		usernameTextField.text = [savedata objectAtIndex:0];
		passwordTextField.text = [savedata objectAtIndex:1];
		CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
		[myAlertView setTransform:myTransform];
		[myAlertView addSubview:usernameTextField];
		[myAlertView addSubview:passwordTextField];
		[myAlertView show];
		[myAlertView release];
	}
	
	if (buttonIdx == 3) {
		FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
		[dialog show];
	}
	
	if (actionSheet == myMenu) {
		[myMenu release];		
		myMenu = nil;
	}
}

- (void)createMailComposer {
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:[story title] ];
	[controller setMessageBody:[story summary] isHTML:YES];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self postTweet];
	}
	
}

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.permission = @"status_update";
	[dialog show];
}

- (void)dialogDidSucceed:(FBDialog*)dialog {
	NSString *link = [[self story] link];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest new];
	
	[postRequest setHTTPMethod:@"GET"];
	
	[postRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=apfeltalk&apiKey=R_c9aabb37645e874c9e99aebe9ba12cb8", link]]];
	
	NSData *responseData;
	NSHTTPURLResponse *response;
	
	//==== Synchronous call to upload
	responseData = [ NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:nil];
	[postRequest release];
    
	NSString *shortLink = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding]
                           autorelease];
	
	NSRange pos1 = [shortLink rangeOfString: @"shortUrl"];
	NSRange pos2 = [shortLink rangeOfString: @"userHash"];
	NSRange range = NSMakeRange(pos1.location + 12,pos2.location - 17 - (pos1.location + 12));
	shortLink = [shortLink substringWithRange:range];
	
	
	NSString *statusString = [NSString stringWithFormat:@"Newstipp: %@ %@", [[self story] title], shortLink];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							statusString, @"status",
							@"true", @"status_includes_verb",
							nil];
	[[FBRequest requestWithDelegate:self] call:@"facebook.Users.setStatus" params:params];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *controllers = [[self navigationController] viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];

    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];
	
	session = [[FBSession sessionForApplication:@"4b52995a95555faf4ee6daa4267c92c5" secret:@"f3a3bf5c39884676247710b27a978b77" delegate:self] retain];
}

@end
