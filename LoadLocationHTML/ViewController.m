//
//  ViewController.m
//  LoadLocationHTML
//
//  Created by 宇玄丶 on 2017/4/21.
//  Copyright © 2017年 北京116科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController () <UIWebViewDelegate>
@property(nonatomic,strong)JSContext *jsContext;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,copy)NSString *htmlStr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.webView];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    
    // 这么写是因为前端给的样式，需要我们上传的是JSON格式
    NSMutableDictionary *newsDic = [@{
         @"content": @"<p>&nbsp;&nbsp;&nbsp;&nbsp;为了扎实开展精准扶贫工作，进一步核实贫困户相关信息，准确制定帮扶措施，4月18日，县扶贫办等工作人员在蔬菜村委会工作人员的陪同下开展了对贫困户的走访工作，共走访调研了本村2户贫困户和1户已脱贫户。<br> &nbsp;&nbsp;&nbsp;&nbsp;根据县扶贫办统一安排，县、镇扶贫办工作人员共走访核实两名贫困户以及一名已脱贫户，在走访活动中，每到一户都和他们面对面亲切交谈，深入了解贫困户生产生活状况、收入来源、人口状况、致贫原因、如何帮扶等相关问题，并对照调查问卷作了详细记录。针对贫困户的需求和愿望，与其共同探讨脱贫致富的办法，制定帮扶措施。<br> &nbsp;&nbsp;&nbsp;&nbsp;此次走访，让贫困户明白了精准扶贫的政策要求，逐户摸清了贫困原因，根据其实际情况制定帮扶措施，以点带面，使扶贫工作落实到户到人，实现全村全部脱贫的最终目标。让每户群众都树立了脱贫致富的信心，制定了有针对性、可操作性的帮扶对策，确保“精准扶贫”工作有条不紊地进行。（吴昊）<br> &nbsp;</p>",
         @"news_id": @45,
         @"news_source": @"大东北农委",
         @"news_type": @1,
         @"status": @1,
         @"title": @"农业部副部长宇玄丶一行调研东北农业面源污染综合防治示范区",
         @"title_image": @"http://www.ahny.gov.cn/upload/20170407/170407_1021814.jpg"
    } mutableCopy];
    NSString *jsonStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:newsDic options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    // 转JSON的过程中，会遇到字符转义方面的问题，很恶心。多亏了看到这篇文章，才得以解决问题
    // http://blog.csdn.net/robotech_er/article/details/40260377
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br>"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
    NSString *textJS = [NSString stringWithFormat:@"vm._getContent('%@')",jsonStr];
    [self.jsContext evaluateScript:textJS];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}



- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.delegate = (id)self;
        _webView.scalesPageToFit = NO;
        _webView.opaque = NO;
    }
    return _webView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
