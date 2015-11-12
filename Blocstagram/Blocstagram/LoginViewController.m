//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Christopher Allen on 9/29/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

- (NSString *)redirectURI {
    return @"http://www.bloc.io";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.title = NSLocalizedString(@"Login", @"Login");
    
//    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    // still not 'liking' properly.
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void) dealloc {
    [self clearInstagramCookies];
    
    self.webView.delegate = nil;
}

/**
 Clears Instagram cookies. This prevents caching the credentials in the cookie jar.
 */
- (void) clearInstagramCookies {
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        
        // notes: confusing.. what happens is instagram gives you an access token and then redirects you to a certain url.  we don't actually want to go there so we return NO.  if you do get that redirect though, it means you got an access token for the insta user you logged in for appended to the redirect URL..  so we grab that, and send access token to notification center to trigger loading of ImagesTableViewController.  here the notification is POSTED.  in other places (appDelegate) there is an observer for this notification set up, which runs a block of code whenever that notification is fired (from here).  it loads the ImagesTableVC, as I said before.
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        
        return NO;
    }
    
    return YES;
}

- (void) viewWillLayoutSubviews {
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
