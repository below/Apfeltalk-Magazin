//
//  DetailLiveticker.m
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

#import "DetailLiveticker.h"
#import "LivetickerController.h"
#import "UIScrollViewPrivate.h"


#define MAX_IMAGE_WIDTH 280


@implementation DetailLiveticker

- (void)viewDidLoad
{
    NSArray            *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Up.png"], [UIImage imageNamed:@"Down.png"], nil];
	UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:imgArray];

	[segControl addTarget:[[[self navigationController] viewControllers] objectAtIndex:0] action:@selector(changeStory:)
         forControlEvents:UIControlEventValueChanged];
	[segControl setFrame:CGRectMake(0, 0, 90, 30)];
	[segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segControl setMomentary:YES];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];

    [[self navigationItem] setRightBarButtonItem:rightItem];
    [[[[self navigationController] viewControllers] objectAtIndex:0] changeStory:segControl];

    [segControl release];
    [rightItem release];

    [webview setDelegate:self];
    [self updateInterface];

	[(UIScrollView *)[webview.subviews objectAtIndex:0] setAllowsRubberBanding:NO];
}

- (NSString *)cssStyleString {
	return @"font:10pt Helvetica; margin:0; padding:0; color:#6a6a6a;";
}

- (NSString *)htmlString
{
	thumbnail.image = [UIImage imageNamed:@"ticker.png"];
    int              newHeight;
    float            scaleFactor;
    NSRange          aRange, searchRange, valueRange;
    NSMutableString *htmlString = [NSMutableString stringWithString:[[self story] summary]];

    // Scale the images to fit into the webview
	// !!!:below:20090919 This needs more cleanup, possibly with XQuery. But not today...
    searchRange = NSMakeRange(0, [htmlString length]);
    while (searchRange.location < [htmlString length])
    {
        aRange = [htmlString rangeOfString:@"width=\"" options:NSLiteralSearch range:searchRange];
        if (aRange.location != NSNotFound)
        {
            searchRange = NSMakeRange(NSMaxRange(aRange), [htmlString length] - NSMaxRange(aRange));
            aRange = [htmlString rangeOfString:@"\"" options:NSLiteralSearch range:searchRange];
            valueRange = NSMakeRange(searchRange.location, aRange.location - searchRange.location);

            scaleFactor = (float)MAX_IMAGE_WIDTH / [[htmlString substringWithRange:valueRange] intValue];
            if (scaleFactor < 1.0)
            {
                [htmlString replaceCharactersInRange:valueRange withString:[NSString stringWithFormat:@"%d", MAX_IMAGE_WIDTH]];
                searchRange = NSMakeRange(valueRange.location, [htmlString length] - valueRange.location);
                aRange = [htmlString rangeOfString:@"height=\"" options:NSLiteralSearch range:searchRange];
                if (aRange.location != NSNotFound)
                {
                    searchRange = NSMakeRange(NSMaxRange(aRange), [htmlString length] - NSMaxRange(aRange));
                    aRange = [htmlString rangeOfString:@"\"" options:NSLiteralSearch range:searchRange];
                    valueRange = NSMakeRange(searchRange.location, aRange.location - searchRange.location);
                    newHeight = [[htmlString substringWithRange:valueRange] intValue] * scaleFactor;
                    [htmlString replaceCharactersInRange:valueRange withString:[NSString stringWithFormat:@"%d", newHeight]];
                    searchRange.length = [htmlString length] - searchRange.location;
                }
            }
        }
        else
        {
            searchRange.location = [htmlString length];
        }
    }

    return [NSString stringWithFormat:@"<div style=\"%@\">%@</div>",
			[self cssStyleString], htmlString];
}



- (UISegmentedControl *)storyControl
{
    return (UISegmentedControl *)[[[self navigationItem] rightBarButtonItem] customView];
}



- (void)updateInterface
{
    [titleLabel setText:[[self story] title]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
	datum.text = [NSString stringWithFormat:@"von %@ - %@", [[self story] author], [dateFormatter stringFromDate:[[self story] date]]];
    [dateFormatter release];

    [webview loadHTMLString:[self htmlString] baseURL:nil];
}

@end
