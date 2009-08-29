//
//  DetailViewController.h
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Story.h"

@interface DetailViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UILabel *datum;
	IBOutlet UILabel *lblText;
	IBOutlet UIImageView *thumbnail;
	IBOutlet UIScrollView *scrollView2;
	IBOutlet UITextView *sunText;
	IBOutlet UINavigationBar *Textvar;
	IBOutlet UIWebView *webview;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *authorLabel;

	Story *story;
}
@property (readwrite, retain) Story *story;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory;
- (NSString *)strip_tags:(NSString *)data :(NSArray *)valid_tags;

@end
