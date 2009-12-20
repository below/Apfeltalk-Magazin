//
//  ATMXMLUtilities.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 21.09.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "ATMXMLUtilities.h"
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#pragma mark special XML processing

NSString *extractTextFromHTMLForQuery (NSString *htmlInput, NSString *query) {
	NSString *value = nil;	
	
	NSData *data = [htmlInput dataUsingEncoding:NSUTF8StringEncoding];
	htmlDocPtr	doc = htmlReadMemory([data bytes],[data length], NULL, NULL, 0);
	// Create xpath evaluation context
	xmlXPathContextPtr xpathCtx = xmlXPathNewContext(doc);
	
	xmlChar * xpathExpr = (xmlChar*)[query UTF8String];
	
	xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
	if(xpathObj == NULL) {
		fprintf(stderr,"Error: unable to evaluate xpath expression \"%s\"\n", xpathExpr);
	}
	else  {
		xmlNodeSetPtr nodeset = xpathObj->nodesetval;
		if (nodeset && nodeset->nodeNr == 1 && nodeset->nodeTab[0]->children){
			xmlNodePtr child = nodeset->nodeTab[0]->children;
			
			if (child->type == XML_TEXT_NODE)
				value = [NSString stringWithCString:(char*)child->content encoding:NSUTF8StringEncoding];
		}
		xmlXPathFreeObject(xpathObj);
	}		
	
	xmlXPathFreeContext(xpathCtx); 
	xmlFreeDoc(doc); 
	xmlCleanupParser();	
	return value;
}
