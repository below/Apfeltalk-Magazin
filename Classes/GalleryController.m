//
//  RootViewController.m
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


#import "GalleryController.h"
#import "DetailGallery.h"



@implementation GalleryController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// We leave it like this for the moment, because the gallery has no read indicators
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	
	// No special customization
	
	cell.textLabel.text = [[stories objectAtIndex: storyIndex] title];
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
	 dvController = nil;
	 
	 // end of custom code
}

- (NSString *) documentPath {
	return @"http://www.apfeltalk.de/forum/gallery.rss";
}

- (NSString *) summaryElementName {
	// It should be discussed if the design should be changed. "summary" may not be the right key
	return @"description";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {return YES;
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

