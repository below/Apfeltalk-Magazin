//
//  ATXMLParser.h
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

#import <Foundation/Foundation.h>


@class ATXMLParser;


@protocol ATXMLParserDelegateProtocol

@optional
- (void)parser:(ATXMLParser *)parser didFinishedSuccessfull:(BOOL)success;
- (BOOL)parser:(ATXMLParser *)parser shouldAddParsedItem:(id)item;

@required
- (void)parser:(ATXMLParser *)parser setParsedStories:(NSArray *)parsedStories;
- (void)parser:(ATXMLParser *)parser parseErrorOccurred:(NSError *)parserError;

@end



#pragma mark -

@interface ATXMLParser : NSObject
{
    id <ATXMLParserDelegateProtocol> delegate;
    Class                            storyClass;
    id                               story;
    NSMutableArray                  *stories;
    NSString                        *dateElementName;
    NSDateFormatter                 *dateFormatter;
    NSMutableString                 *currentContent;
    NSDictionary                    *desiredElementKeys;

@private
    NSXMLParser  *xmlParser;
}

@property(assign) id <ATXMLParserDelegateProtocol> delegate;
@property(assign) Class storyClass;
@property(retain) id story;
@property(retain) NSMutableArray *stories;
@property(copy) NSString *dateElementName;
@property(retain) NSDateFormatter *dateFormatter;
@property(retain) NSMutableString *currentContent;
@property(retain) NSDictionary *desiredElementKeys;

+ (ATXMLParser *)parserWithURLString:(NSString *)urlString;

- (id)initWithURLString:(NSString *)urlString;
- (void)setDateFormat:(NSString *)format localeIdentifier:(NSString *)identifier;
- (BOOL)parse;
- (void)parseInBackgroundWithDelegate:(id <ATXMLParserDelegateProtocol>)object;

@end
