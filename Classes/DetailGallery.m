//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at mac dot com), Stefan Kofler
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

#import "DetailGallery.h"
#import "fullscreen.h"
#import "RootViewController.h"
#import "Apfeltalk_MagazinAppDelegate.h"


@implementation DetailGallery

- (NSString *) storyTitle {
	if ([[self story] title] == @"")
		return NSLocalizedString (@"--Kein Titel--", @"");
	else
		return [[self story] title];
}

- (NSString *) htmlString {	
	NSString *nui = [NSString stringWithFormat:@"<center><b>%@</b></center> ", [[self story] summary]];
	NSString *link = [[[self story] date] description];
	link = [link stringByReplacingOccurrencesOfString:@"#comments" withString:@"?onlycomments=yes"];
	NSString *str = [[self story] summary];
	
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
	str = [[[self story] summary] substringWithRange:myRange2];
	
	str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
	
	NSArray *tags = [NSArray arrayWithObjects: @"a", @"b", @"p", @"br", @"div",@"li", nil];
	nui = [self strip_tags:nui :tags];
	
	NSString *showpicture = [NSString stringWithFormat:@"<img src=\"%@\" width=\"275\" height=\"181\" alt=\"No Medium Picture.\" /> ", str];
	NSString *name2 = [NSString stringWithFormat:@"<style type=\"text/css\"> body		{font-family: \"Helvetica\", sans-serif; font-size:13px; margin: 0; padding: 0; repeat scroll 0 0;}  </style> </div> </head> </div> ", link];
	
	return [NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ <br> %@ <br> %@", showpicture, nui, name2];
}

- (NSString *) rightBarButtonTitle {
	return @"Bildoptionen";
}

- (UIImage *) usedimage {
	return [UIImage imageNamed:@"DetailBackground2.png"];
}

-(IBAction)speichern:(id)sender
{
	Apfeltalk_MagazinAppDelegate *appDelegate = (Apfeltalk_MagazinAppDelegate *)[[UIApplication sharedApplication] delegate];

	UIActionSheet *myMenu = [[UIActionSheet alloc]
							 initWithTitle: nil
							 delegate:self
							 cancelButtonTitle:@"Abbrechen"
							 destructiveButtonTitle:nil
							 otherButtonTitles:@"Kopieren", @"Bild speichern", @"Zeige Bild",nil];

    [myMenu showFromTabBar:[[appDelegate tabBarController] tabBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{
	NSString *str = [[self story] summary];
	
	NSRange pos1 = [str rangeOfString: @"http://www.apfeltalk.de/gallery/data"]; //-42 .... 
	NSRange pos2 = NSMakeRange(1,2);
	NSRange findRange;
	
	findRange = [[str lowercaseString] rangeOfString:@".jpg\" alt="];
	if (findRange.location !=NSNotFound){
		pos2 = findRange; //+4 ....
	}
	else {
		findRange = [[str lowercaseString] rangeOfString:@".png\" alt="];
		if (findRange.location !=NSNotFound){
			pos2 = findRange; //+4 ....
		}  
	}
	pos2.location = pos2.location + 4;
	NSRange myRange2 = NSMakeRange(pos1.location,pos2.location - pos1.location);
	str = [[[self story] summary] substringWithRange:myRange2];
	
	if (buttonIdx == 2) {
		fullscreen *dvController = [[fullscreen alloc] initWithNibName:@"fullscreen" bundle:[NSBundle mainBundle]];
		dvController.string = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
		
		[self.navigationController pushViewController:dvController animated:YES];
		[dvController release];	
	}
	
    if (buttonIdx == 1) {
		str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
		UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:str]]];
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Bild gespeichert" message:@"Das Bild wurde erfolgreich in deine Fotogallerie gespeichert." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
		
	}
	if (buttonIdx == 0) {
		str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@"/medium"];
		UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:str]]];
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.image = image;
	    NSLog(@"PasteBoard %@", [[UIPasteboard generalPasteboard] image]);	}
    [actionSheet release];
}


@end
