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

#import "PodcastController.h"
#import "DetailPodcast.h"

@implementation PodcastController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(shakeToReload) {
		NSLog(@"Shake To Reload is on, activae UIAccelerometer");
		[self activateShakeToReload:self];
	} else {
		NSLog(@"Shake To Reload is off, don't activae UIAccelerometer");
	}	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// if our view is not active/visible, we don't want to receive Accelerometer events
	if(shakeToReload)
	{
		UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
		accel.delegate = nil;
	}
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    ATXMLParser         *parser = [[ATXMLParser alloc] initWithURLString:URL];
    NSMutableDictionary *desiredKeys = [NSMutableDictionary dictionaryWithDictionary:[parser desiredElementKeys]];

    [desiredKeys removeObjectForKey:@"link"];
    [desiredKeys setObject:@"" forKey:@"enclosure"];
    [parser setDesiredElementKeys:desiredKeys];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
}

- (Class) detailControllerClass {
	return [DetailPodcast self];
}

- (NSString *) documentPath {
	return @"http://feeds2.feedburner.com/apfeltalk-small";
}


- (void)updateApplicationIconBadgeNumber {
	//We don't want to update the Application Icon Badge for Podcasts
	[super updateApplicationIconBadgeNumber];
}

// handle acceleromter event
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	if ([self isShake:acceleration]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		if (vibrateOnReload) {
			AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
		}
		[self parseXMLFileAtURL:[self documentPath]];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@end
