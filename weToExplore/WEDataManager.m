//
//  GDDataManager.m
//  weToExplore
//
//  Created by Daniel Tan on 7/30/16.
//  Copyright © 2016 Gnodnate. All rights reserved.
//

#import "WEDataManager.h"
#import "AFNetworking.h"
#import "WETopicDetail.h"

#define BaseURL @"https://www.v2ex.com/api/"
NSString *HotTitle = @"topics/hot.json";
//NSString *LatestTitleShortURL = @"topics/latest.json";
NSString *repliesShortURL = @"replies/show.json";
NSString *userDetailShortURL = @"members/show.json";
#define PointInfo

@interface WEDataManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation WEDataManager

@synthesize sessionManager =_sessionManager;


- (instancetype)init {
    self = [super init];
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    return self;
}


- (NSURLSessionDataTask*) parseURLString:(NSString*)url
                          withParameters:(id)parameters
                success:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                failure:(void (^)(NSError *error))failure  {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [self.sessionManager
                                  GET:url
                                  parameters:parameters
                                  progress:nil
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

    return  task;

}

- (void)getTopics {
    [self parseURLString:HotTitle
          withParameters:nil
                 success:^(NSURLSessionDataTask *dataTask, id responseObject) {
        NSMutableArray *mutableTopicArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in responseObject) {
            [mutableTopicArray addObject:[[WETopicDetail alloc] initWithDictionary:dic]];
        }
        self.topicArray = mutableTopicArray;
                 } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)getRepliesForTopic:(NSNumber *)topicID
                   success:(void (^)(NSArray *array))success
                    failed:(void (^)(NSError *error))failed {
    NSDictionary *parameters =  @{
                                  @"topic_id": topicID
                                  };
    [self parseURLString:repliesShortURL
          withParameters:parameters
                 success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                     success(responseObject);
                 } failure:^(NSError *error) {
                     NSLog(@"%@", error);
                 }];
}

- (void)getDetailofUser:(NSNumber *)userID
                success:(void (^)(NSDictionary *dic))success
                 failed:(void (^)(NSError *error))failed {
    NSDictionary *parameters = @{ @"id" : userID };
    [self parseURLString:userDetailShortURL
          withParameters:parameters
                 success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                     success(responseObject);
                 } failure:^(NSError *error) {
                     failed(error);
                 }];
}
@end
