//
//  LivetickerController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
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

#import "LivetickerController.h"
#import "Story.h"


@implementation LivetickerController

@synthesize stories;
@synthesize reloadTimer;
@synthesize shortTimeFormatter;


- (void)setReloadTimer:(NSTimer *)timer
{
    if (timer != reloadTimer)
    {
        [reloadTimer invalidate];
        [reloadTimer release];
        reloadTimer = [timer retain];
    }
}



- (void)dealloc
{
    [stories release];
    if (reloadTimer)
    {
        [reloadTimer invalidate];
        [reloadTimer release];
    }

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



- (void)viewWillAppear:(BOOL)animated
{
    [self setReloadTimer:[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(reloadTickerEntries:) userInfo:nil repeats:YES]];
    [self reloadTickerEntries:nil];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [self setReloadTimer:nil];
}



- (NSString *)dateElementName
{
    return @"pubDate";  // Can be inherited from the super class
}



- (void)reloadTickerEntries:(NSTimer *)timer
{
    NSArray      *names = [NSArray arrayWithObjects:@"title", @"link", [self dateElementName], @"dc:creator", @"content:encoded", nil];
    NSArray      *keys = [NSArray arrayWithObjects:@"title", @"link", @"date", @"author", @"summary", nil];
    NSDictionary *elementKeys = [NSDictionary dictionaryWithObjects:keys forKeys:names];

    ATXMLParser  *parser = [ATXMLParser parserWithURLString:@"http://feeds.apfeltalk.de/apfeltalk-live"];

    [parser setDelegate:self];
    [parser setStoryClass:[Story self]];
    [parser setDateElementName:[self dateElementName]];
    [parser setDesiredElementKeys:elementKeys];

    if ([parser parse])
        [(UITableView *)[self view] reloadData];
    else
        [self setReloadTimer:nil];
}



#pragma mark -
#pragma mark UITableViewDataSource methods

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



#pragma mark -
#pragma mark ATXMLParserDelegateProtocol

- (void)parser:(ATXMLParser *)parser setParsedStories:(NSArray *)parsedStories
{
    [self setStories:parsedStories];
}



- (void)parser:(ATXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self setReloadTimer:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Parsing Error", nil) message:[parseError localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
