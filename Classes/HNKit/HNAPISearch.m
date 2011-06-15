//
//  HNAPISearch.m
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "HNAPISearch.h"
#import "JSON.h"
#import "HNKit.h"

@class HNEntry;

@implementation HNAPISearch

@synthesize entries;
@synthesize responseData;
@synthesize searchType;

- (id)init {
	if (self = [super init]) {
		self.searchType = kHNSearchTypeInteresting;
	}
	return self;
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (responseData == nil) {
		self.responseData = [[NSMutableData alloc] init];
	}
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)handleResponse {
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSArray *rawResults = [[NSArray alloc] initWithArray:[[responseString JSONValue] objectForKey:@"results"]];
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:[rawResults count]];
	for (NSDictionary *result in rawResults) {
		NSDictionary *item = [self itemFromRaw:[result objectForKey:@"item"]];
		HNEntry *entry = [[HNEntry alloc] initWithType:kHNPageTypeItemComments identifier:[item objectForKey:@"identifier"]];

		[entry loadFromDictionary:item];
		[results addObject:entry];
	}
	self.entries = results;
	[responseString release];
	responseString = nil;
	[rawResults release];
	rawResults = nil;
	[results release];
	results = nil;

	NSDictionary *dictToBePassed = [NSDictionary dictionaryWithObject:entries forKey:@"array"];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"searchDone" object:nil userInfo:dictToBePassed];	
}

- (NSDictionary *)itemFromRaw:(NSDictionary *)rawDictionary {
	NSMutableDictionary *item = [NSMutableDictionary dictionary];
	NSNumber *points = [NSNumber numberWithInt:0];
    NSNumber *comments = [NSNumber numberWithInt:0];
	NSString *title = nil;
    NSString *user = nil;
    NSNumber *identifier = nil;
    NSString *body = nil;
    NSString *date = nil;
    NSString *url = nil;

	points = [rawDictionary valueForKey:@"points"];
	comments = [rawDictionary valueForKey:@"num_comments"];
	title = [rawDictionary valueForKey:@"title"];
	user = [rawDictionary valueForKey:@"username"];
	identifier = [rawDictionary valueForKey:@"id"];
	body = [rawDictionary valueForKey:@"text"];
	date = [rawDictionary valueForKey:@"create_ts"];
	url = [rawDictionary valueForKey:@"url"];

	if ((NSNull *)user != [NSNull null]) [item setObject:user forKey:@"user"];
	if ((NSNull *)points != [NSNull null]) [item setObject:points forKey:@"points"];
	if ((NSNull *)title != [NSNull null]) [item setObject:title forKey:@"title"];
	if ((NSNull *)comments != [NSNull null]) [item setObject:comments forKey:@"numchildren"];
	if ((NSNull *)url != [NSNull null]) [item setObject:url forKey:@"url"];
	if ((NSNull *)date != [NSNull null]) [item setObject:date forKey:@"date"];
	if ((NSNull *)body != [NSNull null]) [item setObject:body forKey:@"body"];
	if ((NSNull *)identifier != [NSNull null]) [item setObject:identifier forKey:@"identifier"];
	return item;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self handleResponse];
	responseData = nil;
}

- (void)performSearch:(NSString *)searchQuery {
	NSString *paramsString = nil;
	if (searchType == kHNSearchTypeInteresting) {
		paramsString = [NSString stringWithFormat:kHNSearchParamsInteresting, searchQuery];
	} else {
		paramsString = [NSString stringWithFormat:kHNSearchParamsRecent, searchQuery];
	}

	NSString *urlString = [NSString stringWithFormat:kHNSearchBaseURL, paramsString];
	NSURL *url = [NSURL URLWithString:urlString];

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection release];
	[request release];

	searchQuery = nil;
}

- (void)dealloc {
    [responseData release];
    [entries release];

    [super dealloc];
}

@end
