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
        for (int cid = 1; cid < 2; cid++) {
            for (int i = 1; i < 90; i++) {
                NSData  *data     = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://aihuishou.com/product/search?cid=%d&bid=0&keyword=&pageIndex=%d", cid, i]]];
                
                TFHpple *doc      = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *elements = [doc searchWithXPathQuery:@"//ul[@class='products']/li/a"];
                for (int j = 0; j < [elements count]; j++) {
                    TFHppleElement *e = [elements objectAtIndex:j];
                    NSString *href    = [e objectForKey:@"href"];
                    NSString *base64name = @"";
                    for (TFHppleElement *t in e.children) {
                        if ([[t tagName] isEqualToString:@"div"]) {
                            base64name = [[t text] base64EncodedString];
                        }
                    }
                    
                    base64name = [base64name stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    base64name = [base64name stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    [log appendFormat:@"%@;", base64name];
                    
                    // Get possible configurations
                    NSData  *sdata     = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://aihuishou.com%@", href]]];
                    TFHpple *sdoc      = [[TFHpple alloc] initWithHTMLData:sdata];
                    NSArray *selements = [sdoc searchWithXPathQuery:@"//div[@class='right']/ul/li/div"];
                    for (int k = 0; k < [selements count]; k++) {
                        TFHppleElement *e = [selements objectAtIndex:k];
                        if (k == 0) {
                            [log appendFormat:@"%d;", 100000 - [[e text] intValue]];
                        } else {
                            [log appendFormat:@"%@;", [e text]];
                        }
                        
                    }
                    [log appendString:@"\n"];
                }
            }
        }
    }
}
