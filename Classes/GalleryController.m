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
#import "AsyncImageView.h"
#import "Story.h"
#import "ATMXMLUtilities.h"

@implementation GalleryController

- (NSDictionary *) desiredKeys {
	NSMutableDictionary *elementKeys = [NSMutableDictionary dictionaryWithDictionary:[super desiredKeys]];
	[elementKeys removeObjectForKey:@"content:encoded"];
	[elementKeys setObject:@"summary" forKey:@"description"];
	
	return elementKeys;
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    [super parseXMLFileAtURL:URL];
	
	// This needs to be done in post-processing, as libxml2 interferes with NSXMLParser
	NSMutableArray *thumbnailStories = [[NSMutableArray alloc] initWithCapacity:[stories count]];
	for (Story *s in stories) {
		NSString *thumbnailLink = extractTextFromHTMLForQuery([s summary], @"//img[attribute::alt]/attribute::src");
		if ([thumbnailLink length] > 0) {
			[s setThumbnailLink:thumbnailLink];
			[thumbnailStories addObject:s];
		}
	}	
	[stories release];
	stories = thumbnailStories;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];

	// This needs to be done in post-processing, as libxml2 interferes with NSXMLParser
	NSMutableArray *thumbnailStories = [[NSMutableArray alloc] initWithCapacity:[stories count]];
	for (Story *s in stories) {
		NSString *thumbnailLink = extractTextFromHTMLForQuery([s summary], @"//img[attribute::alt]/attribute::src");
		if ([thumbnailLink length] > 0) {
			[s setThumbnailLink:thumbnailLink];
			[thumbnailStories addObject:s];
		}
	}

	[stories release];
	stories = thumbnailStories;
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
	Story *story = [stories objectAtIndex:indexPath.row];
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
@end
