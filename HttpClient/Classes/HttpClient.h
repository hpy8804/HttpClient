//
//  HttpClient.h
//  XXXXXX
//
//  Created by he yan on 2018/12/20.
//  Copyright © 2018 DreamCatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpResponse : NSObject
@property (assign, nonatomic) NSInteger statusCode;
@property (strong, nonatomic) NSDictionary *data;
@end

typedef void (^Response)(HttpResponse *response);
typedef void (^Progress)(float downLoadProgress);
NS_ASSUME_NONNULL_BEGIN

@interface HttpClient : NSObject
+ (void)GET:(NSString *)url response:(Response)rsp;
+ (void)POST:(NSString *)url param:(NSObject *)params response:(Response)rsp;
+ (void)DownLoad:(NSString *)url saveToPath:(NSString *)path progress:(Progress)downLoadProgress response:(Response)rsp;
@end

NS_ASSUME_NONNULL_END
