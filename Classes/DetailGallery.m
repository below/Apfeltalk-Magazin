//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at mac dot com), Stefan Kofler
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

#import "DetailGallery.h"
#import "Fullscreen.h"
#import "RootViewController.h"
#import "Apfeltalk_MagazinAppDelegate.h"
#import "GalleryImageViewController.h"
#import "ATMXMLUtilities.h"

#import <libxml/HTMLparser.h>

@interface DetailGallery (private)
- (void)createMailComposer:(NSString*)str;
@end

@implementation DetailGallery
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

- (NSString *) storyTitle {
	if ([[self story] title] == @"")
		return NSLocalizedString (@"--Kein Titel--", @"");
	else
		return [[self story] title];
}

#pragma mark libxml SAX Callbacks
void characters(	void * 	user_data,
				const xmlChar * 	ch,
				int  	len) {
	NSMutableString *output = (NSMutableString *)user_data;
	NSString *charString = (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault,
															   ch, len, 
															   kCFStringEncodingUTF8, NO);
	[output appendString:charString];
	[charString release];
}

void endElement (void *userData, const xmlChar *name) {
	if (strcmp((const char *)name, "br") == 0) {
		NSMutableString *output = (NSMutableString *)userData;
		[output appendString:@"<br/>"];
	}		
}

- (NSString *) htmlString
{
	[cleanedString release];
	[elementString release];
	cleanedString = [NSMutableString new];
	elementString = [NSMutableString new];
	xmlSAXHandler saxInfo;
	memset(&saxInfo, 0, sizeof(saxInfo));
	saxInfo.characters = &characters;
	saxInfo.endElement = &endElement;
	
	// :below:20090919 The following will strip extract the pure text and breaks from the HTML
	
	// The big problem is that we don't have really structured input here, so all of this remains pretty brute force
	
	// Input is:
	//	<a href="http://www.apfeltalk.de/gallery/showphoto.php?photo=15992" target="_blank"><img title="Screenshot_2009-09-17_at_16_31_09.png" border="0" src="http://www.apfeltalk.de/gallery/data/500/thumbs/Screenshot_2009-09-17_at_16_31_09.png" alt="Screenshot_2009-09-17_at_16_31_09.png" /></a><br /><br />von: GunBound<br /><br />Beschreibung: Nein, eigentlich ist ja alles klar\u0085<br /><br />6 Kommentare<img width='1' height='1' src='http://rss.feedsportal.com/c/837/f/10954/s/6302265/mf.gif' border='0'/><div class='mf-viral'><table border='0'><tr><td valign='middle'><a href="http://res.feedsportal.com/viral/sendemail2_de.html?title=H\u00f8\u00f8\u00f8\u00f8\u00f8?&link=http://www.apfeltalk.de/gallery/showphoto.php?photo=15992" target="_blank"><img src="http://rss.feedsportal.com/images/emailthis2.gif" border="0" /></a></td><td valign='middle'><a href="http://res.feedsportal.com/viral/bookmark_de.cfm?title=H\u00f8\u00f8\u00f8\u00f8\u00f8?&link=http://www.apfeltalk.de/gallery/showphoto.php?photo=15992" target="_blank"><img src="http://rss.feedsportal.com/images/bookmark.gif" border="0" /></a></td></tr></table></div><br/><br/><a href="http://da.feedsportal.com/r/50216880195/u/82/f/10954/c/837/s/103817829/a2.htm"><img src="http://da.feedsportal.com/r/50216880195/u/82/f/10954/c/837/s/103817829/a2.img" border="0"/></a>
	// Output should be:
	// <br /><br />von: GunBound<br /><br />Beschreibung: Nein, eigentlich ist ja alles klar\u0085<br /><br />6 Kommentare<br/><br/>
	// TODO: Add a unit test for this
	
	// We could try if seperating it by <br/> Tags works...
	
	xmlChar *xmlCharString = (xmlChar*)[[[self story] summary] cStringUsingEncoding:NSUTF8StringEncoding];
	htmlDocPtr	htmlDoc = htmlSAXParseDoc		(xmlCharString, 
												 "utf-8", 
												 &saxInfo, 
												 cleanedString)	;
		
	free (htmlDoc);
	[elementString release];
	NSString *str = [[[self story] thumbnailLink] stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];

	NSString *showpicture = [NSString stringWithFormat:@"<img src=\"%@\" width=\"275\" height=\"181\" alt=\"No Medium Picture.\" /> ", str];

	NSString *resultString = [NSString stringWithFormat:@"%@<br/>%@", showpicture, cleanedString];
    resultString = [[self baseHtmlString] stringByReplacingOccurrencesOfString:@"%@" withString:resultString];
	[cleanedString release];
	cleanedString = nil;
	
	return resultString;
}

