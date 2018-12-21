//
//  HttpClient.m
//  XXXXXX
//
//  Created by he yan on 2018/12/20.
//  Copyright © 2018 DreamCatcher. All rights reserved.
//

#import "HttpClient.h"

#define kHttpReqTimeOut (15)

@implementation HttpResponse

@end

@interface HttpClient ()<NSURLSessionDelegate>
{
    NSMutableData *_mutRecievedData;
    NSString *_saveFilePath;
}
@property (copy, nonatomic) Response callBackRsp;
@property (copy, nonatomic) Progress downLoadProgress;
@end

@implementation HttpClient

+ (HttpClient *)sharedInstance
{
    return [[HttpClient alloc] init];
}
- (id)init
{
    if (self = [super init]) {
        _mutRecievedData = [NSMutableData data];
    }
    return self;
}

+ (void)GET:(NSString *)url response:(Response)rsp
{
    [[self sharedInstance] GET:url response:rsp];
}
- (void)GET:(NSString *)url response:(Response)rsp
{
    self.callBackRsp = rsp;
    NSMutableURLRequest *request = [self formatRequestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [self sendRequest:request];
}

+ (void)POST:(NSString *)url param:(NSObject *)params response:(Response)rsp
{
    [[self sharedInstance] POST:url param:params response:rsp];
}
- (void)POST:(NSString *)url param:(NSObject *)params response:(Response)rsp
{
    self.callBackRsp = rsp;
    NSMutableURLRequest *request = [self formatRequestWithURL:url];
    [request setHTTPMethod:@"POST"];
    if ([params isKindOfClass:[NSDictionary class]]) {
        request.HTTPBody =  [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    }else if ([params isKindOfClass:[NSData class]]){
        request.HTTPBody = (NSData *)params;
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self sendRequest:request];
}

+ (void)DownLoad:(NSString *)url saveToPath:(NSString *)path progress:(Progress)downLoadProgress response:(Response)rsp
{
    [[self sharedInstance] DownLoad:url saveToPath:path progress:downLoadProgress response:rsp];
}
- (void)DownLoad:(NSString *)url saveToPath:(NSString *)path progress:(Progress)downLoadProgress response:(Response)rsp
{
    self.callBackRsp = rsp;
    self.downLoadProgress = downLoadProgress;
    _saveFilePath = path;
    NSMutableURLRequest *request = [self formatRequestWithURL:url];
    [self sendDownLoadRequest:request];
}

#pragma mark -- NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    // 如果是请求证书信任，我们再来处理，其他的不需要处理
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        // 调用block
        completionHandler(NSURLSessionAuthChallengeUseCredential,cre);
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_mutRecievedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    [task cancel];
    [session invalidateAndCancel];
    NSError *err = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:_mutRecievedData options:NSJSONReadingAllowFragments error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_callBackRsp) {
            HttpResponse *rsp = [HttpResponse alloc];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (!error) {
                rsp.statusCode = httpResponse.statusCode;
            }else{
                rsp.statusCode = error.code;
            }
            rsp.data = jsonObject;
            self->_callBackRsp(rsp);
        }
    });
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:_saveFilePath error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    //进度百分比
    if (self->_downLoadProgress) {
        self->_downLoadProgress(100.0 *totalBytesWritten / totalBytesExpectedToWrite);
    }
}

#pragma mark --
- (NSMutableURLRequest *)formatRequestWithURL:(NSString *)url
{
    NSURL *reqURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:reqURL];
    return request;
}
- (void)sendRequest:(NSMutableURLRequest *)request
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
}
- (void)sendDownLoadRequest:(NSMutableURLRequest *)request
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}
@end
