//
//  TwitterRequest.h
//  Chirpie
//
//  Created by Brandon Trebitowski on 6/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface TwitterRequest : NSObject {
	NSString			*username;
	NSString			*password;
	NSMutableData		*receivedData;
	NSMutableURLRequest	*theRequest;
	NSURLConnection		*theConnection;
	id					delegate;
	SEL					callback;
	SEL					errorCallback;
	
	BOOL				isPost;
	NSString			*requestBody;
}

@property(nonatomic, retain) NSString	   *username;
@property(nonatomic, retain) NSString	   *password;
@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) id			    delegate;
@property(nonatomic) SEL					callback;
@property(nonatomic) SEL					errorCallback;

-(void)friends_timeline:(id)requestDelegate requestSelector:(SEL)requestSelector;
-(void)request:(NSURL *) url;

-(void)statuses_update:(NSString *)status delegate:(id)requestDelegate requestSelector:(SEL)requestSelector;

@end
