#import "BasecampAccount.h"

@interface NSObject (Data)
- (NSData *)data;
@end

@implementation BasecampAccount

- (void)dealloc {
    [super dealloc];
}

- (void)validateWithPassword:(NSString *)password {
  
    NSString *URL = [NSString stringWithFormat:@"https://%@.basecamphq.com/me.xml", domain];
    
    self.request = [SMWebRequest requestWithURLRequest:[NSURLRequest requestWithURLString:URL username:username password:password] delegate:nil context:NULL];
    [request addTarget:self action:@selector(meRequestComplete:) forRequestEvents:SMWebRequestEventComplete];
    [request addTarget:self action:@selector(meRequestError:) forRequestEvents:SMWebRequestEventError];
    [request start];
}

- (void)meRequestComplete:(NSData *)data {
    SMXMLDocument *document = [SMXMLDocument documentWithData:data error:NULL];
    NSString *token = [document.root valueWithPath:@"token"];
    
    NSString *mainFeedString = [NSString stringWithFormat:@"https://%@:%@@%@.basecamphq.com/feed/recent_items_rss", token, token, domain];
    Feed *mainFeed = [Feed feedWithURLString:mainFeedString];
    
    self.feeds = [NSArray arrayWithObject:mainFeed];
    
    [self.delegate accountValidationDidComplete:self];
}

- (void)meRequestError:(NSError *)error {
    NSLog(@"Error! %@", [SMXMLDocument documentWithData:request.data error:NULL]);
    [self.delegate account:self validationDidFailWithMessage:@"Could not log in to the given Basecamp account. Please check your domain, username, and password." field:0];
}

@end