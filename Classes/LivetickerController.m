//
//  LivetickerController.m
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

#import "LivetickerController.h"
#import "LivetickerNavigationController.h"
#import "DetailLiveticker.h"
#import "Story.h"


@implementation LivetickerController

@synthesize stories;
@synthesize shortTimeFormatter;


- (void)dealloc
{
    [stories release];

    [super dealloc];
}



- (void)viewDidLoad
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"HH:mm"];
    [self setShortTimeFormatter:formatter];
    [formatter release];

    [self setStories:[NSMutableArray array]];
}



- (void)reloadTickerEntries:(NSTimer *)timer
{
    ATXMLParser  *parser = [ATXMLParser parserWithURLString:@"http://www.apfeltalk.de/live/?feed=rss2"];

    [NSThread detachNewThreadSelector:@selector(parseInBackgroundWithDelegate:) toTarget:parser withObject:self];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdendifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdendifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdendifier] autorelease];
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
    }

    Story *story = [stories objectAtIndex:[indexPath row]];

    [[cell detailTextLabel] setText:[story title]];
    [[cell textLabel] setText:[[self shortTimeFormatter] stringFromDate:[story date]]];

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stories count];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Story            *story = [stories objectAtIndex:[indexPath row]];
    DetailLiveticker *detailController = [[DetailLiveticker alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle] story:story];

    [[self navigationController] pushViewController:detailController animated:YES];
    [detailController release];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([stories count])
        return nil;
    else
        return NSLocalizedString(@"LivetickerController.noTicker", nil);
}



#pragma mark -
#pragma mark ATXMLParserDelegateProtocol

- (void)parser:(ATXMLParser *)parser didFinishedSuccessfull:(BOOL)success
{
    if (success)
        [(UITableView *)[self view] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    else
        [(LivetickerNavigationController *)[self navigationController] setReloadTimer:nil];
}



- (void)parser:(ATXMLParser *)parser setParsedStories:(NSArray *)parsedStories
{
    [self setStories:parsedStories];
}



- (void)parser:(ATXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [(LivetickerNavigationController *)[self navigationController] setReloadTimer:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Parsing Error", nil) message:[parseError localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
