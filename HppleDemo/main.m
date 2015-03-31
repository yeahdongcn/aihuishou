//
//  main.m
//  HppleDemo
//
//  Created by Vytautas Galaunia on 11/25/14.
//
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"\n\n\n");
        NSMutableString *log = [NSMutableString new];
        for (int cid = 1; cid < 100; cid++) {
            for (int i = 1; i < 100; i++) {
                NSData  * data      = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://aihuishou.com/product/search?cid=%d&bid=0&keyword=&pageIndex=%d", cid, i]]];
                
                TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
                NSArray * elements  = [doc searchWithXPathQuery:@"//ul[@class='products']/li/a"];
                for (int j = 0; j < [elements count]; j++) {
                    TFHppleElement * e = [elements objectAtIndex:j];
                    for (TFHppleElement * t in e.children) {
                        if ([[t tagName] isEqualToString:@"img"]) {
                            [log appendFormat:@"%@;", [t objectForKey:@"src"]];
                        } else if ([[t tagName] isEqualToString:@"div"]) {
                            [log appendFormat:@"%@\n", [t text]];
                        }
                    }
                }
            }
            NSLog(@"%@\n\n\n", log);
            log = [NSMutableString new];
        }
    }
}
