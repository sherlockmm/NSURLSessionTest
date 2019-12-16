//
//  ViewController.m
//  NSURLSessionTest
//
//  Created by wzm on 2019/12/14.
//  Copyright © 2019 wzm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /**
     问题描述:
     1. 当APP 退到后台 再不断的切换网络，在从后台唤醒 CPU 会持续100%消耗 导致手机发烫
     2. 这时候 会有一个com.apple.network.connection 队列
     3. 还有一个com.apple.overCommit 队列 和 com.apple.CFNetwork.LoaderQ
     4. 最终通过汇编追进去是一个 libusrtcp.dylib 一直在这个 __nw_protocol_tcp_wake_read_closed_block 中处理
     */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"] cachePolicy:1 timeoutInterval:10.0];
    request.HTTPMethod = @"GET";
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request];
    [sessionTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *) __unused task didCompleteWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [session finishTasksAndInvalidate];
        if(error){
            NSLog(@"error %@", error);
        }else{
            NSLog(@"success");
        }
    });
}

- (void)URLSession:(NSURLSession *) __unused session dataTask:(NSURLSessionDataTask *) __unused dataTask didReceiveData:(NSData *)data {
    NSLog(@"%s",__FUNCTION__);
}

- (void)URLSession:(NSURLSession *) __unused session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    if ([response respondsToSelector:@selector(statusCode)]) {
        NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode == 404) {
            [dataTask cancel];
            if (completionHandler) {
                completionHandler(NSURLSessionResponseCancel);
            }
            return;
        }
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

- (void)URLSession:(NSURLSession *) __unused session task:(NSURLSessionTask *) __unused task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSURLRequest *newRequest = request;
    if (response) {
        newRequest = nil;
    }
    if (completionHandler) {
        completionHandler(newRequest);
    }
}

@end
