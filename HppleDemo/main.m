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
#import "Base64.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSLog(@"\n\n\n");
        
        NSMutableString *log = [NSMutableString new];
        
        NSArray *brands = @[@"134", @"112", @"114", @"108", @"15", @"124", @"126", @"118", @"128", @"22", @"109", @"110", @"111", @"113", @"120", @"123", @"125", @"127", @"791"];
        for (int brand = 1; brand < [brands count]; brand++) {
            for (int page = 1; page < 50; page++) {
                NSData  *data     = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lehuiso.com/products/products_%@_%d.html", brands[brand], page]]];
                
                TFHpple *doc      = [[TFHpple alloc] initWithHTMLData:data];
                
                NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='product']/dl/dt/a"];
                if ([elements count] > 0) {
                    for (int i = 0; i < [elements count]; i++) {
                        TFHppleElement *e = [elements objectAtIndex:i];
                        NSString *href    = [e objectForKey:@"href"];
                        href = [NSString stringWithFormat:@"%@%@", @"http://www.lehuiso.com", [href stringByReplacingOccurrencesOfString:@".." withString:@""]];
                        NSData  *sdata     = [NSData dataWithContentsOfURL:[NSURL URLWithString:href]];
                        TFHpple *sdoc      = [[TFHpple alloc] initWithHTMLData:sdata];
                        
                        // Sid
                        NSString *goodsid = [[[href lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"goods_" withString:@""];
                        NSLog(@"%@", goodsid);
                        [log appendString:[NSString stringWithFormat:@"%@;", goodsid]];
                        
                        // Name
                        NSArray *selements = [sdoc searchWithXPathQuery:@"//div[@id='pname']/dl/dd"];
                        e = [selements firstObject];
                        NSString *name = [[e text] stringByReplacingOccurrencesOfString:@"产品型号：" withString:@""];
                        NSLog(@"%@", name);
                        [log appendString:[NSString stringWithFormat:@"%@;", name]];
                        
                        // Request prcie
                        NSDictionary *parameters = @{@"goodsid": goodsid};
                        NSError *error = nil;
                        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://www.lehuiso.com/ajax/select_price.php" parameters:parameters error:&error];
                        [request setValue:href forHTTPHeaderField:@"Referer"];
                        if (!error) {
                            NSHTTPURLResponse *response;
                            NSData *json = [NSURLConnection sendSynchronousRequest:request
                                                                  returningResponse:&response
                                                                              error:&error];
                            if (!error) {
                                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json
                                                                                     options:NSJSONReadingAllowFragments
                                                                                       error:nil];
                                NSLog(@"%@", dict[@"productprice"]);
                                NSLog(@"sz %@", dict[@"sz_productprice"]);
                                NSLog(@"h %@", dict[@"h_productprice"]);
                                
                                [log appendString:[NSString stringWithFormat:@"%@;", dict[@"productprice"]]];
                                [log appendString:[NSString stringWithFormat:@"sz %@;", dict[@"sz_productprice"]]];
                                [log appendString:[NSString stringWithFormat:@"h %@;", dict[@"h_productprice"]]];
                            }
                        }
                        [log appendString:@"\n"];
                    }
                }
            }
        }
        
        NSLog(@"\n\n\n");
    }
}
