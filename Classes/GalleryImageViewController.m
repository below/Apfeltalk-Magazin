//
//  GalleryImageViewController.m
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
 
#import "GalleryImageViewController.h"
#import "Image.h"
#import "ImageView.h"

@implementation GalleryImageViewController

@synthesize element;
@synthesize atomicElementFlippedView;
@synthesize atomicElementView;
@synthesize containerView;
@synthesize reflectionView;
@synthesize flipIndicatorButton;
@synthesize frontViewIsVisible;


#define reflectionFraction 0.35
#define reflectionOpacity 0.5


- (id)init {
	if (self = [super init]) {
		element = nil;
		atomicElementView = nil;
		atomicElementFlippedView = nil;
		self.frontViewIsVisible=YES;
		self.hidesBottomBarWhenPushed = YES;

	}
	return self;
}


- (void)loadView {	
	NSLog(@"loadView");
	
	// create and store a container view

	UIView *localContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.containerView = localContainerView;
	[localContainerView release];
	
	containerView.backgroundColor = [UIColor blackColor];
	
	CGSize preferredAtomicElementViewSize = [ImageView preferredViewSize];
	
	CGRect viewRect = CGRectMake((containerView.bounds.size.width-preferredAtomicElementViewSize.width)/2,
								 (containerView.bounds.size.height-preferredAtomicElementViewSize.height)/2-40,
								 preferredAtomicElementViewSize.width,preferredAtomicElementViewSize.height);
	
	// create the atomic element view
	ImageView *localAtomicElementView = [[ImageView alloc] initWithFrame:viewRect];
	self.atomicElementView = localAtomicElementView;
	[localAtomicElementView release];
	
	// add the atomic element view to the containerView
	NSLog(@"controller. element: %@", element);
//	atomicElementView.element = element;	
	//testing
	
	//we need to tell the element where our image is located.... for now its hardcoded!!!
	atomicElementView.element =	[[Image alloc] init];
	[containerView addSubview:atomicElementView];
	
	atomicElementView.viewController = self;
	self.view = containerView;

	// create the reflection view
	CGRect reflectionRect=viewRect;

	// the reflection is a fraction of the size of the view being reflected
	reflectionRect.size.height=reflectionRect.size.height*reflectionFraction;
	
	// and is offset to be at the bottom of the view being reflected
	reflectionRect=CGRectOffset(reflectionRect,0,viewRect.size.height);
	
	UIImageView *localReflectionImageView = [[UIImageView alloc] initWithFrame:reflectionRect];
	self.reflectionView = localReflectionImageView;
	[localReflectionImageView release];
	
	// determine the size of the reflection to create
	NSUInteger reflectionHeight=atomicElementView.bounds.size.height*reflectionFraction;
	
	// create the reflection image, assign it to the UIImageView and add the image view to the containerView
	reflectionView.image=[self.atomicElementView reflectedImageRepresentationWithHeight:reflectionHeight];
	reflectionView.alpha=reflectionOpacity;
	
	[containerView addSubview:reflectionView];

	
	UIButton *localFlipIndicator=[[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
	self.flipIndicatorButton=localFlipIndicator;
	[localFlipIndicator release];
	
	// front view is always visible at first
	[flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"flipper_list_blue.png"] forState:UIControlStateNormal];
	
	UIBarButtonItem *flipButtonBarItem;
	flipButtonBarItem=[[UIBarButtonItem alloc] initWithCustomView:flipIndicatorButton];
	
	[self.navigationItem setRightBarButtonItem:flipButtonBarItem animated:YES];
	[flipButtonBarItem release];
	
	[flipIndicatorButton addTarget:self action:@selector(flipCurrentView) forControlEvents:(UIControlEventTouchDown   )];
	 

}

- (void)dealloc {
	[atomicElementView release];
	[reflectionView release];
	[atomicElementFlippedView release];
	[element release];
	[super dealloc];
}


@end
