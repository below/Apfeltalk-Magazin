//
//  RootViewController.h
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

#define kAccelerationThreshold        2.2
#define kUpdateInterval               (1.0f/10.0f)

#import "ATXMLParser.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DetailViewController.h"
#import <MessageUI/MessageUI.h>


@interface RootViewController : UITableViewController <ATXMLParserDelegateProtocol, MFMailComposeViewControllerDelegate>
{
	IBOutlet UITableView * newsTable;

	NSArray *stories;

	// should we show Icon Badges. (this could be switched on/off in preferences pane)
	BOOL showIconBadge;

	// should we use shake to relad
	BOOL shakeToReload;
	
	// should we vibrate on reload
	BOOL vibrateOnReload;

@protected
	sqlite3 * database;
}

@property(retain) NSArray *stories;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)openSafari:(id)sender;
- (IBAction)about:(id)sender;

- (NSString *)supportFolderPath;
- (NSString *)documentPath;
- (Class) detailControllerClass;

- (void)updateApplicationIconBadgeNumber;
- (BOOL)databaseContainsURL:(NSString *)link;

- (BOOL)isShake:(UIAcceleration *)acceleration;
- (void)activateShakeToReload:(id)delegate;

@end
