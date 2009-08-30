//
//  Story.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at mac dot com), Stefan Kofler
//						Alexander von Below, Michael Fenske, Jesper (Graphics),
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

#import "Story.h"


@implementation Story
@synthesize title, summary, date, author, link;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		if ([aDecoder allowsKeyedCoding]) {
			[self setTitle:[aDecoder decodeObjectForKey:@"title"]];
			[self setSummary:[aDecoder decodeObjectForKey:@"summary"]];
			[self setDate:[aDecoder decodeObjectForKey:@"date"]];
			[self setAuthor:[aDecoder decodeObjectForKey:@"author"]];
			[self setLink:[aDecoder decodeObjectForKey:@"link"]];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[self title] forKey:@"title"];
	[aCoder encodeObject:[self summary] forKey:@"summary"];
	[aCoder encodeObject:[self date] forKey:@"date"];
	[aCoder encodeObject:[self author] forKey:@"author"];
	[aCoder encodeObject:[self link] forKey:@"link"];
}

- (void) dealloc
{
	[title release];
	[summary release];
	[date release];
	[author release];
	[link release];
	[super dealloc];
}

@end