- (NSString *) rightBarButtonTitle {
	return @"Bildoptionen";
}

- (UIImage *) usedimage {
	return [UIImage imageNamed:@"header.png"];
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
							 otherButtonTitles:@"Per Mail versenden", @"Bild speichern", @"Zeige Bild",nil];

    [myMenu showFromTabBar:[[appDelegate tabBarController] tabBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{
	NSString *str = [[self story] summary];
	
    NSString *thumbLink = extractTextFromHTMLForQuery(str, @"//img[attribute::title]/attribute::src");
	
    if ([thumbLink length] == NSNotFound) {
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Keine URL", @"")
                                                              message:NSLocalizedString (@"Es konnte keine URL für das Bild gefunden werden", @"")
                                                             delegate:nil cancelButtonTitle:NSLocalizedString (@"OK", @"")
                                                    otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
        return;
    }

    NSString *imageLink = [thumbLink stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
    
    switch (buttonIdx) {
        case 2: {
            GalleryImageViewController *galleryImageViewController = [[GalleryImageViewController alloc] initWithURL:[NSURL URLWithString:imageLink]];
            [self.navigationController pushViewController:galleryImageViewController animated:YES];
            [galleryImageViewController release];
            break;
        }
        case 1:
        {
            UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageLink]]];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); 
            
            UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Bild gespeichert" message:@"Das Bild wurde erfolgreich in deine Fotogallerie gespeichert." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            [errorAlert release];
            
        }
            break;
        case 0:
        {
            imageLink = [thumbLink stringByReplacingOccurrencesOfString:@"/thumbs" withString:@"/medium"];
            
            if (TARGET_IPHONE_SIMULATOR)
                NSLog(@"Keep in mind, that no mail could be send in Simulator mode... just providing the UI");
            [self createMailComposerWithThumbnailLink:thumbLink];
        }
    }
	
	// :below:20090920 This is only to placate the analyzer
	if (actionSheet == myMenu) {
		[myMenu release];
		myMenu = nil;
	}
}

- (void)createMailComposerWithThumbnailLink:(NSString*)thumbnailLink {
    
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	
    NSString *imageLink = [thumbnailLink stringByReplacingOccurrencesOfString:@"/thumbs" withString:@"/medium"];
    
	// adde image as attachment
	UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageLink]]];
    if (image == nil) {
        imageLink = [thumbnailLink stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
        image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageLink]]];
    }
      
    if (image == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString (@"Foto konnte nicht geladen werden", @"")
                                                            message:NSLocalizedString (@"Das Foto konnte in keiner Auflösung geladen werden", @"")
                                                           delegate:nil cancelButtonTitle:NSLocalizedString (@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
	NSData *imageData = UIImageJPEGRepresentation(image, 1);
	[controller addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"attachment.jpg"];
	
	[controller setSubject:[story title] ];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)createMailComposer:(NSString*)str {
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	
	// adde image as attachment
	UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:str]]];
	NSData *imageData = UIImageJPEGRepresentation(image, 1);
	[controller addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"attachment.jpg"];
	
	[controller setSubject:[story title] ];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

- (void) dealloc
{
	[cleanedString release];
	[super dealloc];
}

@end
