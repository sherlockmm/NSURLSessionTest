#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /**
     Problem description:
     1. When the application continuously cuts the mobile network from WiFi in the foreground, waking the CPU from the background will continue to consume 100%, causing the phone to become hot
     2. I found com.apple.network.connection queue
     3. com.apple.overCommit and com.apple.CFNetwork.LoaderQ
     */
    [self urlSessionTest];
}

- (void)urlSessionTest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://developer.apple.com"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    request.HTTPMethod = @"GET";
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request];
    [sessionTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [session finishTasksAndInvalidate];
        if(error){
            NSLog(@"error %@", error);
        }else{
            NSLog(@"success");
        }
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"%s",__FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%s",__FUNCTION__);
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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    NSURLRequest *newRequest = request;
    if (response) {
        newRequest = nil;
    }
    if (completionHandler) {
        completionHandler(newRequest);
    }
}

- (void)applicationState {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)didEnterBackground {
    
}

- (void)willEnterForeground {
    
}

- (void)becomeActive {
    
}

- (void)resignActive {
    
}

@end
