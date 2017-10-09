//
//  ZJWebVC.m
//  T
//
//  Created by Jion on 16/5/31.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "ZJWebVC.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ZJWebVC ()<UIWebViewDelegate>
{
    NSString *urlStr;
}

@end

@implementation ZJWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    urlStr = @"http://m.sfbest.com/special/2-5971-2-52-500.html";//@"http://img01.bqstatic.com/upload/activity/activity_v4_20624_1452392276_top.jpg@90Q";//
    urlStr = @"www.youjuke.com";//@"http://m.youjuke.com/onsale/index";
    
   __block UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    //加载方式1
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    //加载方式2
    NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@",html);
//    1.html定义内容，url定义布局
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:urlStr]];
    //2.只有内容没有布局
//    [webView loadHTMLString:html baseURL:nil];
    
    //加载方式3
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    NSURLSessionDataTask *sessionTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        NSLog(@"data = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        
//        [webView loadData:data MIMEType:response.MIMEType textEncodingName:@"UTF8" baseURL:response.URL];
//    }];
//    [sessionTask resume];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString * requestStr =[request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *body  =[[ NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSLog(@"HTTPMethod==%@\n HTTPBody = %@ \n  path = %@ \n urlstr = %@",request.HTTPMethod,body,request.URL.path,requestStr);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
   JSContext *jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
//    jsContext[@"activityList"] = ^(NSDictionary *param) {
//        NSLog(@"%@", param);
//    };
    
   /*
    //1.获取当前页面的url,需要等UIWebView中的页面加载完成之后去调用
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    //2、获取页面title：
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //3、修改界面元素的值。
    NSString *js_result = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('q')[0].value='iOS';"];
    //4、表单提交：
    NSString *js_result2 = [webView stringByEvaluatingJavaScriptFromString:@"document.forms[0].submit(); "];
    //5、插入js代码
    //6、直接调用JS函数
   */
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
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
