# LoadLocationHTML
iOS-利用UIWebView获取的HTML加载本地样式

随着各种各样的需求涌出，混合式开发越来越被使用，所以原生与H5的交互也使用的越来越频繁。
现在有这样的一个需求，分享出来与大家共勉。

新闻详情页面使用的是WebView，数据都是从各个网站爬下来的，所以导致各种样式，用户使用起来非常不爽，所以，前端就写了 一个本地的样式，我们利用webView，根据网络获取的这个html，加载本地的这个统一的样式。

index.html这个是前端写好的样式。

![index.html](http://upload-images.jianshu.io/upload_images/5684426-89e58abcf952ae59.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

html里面的script：
![html里面的script](http://upload-images.jianshu.io/upload_images/5684426-885333b032e16966.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如图所示：截图中明确的给出了JSON样式，以及我们需要调用的JS方法。
接下来看下代码如何实现：
- 首先我们需要加载这个本地的html
```
NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
[self.webView loadRequest:request];
```
- pragma mark - UIWebViewDelegate

```
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    
    // 这么写是因为前端给的样式，需要我们上传的是JSON格式(在上文中html里面的截图已经说到)
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
// vm._getContent:拿到JS方法，上传jsonStr
    NSString *textJS = [NSString stringWithFormat:@"vm._getContent('%@')",jsonStr];
    [self.jsContext evaluateScript:textJS];
}
```
好了，大功告成！
效果如下：

![加载本地的样式](http://upload-images.jianshu.io/upload_images/5684426-85569e778d14bf0e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果有写的不好的地方，欢迎各种大神提出指正。喜欢的小伙伴记得给个Star啊^_^
代码：

