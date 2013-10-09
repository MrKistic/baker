//
//  BakerAnalyticsEvents.m
//  Baker
//
//  ==========================================================================================
//
//  Copyright (c) 2010-2013, Davide Casali, Marco Colombo, Alessandro Morandi
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of
//  conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//  Neither the name of the Baker Framework nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific prior written
//  permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "BakerAnalyticsEvents.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


@implementation BakerAnalyticsEvents


#pragma mark - Singleton

+ (BakerAnalyticsEvents *)sharedInstance {
    static dispatch_once_t once;
    static BakerAnalyticsEvents *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    // ****** Add here your analytics code
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-xxxxxxxx-x"];
    
    
    // ****** Register to handle events
    [self registerEvents];
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark - Events

- (void)registerEvents {
    // Register the analytics event that are going to be tracked by Baker.
    
    NSArray *analyticEvents = [NSArray arrayWithObjects:
                               @"BakerApplicationStart",
                               @"BakerIssueDownload",
                               @"BakerIssueOpen",
                               @"BakerIssueClose",
                               @"BakerIssuePurchase",
                               @"BakerIssueArchive",
                               @"BakerSubscriptionPurchase",
                               @"BakerViewPage",
                               @"BakerGotoPage",
                               @"BakerViewIndexOpen",
                               @"BakerViewModalBrowser",
                               nil];
    
    for (NSString *eventName in analyticEvents) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveEvent:)
                                                     name:eventName
                                                   object:nil];
    }
    

}

- (void)receiveEvent:(NSNotification *)notification {

    /*

    Google v3 example:

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"play"          // Event label
                                                           value:nil] build]];    // Event value
    */

    NSLog(@"[BakerAnalyticsEvent] Received event %@", [notification name]); // Uncomment this to debug
    NSLog(@"[BakerAnalyticsEvent] Received object %@", [notification object]); // Uncomment this to debug
    NSLog(@"[BakerAnalyticsEvent] Received userInfo %@", [notification userInfo]); // Uncomment this to debug

    // If you want, you can handle differently the various events
    if ([[notification name] isEqualToString:@"BakerApplicationStart"]) {

      // Track here when the Baker app opens
      NSLog(@"[Google Analytics] Opening Application");
      NSLog(@"[Google Screen Name] Home Screen");
      [tracker set:kGAIScreenName value:@"Home Screen"];
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"OpenApplication"
                              label:@"Teachers Academy App Open"
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerIssueDownload"]) {

      // Track here when an issue download is requested
      IssueViewController *issueView = [notification object];
      NSLog(@"[Google Analytics] Downloading Issue %@", issueView.issue.title);
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"IssueDownload"
                              label:issueView.issue.title
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerIssueOpen"]) {

      // Track here when an issue is opened to be read
      IssueViewController *issueView = [notification object];
      NSLog(@"[Google Analytics] Opening Issue %@", issueView.issue.title);
      NSLog(@"[Google Screen Name] %@", issueView.issue.title);
      [tracker set:kGAIScreenName value:issueView.issue.title];
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"IssueOpen"
                              label:issueView.issue.title
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerIssueClose"]) {

      // Track here when an issue that was being read is closed
      BakerViewController *bakerview = [notification object];
      NSLog(@"[Google Analytics] Closing Issue %@", bakerview.book.title);
      NSLog(@"[Google Screen Name] Home Screen");
      [tracker set:kGAIScreenName value:@"Home Screen"];
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"IssueClose"
                              label: bakerview.book.title
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerIssuePurchase"]) {

      // Track here when an issue purchase is requested
      NSDictionary *userInfo = [notification userInfo];
      NSString *productId = [userInfo objectForKey:@"productId"];
      NSLog(@"[Google Analytics] Issue Purchased %@", productId);
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"PurchaseIssue"
                              label:productId
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerIssueArchive"]) {

      // Track here when an issue archival is requested
      IssueViewController *issueView = [notification object];
      NSLog(@"[Google Analytics] Archiving Issue %@", issueView.issue.title);
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"IssueArchive"
                              label:issueView.issue.title
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerSubscriptionPurchase"]) {

      // Track here when a subscription purchased is requested
      NSDictionary *userInfo = [notification userInfo];
      NSString *productId = [userInfo objectForKey:@"productId"];
      NSLog(@"[Google Analytics] Subscription Purchased %@", productId);
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"PurchaseSubscription"
                              label:productId
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerViewPage"]) {

      // Track here when a specific page is opened
      BakerViewController *bakerview = [notification object];
      NSLog(@"[Google Analytics] Viewing page %@", [NSString stringWithFormat: @"%@ : %d", bakerview.book.title, bakerview.currentPageNumber]);
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"ViewPage"
                              label: [NSString stringWithFormat: @"%@ : %d", bakerview.book.title, bakerview.currentPageNumber]
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerGotoPage"]) {

      // Track here when a specific page is opened
      BakerViewController *bakerview = [notification object];
      NSLog(@"[Google Analytics] Goto page %@", [NSString stringWithFormat: @"%@ : %d", bakerview.book.title, bakerview.currentPageNumber]);
      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"ViewPage"
                              label: [NSString stringWithFormat: @"%@ : %d", bakerview.book.title, bakerview.currentPageNumber]
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerViewIndexOpen"]) {

      // Track here the opening of the index and status bar
      BakerViewController *bakerview = [notification object];
      NSLog(@"[Google Analytics] Opening index %@", [NSString stringWithFormat: @"%@ : %d", bakerview.book.title, bakerview.currentPageNumber]);

      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory:@"action"
                              action:@"ViewBookIndex"
                              label:bakerview.book.title
                              value:nil]
      build]];

    } else if ([[notification name] isEqualToString:@"BakerViewModalBrowser"]) {

      // Track here the opening of the modal view
      NSDictionary *userInfo = [notification userInfo];
      NSString *url = [userInfo objectForKey:@"url"];
      NSLog(@"[Google Analytics] Loading a Modal WebView with URL: %@", url);

      [tracker send:[
        [GAIDictionaryBuilder createEventWithCategory: @"action"
                              action: @"OpenWebBrowser"
                              label: url
                              value: nil]
      build]];

    } else {

      // default
        
    }
}


@end
