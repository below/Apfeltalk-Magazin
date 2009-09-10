//
//  Image.m
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

#import "Image.h"


@implementation Image

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	if ([self init]) {
		
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}
 
- (UIImage *)stateImageForAtomicElementView {
//	return [UIImage imageNamed:[NSString stringWithFormat:@"%@_256.png",state]];
	NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://www.apfeltalk.de/gallery/data/501/medium/100_2460.JPG"]];
	UIImage* image = [[UIImage alloc] initWithData:imageData];
	[imageData release];
	
	NSLog(@"returning image");
	return image;
}

@end
