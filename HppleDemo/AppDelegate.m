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
            [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
            [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"Upgrade-Insecure-Requests"];
            [manager.requestSerializer setValue:@"www.yifone.com" forHTTPHeaderField:@"Host"];
            [manager.requestSerializer setValue:@"c=%5B%7B%22LoadTime%22%3A16%2C%22imgUrl%22%3A%22%22%2C%22linkUrl%22%3A%22http%3A%2F%2Fwww.yifone.com%2FProduct%2FProductDetail%3Fpkid%3D2856%22%2C%22title%22%3A%22%20iPhone6%20plus%22%7D%2C%7B%22LoadTime%22%3A16%2C%22imgUrl%22%3A%22%22%2C%22linkUrl%22%3A%22http%3A%2F%2Fwww.yifone.com%2FProduct%2FProductDetail%3Fpkid%3D1419%22%2C%22title%22%3A%22iphone5s%22%7D%2C%7B%22LoadTime%22%3A16%2C%22imgUrl%22%3A%22%22%2C%22linkUrl%22%3A%22http%3A%2F%2Fwww.yifone.com%2FProduct%2FProductDetail%3Fpkid%3D1428%22%2C%22title%22%3A%22%E4%B8%89%E6%98%9Fnote3%22%7D%2C%7B%22LoadTime%22%3A16%2C%22imgUrl%22%3A%22%22%2C%22linkUrl%22%3A%22http%3A%2F%2Fwww.yifone.com%2FProduct%2FProductDetail%3Fpkid%3D1214%22%2C%22title%22%3A%22%E4%B8%89%E6%98%9Fnote2%22%7D%5D; Hm_lvt_49618d01fe259a7c123bdb2ffe484297=1447655166,1450227883,1450229132; Hm_lpvt_49618d01fe259a7c123bdb2ffe484297=1450229147" forHTTPHeaderField:@"Cookie"];
            NSString *URL = [NSString stringWithFormat:@"http://www.yifone.com/Product/Search?pageindex=%d&fid=93&typeid=%d", page, type];
            sleep(2);
            [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                            NSLog(@"%@", log);
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        j--;
                        NSLog(@"Error: %@", error);
                        if (j == 0) {
                            int a = 0;
                            a++;
                            NSLog(@"%@", log);
                        }
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
