//
//  FPPlacesService.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPPlacesService.h"
#import "FPMappingService.h"
#import "FPGoogleConstants.h"

@implementation FPPlacesService

+ (NSURLSessionDataTask *)fetchPlacesNearLatitude:(CGFloat)latitude
                                        longitude:(CGFloat)longitude
                                           radius:(NSInteger)radius
                                       completion:(FPPlacesServiceCompletion)completion {
    NSString *service = [NSString stringWithFormat:kGooglePlacesApiUrl, latitude, longitude, @(radius), kGoogleAPIKey];
    NSURL *url = [NSURL URLWithString:service];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                     if (error && completion) {
                                                                             completion(nil, error);
                                                                         return;
                                                                     }
                                                                     
                                                                     NSError *jsonError;
                                                                     NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                              options:NSJSONReadingAllowFragments
                                                                                                                                error:&jsonError];
                                                                     if (jsonError && completion) {
                                                                         completion(nil, jsonError);
                                                                         return;
                                                                     }
                                                                     NSArray *results = jsonDict[@"results"];
                                                                     NSArray *mappedItems = [FPMappingService mappedPairItemsFromRepresentation:results];
                                                                     if (completion) {
                                                                         completion(mappedItems, error);
                                                                     }
                                                                 }];
    
    [dataTask resume];
    return dataTask;
}

+ (void)fetchFakeLocationPlacesWithCompletion:(FPPlacesServiceCompletion)completion {
    NSError *jsonError;
    NSURL *localFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FakeResponse" ofType:@"json"]];
    NSData *contentOfLocalFile = [NSData dataWithContentsOfURL:localFileURL];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:contentOfLocalFile
                                                             options:0
                                                               error:&jsonError];
    if (jsonError && completion) {
        completion(nil, jsonError);
        return;
    }
    NSArray *results = jsonDict[@"results"];
    NSArray *mappedItems = [FPMappingService mappedPairItemsFromRepresentation:results];
    if (completion) {
        completion(mappedItems, nil);
    }
}

@end
