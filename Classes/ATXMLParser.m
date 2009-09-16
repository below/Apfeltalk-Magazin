//
//  ATXMLParser.m
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

#import "ATXMLParser.h"
#import "Story.h";


@implementation ATXMLParser

@synthesize delegate;
@synthesize storyClass;
@synthesize story;
@synthesize stories;
@synthesize dateElementName;
@synthesize dateFormatter;
@synthesize currentContent;
@synthesize desiredElementKeys;


+ (ATXMLParser *)parserWithURLString:(NSString *)urlString
{
    return [[[ATXMLParser alloc] initWithURLString:urlString] autorelease];
}



- (id)initWithURLString:(NSString *)urlString
{
    if (self = [super init])
    {
        [self setStoryClass:[Story self]];
        [self setDateElementName:@"pubDate"];
        [self setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz" localeIdentifier:@"en_US"];

        NSArray      *names = [NSArray arrayWithObjects:@"title", @"link", [self dateElementName], @"dc:creator", @"content:encoded", nil];
        NSArray      *keys = [NSArray arrayWithObjects:@"title", @"link", @"date", @"author", @"summary", nil];
        NSDictionary *elementKeys = [NSDictionary dictionaryWithObjects:keys forKeys:names];
        [self setDesiredElementKeys:elementKeys];

        xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
        [xmlParser setDelegate:self];
    }

    return self;
}



- (void)setDateFormat:(NSString *)format localeIdentifier:(NSString *)identifier
{
    NSLocale        *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:format];
    [formatter setLocale:locale];
    [self setDateFormatter:formatter];

    [locale release];
    [formatter release];
}



- (BOOL)parse
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return [xmlParser parse];
}



- (void)parseInBackgroundWithDelegate:(id <ATXMLParserDelegateProtocol>)object
{
    BOOL               result;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [self setDelegate:object];

    result = [self parse];
    if ([(NSObject *)delegate respondsToSelector:@selector(parser:didFinishedSuccessfull:)])
        [delegate parser:self didFinishedSuccessfull:result];

    [pool release];
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [self setStories:[NSMutableArray array]];
}



- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [delegate parser:self setParsedStories:stories];
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"])
    {
        id storyObject = [[storyClass alloc] init];
        [self setStory:storyObject];
        [storyObject release];
    }
    else if ([[desiredElementKeys allKeys] containsObject:elementName])
    {
        [self setCurrentContent:[NSMutableString string]];
    }
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[[self currentContent] appendString:string];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"])
    {
        [stories addObject:[self story]];
    }
    else if ([[desiredElementKeys allKeys] containsObject:elementName])
    {
        if ([elementName isEqualToString:[self dateElementName]])
        {
            NSDate *date = [[self dateFormatter] dateFromString:[self currentContent]];
            [story setValue:date forKey:[desiredElementKeys objectForKey:elementName]];
        }
        else
        {
            [story setValue:[self currentContent] forKey:[desiredElementKeys objectForKey:elementName]];
        }
    }
}



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parser:self parseErrorOccurred:parseError];
}

- (void)dealloc
{
    [story release];
    [stories release];
    [dateElementName release];
    [dateFormatter release];
    [currentContent release];
    [desiredElementKeys release];
    [xmlParser release];
	
    [super dealloc];
}

@end
