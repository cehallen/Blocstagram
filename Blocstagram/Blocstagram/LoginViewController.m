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
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
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
 (AS.33) ADD BACK BUTTON IN WEBVIEW
 - http://stackoverflow.com/questions/1662565/uiwebview-finished-loading-event
 - http://stackoverflow.com/questions/6991623/how-to-convert-navigationcontrollers-back-button-into-browsers-back-button-in
 - check if self.webView 'canGoBack' and then if it can set the button with the 'goBack' ability on click.  see bloc browser for examples
 */
- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self updateBackButton];
}

- (void) updateBackButton {
    if ([self.webView canGoBack]) {
        if (!self.navigationItem.leftBarButtonItem) {
            [self.navigationItem setHidesBackButton:YES]; // this is the default back button you are hiding.  what default back button?  anyway.. do it
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backWasClicked:)];
            [self.navigationItem setLeftBarButtonItem:backButton];
        }
    } else {
        [self.navigationItem setLeftBarButtonItem:nil]; 
        [self.navigationItem setHidesBackButton:NO];
    }
}

- (void) backWasClicked:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
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

//- (void) viewWillAppear:(BOOL)animated {
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = backButton;
//}



//- (void) back {
//    [self.navigationController popViewControllerAnimated:YES];
//}

@end
