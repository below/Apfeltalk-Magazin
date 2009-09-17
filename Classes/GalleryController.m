//
//  RootViewController.m
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

#import "GalleryController.h"
#import "DetailGallery.h"
#import "AsyncImageView.h";
#import "GalleryStory.h";

@implementation GalleryController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(shakeToReload) {
		NSLog(@"Shake To Reload is on, activae UIAccelerometer");
		[self activateShakeToReload:self];
	} else {
		NSLog(@"Shake To Reload is off, don't activae UIAccelerometer");
	}	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// if our view is not active/visible, we don't want to receive Accelerometer events
	if(shakeToReload)
	{
		UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
		accel.delegate = nil;
	}
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    ATXMLParser         *parser = [[ATXMLParser alloc] initWithURLString:URL];
    NSMutableDictionary *desiredKeys = [NSMutableDictionary dictionaryWithDictionary:[parser desiredElementKeys]];

    [desiredKeys removeObjectForKey:@"content:encoded"];
    [desiredKeys setObject:@"summary" forKey:@"description"];

    [parser setDesiredElementKeys:desiredKeys];
    [parser setStoryClass:[GalleryStory self]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"ImageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } else {
		AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:999];
		[oldImage removeFromSuperview];
	}

	CGRect previewImageFrame;
	previewImageFrame.size.width=44.f; 
	previewImageFrame.size.height=44.f;
	previewImageFrame.origin.x=6;
	previewImageFrame.origin.y=0;
	
	AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame:previewImageFrame] autorelease];
	asyncImage.tag = 999;
	GalleryStory *story = [stories objectAtIndex:indexPath.row];
	NSString *urlString = [story thumbnailLink];
	if ([urlString length] > 0) {
		NSURL *url = [NSURL URLWithString:urlString];
		[asyncImage loadImageFromURL:url];
		
		[cell.contentView addSubview:asyncImage];    		
	}
	else
		NSLog (@"%@ has no thumbnail", [story title]);
	
	// We leave it like this for the moment, because the gallery has no read indicators
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	
	// No special customization
	cell.indentationLevel = 5; // intend, so the image does not get cut off
	cell.textLabel.text = [[stories objectAtIndex: storyIndex] title];    // TODO show author name in cell text
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Right now, let's leave it at that because the gallery has no read-indicators
    // Navigation logic

    // Custom code

    // open in Safari
    DetailGallery *dvController = [[DetailGallery alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle] 
                                                                   story:[stories objectAtIndex: indexPath.row]];
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
	 
	 // end of custom code
}

- (NSString *) documentPath {
	return @"http://www.apfeltalk.de/forum/gallery.rss";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {return YES;
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// handle acceleromter event
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	if ([self isShake:acceleration]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[super parseXMLFileAtURL:[self documentPath]];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}


#pragma mark -
#pragma mark ATXMLParserDelegateProtocol

- (BOOL)parser:(ATXMLParser *)parser shouldAddParsedItem:(id)item
{
    BOOL      result = NO;
    NSRange   linkRange, aRange;
	NSString *aString = [[item summary] lowercaseString];

    linkRange = [aString rangeOfString:@"http://www.apfeltalk.de/gallery/data"];

    if (linkRange.location != NSNotFound)
    {
        aRange = [aString rangeOfString:@".jpg\" alt=" options:NSLiteralSearch range:NSMakeRange(linkRange.location, [aString length] - linkRange.location)];

        if (aRange.location == NSNotFound)
            aRange = [aString rangeOfString:@".png\" alt=" options:NSLiteralSearch
                                      range:NSMakeRange(linkRange.location, [aString length] - linkRange.location)];

        if (aRange.location != NSNotFound)
        {
            linkRange.length = NSMaxRange(aRange) - 6 - linkRange.location;
            [item setThumbnailLink:[[item summary] substringWithRange:linkRange]];
            result = YES;
        }
    }

    return result;
}

@end
