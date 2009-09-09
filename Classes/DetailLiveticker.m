//
//  DetailLiveticker.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper (Graphics),
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


#define MAX_IMAGE_WIDTH 280


@implementation DetailLiveticker

@synthesize story;


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
    if (self = [super initWithNibName:nibName bundle:nibBundle])
        [self setStory:newStory];

    return self;
}



- (void)dealloc
{
    [story release];
    [super dealloc];
}



- (void)viewDidLoad
{
    [webview setDelegate:self];

    [titleLabel setText:[[self story] title]];
    //[authorLabel setText:[[self story] author]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
	datum.text = [NSString stringWithFormat:@"von %@ - %@", [[self story] author], [dateFormatter stringFromDate:[[self story] date]]];
    [dateFormatter release];

    [webview loadHTMLString:[self htmlString] baseURL:nil];

#warning: setAllowsRubberBanding: is not documented. I think this will block the app to go into the AppStore
	[(UIScrollView *)[webview.subviews objectAtIndex:0] setAllowsRubberBanding:NO];

}



- (NSString *)htmlString
{
    int              newHeight;
    float            scaleFactor;
    NSRange          aRange, searchRange, valueRange;
    NSMutableString *htmlString = [NSMutableString stringWithString:[[self story] summary]];

    // Scale the images to fit into the webview
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

    NSURL *backgroundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bubble_middle" ofType:@"png"]];

    return [NSString stringWithFormat:@"<head> <style type=\"text/css\">"
            @" body { background:url(%@) repeat-y; font:10pt Helvetica; margin:0; padding:0; color:#6a6a6a }"
            @"</style></head> <body><div style=\"padding-left:20px; padding-right:20px;\">%@</div></body>", [backgroundURL absoluteString], htmlString];
}

@end
