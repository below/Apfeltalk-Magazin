//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//  Created by Stefan Kofler on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailGallery.h"
#import "RootViewController.h"

@implementation DetailGallery

- (NSString *) selectedCountry {
	if (selectedCountry == @"")
		return NSLocalizedString (@"--Kein Titel--", @"");
	else
		return selectedCountry;
}

- (NSString *) htmlString {
	NSString *nui = [NSString stringWithFormat:@"<center><b>%@</b></center> ",selectedSumary];
	NSString *link = [[self date] description];
	link = [link stringByReplacingOccurrencesOfString:@"#comments" withString:@"?onlycomments=yes"];
	NSString *str = selectedSumary;
	
	NSRange pos1 = [str rangeOfString: @"http://www.apfeltalk.de/gallery/data"]; //-42 .... 
	NSRange pos2 = NSMakeRange(1,2);
	if ([str rangeOfString:@".jpg\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".jpg\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".JPG\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".JPG\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".png\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".png\" alt="]; //+4 ....
	}	
	if ([str rangeOfString:@".PNG\" alt="].location !=NSNotFound){
		pos2 = [str rangeOfString: @".PNG\" alt="]; //+4 ....
	}
	pos2.location = pos2.location + 4;
	NSRange myRange2 = NSMakeRange(pos1.location,pos2.location - pos1.location);
	str = [selectedSumary substringWithRange:myRange2];
	
	str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
	NSArray *tags = [NSArray arrayWithObjects: @"a", @"b", @"p", @"br", @"div",@"li", nil];
	nui = [self strip_tags:nui :tags];
	
	NSString *showpicture = [NSString stringWithFormat:@"<img src=\"%@\" width=\"275\" height=\"181\" alt=\"No Medium Picture.\" /> ", str];
	NSString *name2 = [NSString stringWithFormat:@"<head> <title>Kommentare</title> <style type=\"text/css\"> body		{font-family: \"Helvetica\", sans-serif; font-size:13px; margin: 0; padding: 0; background: url(http://touch-mania.com/wp-content/plugins/wptouch/themes/default/images/blank.gif) repeat scroll 0 0;} div.button 	{border:1px solid #B1B1B1;cursor:pointer;font-weight:bold;margin-left:10px;margin-right:10px; background-color: white; padding-bottom:10px; padding-left:10px;padding-top:10px;text-shadow:0 1px 0 #FFFFFF; margin-top: 10px;} div#frame	{padding: 0; margin: 0;} iframe		{padding: 0; margin: 0; border: 0;} </style> <script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\" /> <script type=\"text/javascript\"> $(document).ready(function() { $(\"div#frame\").hide(); $(\"div#show\").click(function(){ $(\"div#frame\").slideToggle(); }); }); </script> </div> <meta name=\"viewport\" content=\"maximum-scale=1.0 width=device-width initial-scale=1.0 user-scalable=no\" /> </head> <body> <div id=\"wrapper\"> <div class=\"button\" id=\"show\"> 	 Zeige Kommentare </div> <div id=\"frame\"> <iframe width=\"320\" height=\"100%\" scrolling=\"yes\" src=\"%@\" frameborder=\"0\"/> </div>  </div> </div> </body> ", link];
	
	return [NSString stringWithFormat:@"<div style=\"-webkit-border-radius: 10px;background-color: white;border: 1px solid rgb(173, 173, 173);margin: 10px;padding:10px;\"> %@ <br> %@ <br> %@", showpicture, nui, name2];
}

-(IBAction)speichern:(id)sender
{
	NSString *str = selectedSumary;
	
	NSRange pos1 = [str rangeOfString: @"http://www.apfeltalk.de/gallery/data"]; //-42 .... 
	NSRange pos2 = NSMakeRange(1,2);
	NSRange findRange;
	
	findRange = [[str lowercaseString] rangeOfString:@".jpg\" alt="];
	if (findRange.location !=NSNotFound){
		pos2 = findRange; //+4 ....
	}
	else {
		findRange = [[str lowercaseString] rangeOfString:@".png\" alt="];
		if (findRange.location !=NSNotFound){
			pos2 = findRange; //+4 ....
		}	
	}
	pos2.location = pos2.location + 4;
	NSRange myRange2 = NSMakeRange(pos1.location,pos2.location - pos1.location);
	str = [selectedSumary substringWithRange:myRange2];
	
	str = [str stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];	
	UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:str]]];
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Bild gespeichert" message:@"Das Bild wurde erfolgreich in deine Fotogallerie gespeichert." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

@end
