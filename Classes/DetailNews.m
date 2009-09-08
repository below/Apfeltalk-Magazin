//
//  DetailNews.m
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

#import "DetailNews.h"
#import "NewsController.h"
#import "Apfeltalk_MagazinAppDelegate.h"


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

-(IBAction)speichern:(id)sender
{
	// This is an ugly hack
	/*UINavigationController *navController = [self navigationController];
	NSArray *controllers = [navController viewControllers];
	
	NewsController *newsController = (NewsController*) [controllers objectAtIndex:[controllers count] -2];
	[newsController addSavedStory:[self story]];
    [[self navigationItem] setRightBarButtonItem:nil animated:YES];
	 */
	Apfeltalk_MagazinAppDelegate *appDelegate = (Apfeltalk_MagazinAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	UIActionSheet *myMenu = [[UIActionSheet alloc]
							 initWithTitle: nil
							 delegate:self
							 cancelButtonTitle:@"Abbrechen"
							 destructiveButtonTitle:nil
							 otherButtonTitles: @"Per Mail versenden" , [self Mailsendecode],nil];
	
    [myMenu showFromTabBar:[[appDelegate tabBarController] tabBar]];
	[myMenu release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{	
	int numberOfButtons = [actionSheet numberOfButtons];
	
	// assume that when we have 3 buttons, the one with idx 1 is the save button
	if (buttonIdx == 1 && numberOfButtons == 3) {
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
	
    [actionSheet release];
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

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *controllers = [[self navigationController] viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];

    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];

    //if (![self showSave])
      //  [[self navigationItem] setRightBarButtonItem:nil];
}

- (void)dealloc {
    [super dealloc];
}

@end
