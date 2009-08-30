//
//  Story.h
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 29.08.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Story : NSObject <NSCoding> {
	NSString *title;
	NSString *summary;
	NSDate *date;
	NSString *author;
	NSString *link;
}
@property (readwrite, copy) NSString *title;
@property (readwrite, copy) NSString *summary;
@property (readwrite, copy) NSDate *date;
@property (readwrite, copy) NSString *author;
@property (readwrite, copy) NSString *link;
@end
