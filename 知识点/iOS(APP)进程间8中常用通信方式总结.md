> iOS系统是相对封闭的系统，App各自在各自的沙盒（sandbox）中运行，每个App都只能读取iPhone上iOS系统为该应用程序程序创建的文件夹AppData下的内容，不能随意跨越自己的沙盒去访问别的App沙盒中的内容。

## 1、 URL Scheme

这个是iOS app通信最常用到的通信方式，App1通过openURL的方法跳转到App2，并且在URL中带上想要的参数，有点类似http的get请求那样进行参数传递。这种方式是使用最多的最常见的，使用方法也很简单只需要源App1在info.plist中配置LSApplicationQueriesSchemes，指定目标App2的scheme；然后在目标App2的info.plist中配置好URL types，表示该app接受何种URL scheme的唤起。

![这里写图片描述](https://img-blog.csdn.net/20171225122803385?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

**典型的使用场景就是各开放平台SDK的分享功能**，如分享到微信朋友圈微博等，或者是支付场景。比如从滴滴打车结束行程跳转到微信进行支付。

![这里写图片描述](https://img-blog.csdn.net/20171225122846671?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 2、 Keychain

iOS系统的Keychain是一个安全的存储容器，它本质上就是一个sqllite数据库，它的位置存储在/private/var/Keychains/keychain-2.db，不过它所保存的所有数据都是经过加密的，可以用来为不同的app保存敏感信息，比如用户名，密码等。iOS系统自己也用keychain来保存VPN凭证和Wi-Fi密码。它是独立于每个App的沙盒之外的，所以即使App被删除之后，Keychain里面的信息依然存在。

基于安全和独立于app沙盒的两个特性，Keychain主要用于给app保存登录和身份凭证等敏感信息，这样只要用户登录过，即使用户删除了app重新安装也不需要重新登录。

那Keychain用于App间通信的一个**典型场景也和app的登录相关，就是统一账户登录平台**。使用同一个账号平台的多个app，只要其中一个app用户进行了登录，其他app就可以实现自动登录不需要用户多次输入账号和密码。一般开放平台都会提供登录SDK，在这个SDK内部就可以把登录相关的信息都写到keychain中，这样如果多个app都集成了这个SDK，那么就可以实现统一账户登录了。

Keychain的使用比较简单，使用iOS系统提供的类KeychainItemWrapper，并通过keychain access groups就可以在应用之间共享keychain中的数据的数据了。

![这里写图片描述](https://img-blog.csdn.net/20171225123055422?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 3、 UIPasteboard 剪切板

顾名思义， UIPasteboard是剪切板功能，因为iOS的原生控件UITextView，UITextField 、UIWebView，我们在使用时如果长按，就会出现复制、剪切、选中、全选、粘贴等功能，这个就是利用了系统剪切板功能来实现的。而每一个App都可以去访问系统剪切板，所以就能够通过系统剪贴板进行App间的数据传输了。
UIPasteboard的使用很简单，

![这里写图片描述](https://img-blog.csdn.net/20171225123152927?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

UIPasteboard典型的使用场景就是淘宝跟微信/QQ的链接分享。由于腾讯和阿里的公司战略，腾讯在微信和qq中都屏蔽了淘宝的链接。那如果淘宝用户想通过QQ或者微信跟好友分享某个淘宝商品，怎么办呢？ 阿里的工程师就巧妙的利用剪贴板实现了这个功能。首先淘宝app中将链接自定义成淘口令，引导用户进行复制，并去QQ好友对话中粘贴。然后QQ好友收到消息后再打开自己的淘宝app，淘宝app每次从后台切到前台时，就会检查系统剪切板中是否有淘口令，如果有淘口令就进行解析并跳转到对于的商品页面。

先复制淘口令到剪切板，

![这里写图片描述](https://img-blog.csdn.net/20171225123220411?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

把剪切板中的内容粘贴到微信发给微信好友，

![这里写图片描述](https://img-blog.csdn.net/20171225123248559?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

微信好友把淘口令复制到淘宝中，就可以打开好友分享的淘宝链接了。

![这里写图片描述](https://img-blog.csdn.net/20171225123315985?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 4、 UIDocumentInteractionController

UIDocumentInteractionController主要是用来实现同设备上app之间的共享文档，以及文档预览、打印、发邮件和复制等功能。它的使用非常简单.

首先通过调用它唯一的类方法 interactionControllerWithURL:，并传入一个URL(NSURL)，为你想要共享的文件来初始化一个实例对象。然后UIDocumentInteractionControllerDelegate，然后显示菜单和预览窗口。

![这里写图片描述](https://img-blog.csdn.net/20171225123423205?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

效果如下，

![这里写图片描述](https://img-blog.csdn.net/20171225123458566?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 5、 local socket

这种方式不太常见，也是很容易被iOS开发者所忽略但是特别实用的一种方法。它的原理很简单，一个App1在本地的端口port1234进行TCP的bind和listen，另外一个App2在同一个端口port1234发起TCP的connect连接，这样就可以建立正常的TCP连接，进行TCP通信了，那么就想传什么数据就可以传什么数据了。

这种方式最大的特点就是灵活，只要连接保持着，随时都可以传任何相传的数据，而且带宽足够大。它的缺点就是因为iOS系统在任意时刻只有一个app在前台运行，那么就要通信的另外一方具备在后台运行的权限，像导航或者音乐类app。

它是常用使用场景就是某个App1具有特殊的能力，比如能够跟硬件进行通信，在硬件上处理相关数据。而App2则没有这个能力，但是它能给App1提供相关的数据，这样APP2跟App1建立本地socket连接，传输数据到App1，然后App1在把数据传给硬件进行处理。

![这里写图片描述](https://img-blog.csdn.net/20171225123553001?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 6、 AirDrop

通过AirDrop实现不同设备的App之间文档和数据的分享；

## 7、 UIActivityViewController

iOS SDK中封装好的类在App之间发送数据、分享数据和操作数据；

![这里写图片描述](https://img-blog.csdn.net/20171225124028961?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](https://img-blog.csdn.net/20171225123930299?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](https://img-blog.csdn.net/20171225124213106?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 8、 App Groups

App Group用于同一个开发团队开发的App之间，包括App和Extension之间共享同一份读写空间，进行数据共享。同一个团队开发的多个应用之间如果能直接数据共享，大大提高用户体验。

![这里写图片描述](https://img-blog.csdn.net/20171226172034918?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](https://img-blog.csdn.net/20171226172252819?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQva3VhbmdkYWNhaWt1YW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)