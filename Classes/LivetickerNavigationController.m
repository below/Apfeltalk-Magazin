//
//  LivetickerNavigationController.m
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

#import "LivetickerNavigationController.h"
#import "LivetickerController.h"


#define RELOAD_TIME 30


@implementation LivetickerNavigationController

@synthesize reloadTimer;


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
    if (reloadTimer)
    {
        [reloadTimer invalidate];
        [reloadTimer release];
    }

    [super dealloc];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    LivetickerController *rootViewController = (LivetickerController *)[[self viewControllers] objectAtIndex:0];

    [self setReloadTimer:[NSTimer scheduledTimerWithTimeInterval:RELOAD_TIME target:rootViewController selector:@selector(reloadTickerEntries:) userInfo:nil
                                                         repeats:YES]];
    [rootViewController reloadTickerEntries:[self reloadTimer]];
	
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setReloadTimer:nil];
}

@end
