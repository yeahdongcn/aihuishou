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

BOOL contains(NSArray *array, NSString *key) {
    for (NSMutableDictionary *dict in array) {
        if ([[dict.allKeys firstObject] isEqualToString:key]) {
            return YES;
        }
    }
    return NO;
}

NSMutableDictionary *dd(NSArray *array, NSString *key) {
    for (NSMutableDictionary *dict in array) {
        if ([[dict.allKeys firstObject] isEqualToString:key]) {
            return dict;
        }
    }
    return nil;
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSLog(@"\n\n\n");
        
        NSMutableString *log = [NSMutableString new];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        
        NSArray *brands = @[@"134", @"112", @"114", @"108", @"15", @"124", @"126", @"118", @"128", @"22", @"109", @"110", @"111", @"113", @"120", @"123", @"125", @"127", @"791"];
        for (int brand = 0; brand < [brands count]; brand++) {
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
                        
                        NSArray *selements = [sdoc searchWithXPathQuery:@"//div[@id='right_main']/form/dl"];
                        if ([selements count] > 0) {
                            for (int i = 0; i < [selements count]; i++) {
                                TFHppleElement *ee = [selements objectAtIndex:i];
                                NSString *key = nil;
                                NSMutableArray *array = nil;
                                NSMutableDictionary *sdict = nil;
                                for (TFHppleElement *eee in ee.children) {
                                    if ([eee.tagName isEqualToString:@"dt"]) {
                                        key = [[[eee text] componentsSeparatedByString:@"."] lastObject];
                                        array = dict[key];
                                    } else if ([eee.tagName isEqualToString:@"dd"] && [[eee attributes][@"class"]length] == 0) {
                                        if (!array) {
                                            array = [NSMutableArray new];
                                        }
                                        
                                        NSString *ratio = [(TFHppleElement *)[[eee children] firstObject] attributes][@"ratio"];
                                        if (ratio == nil) {
                                            ratio = @"0";
                                        }
                                        if ([ratio length] == 0) {
                                            ratio = @"0";
                                        }
                                        if (!contains(array, [eee text])) {
                                            NSMutableArray *a = [@[ratio] mutableCopy];
                                            sdict = [@{[eee text]: a} mutableCopy];
                                            [array addObject:sdict];
                                        } else {
                                            sdict = dd(array, [eee text]);
                                            if (![sdict[[eee text]] containsObject:ratio]) {
                                                [sdict[[eee text]] addObject:ratio];
                                            }
                                        }
                                    }
                                }
                                dict[key] = array;
                            }
                        }
                        
                        // Sid
                        NSString *goodsid = [[[href lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"goods_" withString:@""];
                        NSLog(@"%@", goodsid);
                        [log appendString:[NSString stringWithFormat:@"%@;", goodsid]];
                        
                        // Name
                        selements = [sdoc searchWithXPathQuery:@"//div[@id='pname']/dl/dd"];
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
                                NSLog(@"%@", dict[@"sz_productprice"]);
                                NSLog(@"%@", dict[@"h_productprice"]);
                                
                                [log appendString:[NSString stringWithFormat:@"%@;", dict[@"productprice"]]];
                                [log appendString:[NSString stringWithFormat:@"%@;", dict[@"sz_productprice"]]];
                                [log appendString:[NSString stringWithFormat:@"%@;", dict[@"h_productprice"]]];
                            }
                        }
                        
                        // Ratio
                        selements = [sdoc searchWithXPathQuery:@"//dl[@name='dlchoses']/dd/input"];
                        if ([selements count] > 0) {
                            for (int i = 0; i < [selements count]; i++) {
                                TFHppleElement *e = [selements objectAtIndex:i];
                                NSString *ratio = [e attributes][@"ratio"];
                                [log appendString:[NSString stringWithFormat:@"%@;", ratio]];
                            }
                        }
                        
                        [log appendString:@"\n"];
                        
                        // Image
                        selements = [sdoc searchWithXPathQuery:@"//div[@id='goods_left']/dl/dd/img"];
                        if ([selements count] > 0) {
                            TFHppleElement *e = [selements firstObject];
                            NSString *image = [e attributes][@"src"];
                            image = [NSString stringWithFormat:@"%@%@", @"http://www.lehuiso.com", [image stringByReplacingOccurrencesOfString:@".." withString:@""]];
                            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
                            if (img) {
                                NSData *raw           = UIImageJPEGRepresentation(img, 1.0);
                                NSString *doc         = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                                NSString *docFilePath = [doc stringByAppendingPathComponent:goodsid];
                                docFilePath = [docFilePath stringByAppendingString:@".jpg"];
                                [raw writeToFile:docFilePath atomically:YES];
                            }
                        }
                    }
                }
            }
        }
        
        NSLog(@"\n\n\n");
    }
}
