//
//  main.m
//  HppleDemo
//
//  Created by Vytautas Galaunia on 11/25/14.
//
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "AFNetworking.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSLog(@"\n\n\n");
        NSMutableString *log = [NSMutableString new];
        for (int cid = 1; cid < 40; cid++) {
            for (int i = 1; i < 90; i++) {
                NSData  *data     = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://aihuishou.com/product/search?cid=%d&bid=0&keyword=&pageIndex=%d", cid, i]]];
                
                TFHpple *doc      = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *elements = [doc searchWithXPathQuery:@"//ul[@class='products']/li/a"];
                for (int j = 0; j < [elements count]; j++) {
                    TFHppleElement *e = [elements objectAtIndex:j];
                    NSString *href    = [e objectForKey:@"href"];
                    NSString *pid     = [href stringByReplacingOccurrencesOfString:@"/product/" withString:@""];
                    pid               = [pid stringByReplacingOccurrencesOfString:@".html" withString:@""];
                    [log appendFormat:@"%@;", pid];
                    NSString *image = @"";
                    NSString *name  = @"";
                    for (TFHppleElement *t in e.children) {
                        if ([[t tagName] isEqualToString:@"img"]) {
                            image = [t objectForKey:@"src"];
                            [log appendFormat:@"%@;", image];
                        } else if ([[t tagName] isEqualToString:@"div"]) {
                            name = [t text];
                            [log appendFormat:@"%@;", name];
                        }
                    }
                    
                    if ([image length] > 0) {
                        image = [image stringByReplacingOccurrencesOfString:@"&w=150" withString:@""];
                    }
                    if ([name length] > 0) {
                        name = [name stringByAppendingString:@".jpg"];
                    }
                    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
                    if (img) {
                        NSData *raw           = UIImageJPEGRepresentation(img, 1.0);
                        NSString *doc         = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                        NSString *docFilePath = [doc stringByAppendingPathComponent:name];
                        [raw writeToFile:docFilePath atomically:YES];
                    }
                    
                    NSData  *sdata     = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://aihuishou.com%@", href]]];
                    TFHpple *sdoc      = [[TFHpple alloc] initWithHTMLData:sdata];
                    NSArray *selements = [sdoc searchWithXPathQuery:@"//div[@id='ahs_property_body']/div/dl/dd"];
                    
                    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[selements count]];
                    for (int j = 0; j < [selements count]; j++) {
                        TFHppleElement *s    = [selements objectAtIndex:j];
                        NSArray *pelements   = [s searchWithXPathQuery:@"//ul/li"];
                        NSMutableArray *rows = [NSMutableArray arrayWithCapacity:[pelements count]];
                        for (int k = 0; k < [pelements count]; k++) {
                            TFHppleElement *p    = [pelements objectAtIndex:k];
                            NSString *_selected_ = [p objectForKey:@"data-id"];
                            NSString *_default_  = [p objectForKey:@"data-default"];
                            if (_default_) {
                                [rows addObject:@[_selected_, _default_]];
                            } else {
                                [rows addObject:_selected_];
                            }
                        }
                        [sections addObject:rows];
                    }
                    
                    int loop = 1;
                    NSMutableArray  *loopArray = [NSMutableArray new];
                    NSMutableString *_default_ = [NSMutableString new];
                    for (int a = 0; a < [sections count]; a++) {
                        NSArray *rows = sections[a];
                        if ([[rows firstObject] isKindOfClass:[NSString class]]) {
                            NSMutableArray *cloopArray = [NSMutableArray new];;
                            for (int b = 0; b < [rows count]; b++) {
                                NSString *row = rows[b];
                                if (a == 0) {
                                    NSMutableArray *subArray = [NSMutableArray new];
                                    [subArray addObject:row];
                                    [loopArray addObject:subArray];
                                } else {
                                    for (NSMutableArray *subArray in loopArray) {
                                        NSMutableArray  *csubArray = [subArray mutableCopy];
                                        [csubArray addObject:row];
                                        [cloopArray addObject:csubArray];
                                    }
                                }
                            }
                            if ([cloopArray count] > 0) {
                                loopArray = cloopArray;
                            }
                            loop *= [rows count];
                        } else {
                            for (int b = 0; b < [rows count]; b++) {
                                if ([rows[b] count] > 1) {
                                    [_default_ appendFormat:@"%@;", rows[b][1]];
                                }
                            }
                        }
                    }
                    
                    NSMutableArray *prices = [NSMutableArray new];
                    for (NSArray *subArray in loopArray) {
                        loop--;
                        NSMutableString *units = [NSMutableString new];
                        for (NSString *unit in subArray) {
                            [units appendFormat:@"%@;", unit];
                        }
                        [units appendString:_default_];
                        [units deleteCharactersInRange:NSMakeRange([units length] - 1, 1)];
                        NSDictionary *parameters = @{@"AuctionProductId": pid,
                                                     @"ProductModelId": @"",
                                                     @"PriceUnits": units,
                                                     @"ValidateCode": @""};
                        NSError *error = nil;
                        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://aihuishou.com/userinquiry/create" parameters:parameters error:&error];
                        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept-Language"];
                        [request setValue:@"zh-cn" forHTTPHeaderField:@"Accept"];
                        [request setValue:href forHTTPHeaderField:@"Referer"];
                        [request setValue:@"http://aihuishou.com" forHTTPHeaderField:@"Origin"];
                        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.16 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.16" forHTTPHeaderField:@"User-Agent"];
                        [request setValue:@"aihuishou.com" forHTTPHeaderField:@"Host"];
                        [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
                        if (!error) {
                            NSHTTPURLResponse *response;
                            NSData *price = [NSURLConnection sendSynchronousRequest:request
                                                                  returningResponse:&response
                                                                              error:&error];
                            if (!error) {
                                TFHpple *priceDoc      = [[TFHpple alloc] initWithHTMLData:price];
                                NSArray *priceElements = [priceDoc searchWithXPathQuery:@"//ul[@id='quoter_list']/li/div/span"];
                                for (int m = 0; m < [priceElements count]; m++) {
                                    TFHppleElement *price = [priceElements objectAtIndex:m];
                                    if (![prices containsObject:[price text]]) {
                                        [prices addObject:[price text]];
                                    }
                                }
                            }
                        }
                    }
                    for (NSString *price in prices) {
                        [log appendFormat:@"%@;", price];
                    }
                    [log deleteCharactersInRange:NSMakeRange([log length] - 1, 1)];
                    [log appendString:@"\n"];
                }
            }
            NSLog(@"%@\n\n\n", log);
            log = [NSMutableString new];
        }
    }
}
