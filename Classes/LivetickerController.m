//
//  LivetickerController.m
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

#import "LivetickerController.h"
#import "LivetickerNavigationController.h"
#import "DetailLiveticker.h"
#import "Story.h"


#define TIMELABEL_TAG 1
#define TITLELABEL_TAG 2


@implementation LivetickerController

@synthesize stories;
@synthesize shortTimeFormatter;
@synthesize displayedStoryIndex;


- (void)dealloc
{
    [stories release];
    [shortTimeFormatter release];

    [super dealloc];
}



- (void)viewDidLoad
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"HH:mm"];
    [self setShortTimeFormatter:formatter];
    [formatter release];

    [self setStories:[NSArray array]];
}


- (NSDictionary *) desiredKeys {
	// :below:20091018 Somewhat ugly...
	NSArray      *names = [NSArray arrayWithObjects:@"title", @"link", @"pubDate", @"dc:creator", @"content:encoded", nil];
	NSArray      *keys = [NSArray arrayWithObjects:@"title", @"link", @"date", @"author", @"summary", nil];
	NSDictionary *elementKeys = [NSDictionary dictionaryWithObjects:keys forKeys:names];
	
	return elementKeys;
}

- (void)reloadTickerEntries:(NSTimer *)timer
{
    ATXMLParser *parser = [ATXMLParser parserWithURLString:@"http://www.apfeltalk.de/live/?feed=rss2"];
	[parser setDesiredElementKeys:[self desiredKeys]];
	
    [NSThread detachNewThreadSelector:@selector(parseInBackgroundWithDelegate:) toTarget:parser withObject:self];
}



- (void)changeStory:(id)sender
{
    NSUInteger  newIndex = [self displayedStoryIndex];
    Story      *newStory;

    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 0)
        newIndex--;

    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 1)
        newIndex++;

    if ([(UISegmentedControl *)sender selectedSegmentIndex] != UISegmentedControlNoSegment)
    {
        [self setDisplayedStoryIndex:newIndex];
        newStory = [[self stories] objectAtIndex:newIndex];
        [[[[self navigationController] viewControllers] lastObject] setStory:newStory];
        [[[[self navigationController] viewControllers] lastObject] updateInterface];
    }

    [(UISegmentedControl *)sender setEnabled:([self displayedStoryIndex] > 0) forSegmentAtIndex:0];
    [(UISegmentedControl *)sender setEnabled:!([self displayedStoryIndex] == ([[self stories] count] - 1)) forSegmentAtIndex:1];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdendifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdendifier];

    UILabel *timeLabel;
    UILabel *titleLabel;

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdendifier] autorelease];

        CGRect contentRect = [[cell contentView] frame];

        // Creating the time label
        timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 50.0, contentRect.size.height)] autorelease];
        [timeLabel setTag:TIMELABEL_TAG];
        [timeLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [timeLabel setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0]];
        [timeLabel setHighlightedTextColor:[UIColor whiteColor]];
        [timeLabel setTextAlignment:UITextAlignmentLeft];
        [timeLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight];

        [[cell contentView] addSubview:timeLabel];

        // Creating the title label
        titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50.0, 0.0, contentRect.size.width - 60.0, contentRect.size.height)] autorelease];
        [titleLabel setTag:TITLELABEL_TAG];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        [[cell contentView] addSubview:titleLabel];
    }
    else
    {
        timeLabel = (UILabel *)[[cell contentView] viewWithTag:TIMELABEL_TAG];
        titleLabel = (UILabel *)[[cell contentView] viewWithTag:TITLELABEL_TAG];
    }

    Story *story = [stories objectAtIndex:[indexPath row]];

    [timeLabel setText:[[self shortTimeFormatter] stringFromDate:[story date]]];
    [titleLabel setText:[story title]];

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stories count];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([stories count])
        return nil;
    else
        return NSLocalizedString(@"LivetickerController.noTicker", nil);
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setDisplayedStoryIndex:[indexPath row]];

    Story            *story = [stories objectAtIndex:[indexPath row]];
    DetailLiveticker *detailController = [[DetailLiveticker alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle] story:story];

    [[self navigationController] pushViewController:detailController animated:YES];
    [detailController release];
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
    NSInteger diffCount = [parsedStories count] - [[self stories] count];

    if (diffCount > 0)
    {
        [self setDisplayedStoryIndex:[self displayedStoryIndex] + diffCount];
        if ([[[self navigationController] viewControllers] lastObject] != self)
            [self performSelectorOnMainThread:@selector(changeStory:) withObject:[[[[self navigationController] viewControllers] lastObject] storyControl]
                                waitUntilDone:NO];
    }

    [self setStories:parsedStories];
}



- (void)parser:(ATXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [(LivetickerNavigationController *)[self navigationController] setReloadTimer:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Content konnte nicht geladen werden", nil) message:@"Der Feed ist im Moment nicht verfügbar. Versuche es bitte später erneut."
													   delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
