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
                        
                        // Ratio
                        NSArray *selements = [sdoc searchWithXPathQuery:@"//dl[@name='dlchoses']/dd/input"];
                        if ([selements count] > 0) {
                            for (int i = 0; i < [selements count]; i++) {
                                TFHppleElement *e = [selements objectAtIndex:i];
                                NSString *ratio = [e attributes][@"ratio"];
                                [log appendString:[NSString stringWithFormat:@"%@;", ratio]];
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
