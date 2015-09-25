//
//  AppDelegate.m
//  HppleDemo
//
//  Created by R0CKSTAR on 15/7/9.
//
//

#import "AppDelegate.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "Base64.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableString *log = [NSMutableString new];
    __block int j = 0;
    NSArray *types = @[@(5), @(6), @(16), @(17), @(18), @(19), @(21), @(22), @(23),
                       @(24), @(25), @(66), @(67), @(68), @(69), @(78), @(80), @(84),
                       @(85), @(86), @(87), @(88), @(89), @(90), @(91), @(149), @(173),
                       @(175), @(258), @(259)];
    [types enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int type = [obj intValue];
        for (int page = 1; page < 40; page++) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer new];
            NSString *URL = [NSString stringWithFormat:@"http://www.yifone.com/Product/Search?pageindex=%d&fid=93&typeid=%d", page, type];
            [manager POST:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                TFHpple *doc      = [[TFHpple alloc] initWithHTMLData:responseObject];
                NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='body']/section[3]/section[2]/ul[2]/li/a"];
                for (int i = 0; i < [elements count]; i++) {
                    TFHppleElement *e = [elements objectAtIndex:i];
                    NSString *pid = [[[e objectForKey:@"href"] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"/Product/ProductDetail?pkid=" withString:@""];
                    NSString *name = nil;
                    for (TFHppleElement *t in e.children) {
                        BOOL shouldBreak = NO;
                        if ([[t tagName] isEqualToString:@"p"]) {
                            for (TFHppleElement *tt in t.children) {
                                if ([[tt tagName] isEqualToString:@"img"]) {
                                    name = [tt objectForKey:@"alt"];
                                    shouldBreak = YES;
                                    break;
                                }
                            }
                        }
                        if (shouldBreak) {
                            break;
                        }
                    }
                    j++;
                    
                    NSString *URL = [NSString stringWithFormat:@"http://www.yifone.com/api/OrderPermition/GetOrderPrice?accessToken=MjliNDExZDgtODgyMS00ZTM3LWJlMWYtZjk2YjA1MTBlYmE1&timestamp=MjAxNS0wOS0xNA==&sign=OWFhYzg1MDIzMjlmNTRjOGQzNjE3MDUwNzAxZDNmNTE=&model_id=%@&sub_options=24,73,57,39,11,17,27,81,85,64,13,74,78,88,91,34,69", pid];
                    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                        [log appendString:name];
                        [log appendString:@";"];
                        NSArray *others = json[@"data"][@"others"];
                        [others enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString *mname = obj[@"name"];
                            int mprice = [obj[@"price"] intValue];
                            [log appendFormat:@"%@;%d;", mname, mprice];
                        }];
                        [log appendString:@"\n"];
                        j--;
                        if (j == 0) {
                            int a = 0;
                            a++;
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        j--;
                        if (j == 0) {
                            int a = 0;
                            a++;
                        }
                        NSLog(@"Error: %@", error);
                    }];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    }];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int t = 0; t < 10000000; t++) {
            sleep(1);
        }
    });
    self.window = [UIWindow new];
    UIViewController *vc = [UIViewController new];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
