//
//  SSCNewsFeeds.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/19/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "SSCNewsFeedManager.h"
#import "SSCAppDelegate.h"

@interface SSCNewsFeedManager  () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic) NSOperationQueue *feedQueue;
@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccount *facebookAccount;
@property (nonatomic) ACAccount *twitterAccount;
@property (nonatomic) NSURLSession *session;

@end

@implementation SSCNewsFeedManager

+(SSCNewsFeedManager*) sharedManager
{
    static dispatch_once_t pred;
    static SSCNewsFeedManager* shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SSCNewsFeedManager alloc] init];
        [shared setup];
    });
    
    return shared;
}

-(void) setup {
    if (!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    if (!self.feedQueue) {
        self.feedQueue = [NSOperationQueue new];
        
    }
    self.allFeeds = [[SSCNewsFeed alloc] init];
}

#pragma mark - news post interaction
-(void) tellFacebookToLikePost:(SSCNewsPost*) thePost
{
    //slrequest
}

#pragma mark - news post session methods
-(void) getNewsPosts {
    NSURL *urlToFeed = [NSURL URLWithString:@""];
    NSURLSessionConfiguration *sessionConfigs = [self setupSessionConfig];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfigs delegate:self delegateQueue:self.feedQueue];
    
    NSURLSessionDataTask *downloadFeed = [self.session dataTaskWithURL:urlToFeed completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *err;
            NSHTTPURLResponse *codeResponse = (NSHTTPURLResponse*) response;
            if (codeResponse.statusCode == 200) {
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                if (!err) {
                    [self.allFeeds makeFeed:dataDict];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsFeedDidFinishDownloading" object:nil];
                } else {
                    //did not get JSON data
                }
            } else {
                //received some other response
            }
        } else {
            //download task failed
        }
    }];
    
    [downloadFeed resume];
}

-(void) getNewerNewPosts:(NSDate *) time {
    
}

-(void) getOlderNewsPosts:(NSDate *) time {
    
}

#pragma mark - session configurations
-(NSURLSessionConfiguration*) setupSessionConfig {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept" :@"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.f;
    sessionConfig.timeoutIntervalForResource = 60.f;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    return sessionConfig;
}

#pragma mark - NSURLSessionDownloadDelegate methods

-(void)URLSession:(NSURLSession *)session
downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat percentDone = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    NSLog(@"%f / %f = %f",(float)totalBytesWritten, (float)totalBytesExpectedToWrite, percentDone);
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

@end
