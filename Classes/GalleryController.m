//
//  RootViewController.m
//  Apfeltalk Magazin
//
//  Created by Stephan König on  7/29/09.
//  Copyright Stephan König All rights reserved.
//


#import "GalleryController.h"
#import "ApfeltalkMagazinAppDelegate.h"
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
	
	cell.textLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    return cell;
}


 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 // Right now, let's leave it at that because the gallery has no read-indicators
	 // Navigation logic
	 	 
	 NSString *selectedCountry = [[stories objectAtIndex: indexPath.row] objectForKey: @"title"];
	 NSString *selectedSumary = [[stories objectAtIndex: indexPath.row] objectForKey: @"summary"];
	 NSString *selecteddate = [[stories objectAtIndex: indexPath.row] objectForKey: @"date"];
	 	
	 
	 // Custom code
	 
	 // open in Safari
	 DetailGallery *dvController = [[DetailGallery alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	 dvController.selectedCountry = selectedCountry;
	 dvController.selecteddate = selecteddate;
	 dvController.selectedSumary = selectedSumary;
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

