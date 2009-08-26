//
//  DetailViewController.h
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UILabel *datum;
	IBOutlet UILabel *lblText;
	IBOutlet UIImageView *thumbnail;
	IBOutlet UIScrollView *scrollView2;
	IBOutlet UITextView *sunText;
	NSString *selectedCountry;
	NSString *selectedSumary;
	NSString *selecteddate;
	IBOutlet UINavigationBar *Textvar;
	IBOutlet UIWebView *webview;
	IBOutlet UILabel *titel;
}
@property (nonatomic, retain) NSString *selectedCountry;
@property (nonatomic, retain) NSString *selectedSumary;
@property (nonatomic, retain) NSString *selecteddate;

- (NSString *)strip_tags:(NSString *)data :(NSArray *)valid_tags;

@end
