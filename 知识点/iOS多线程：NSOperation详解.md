# iOS多线程：NSOperation详解

> 多线程开发是日常开发任务中不可缺少的一部分，在iOS开发中常用到的多线程开发技术有`GCD、NSOperation、NSThread`，本文主要讲解多线系列文章中关于`NSOperation`的相关知识和使用详解。

# 1、NSOperation简介

`NSOperation`是苹果公司提供的一套完整的多线程解决方案，实际上它是基于`GCD`更高一层的封装，完全面向对象。相对于GCD而言使用更加的简单、代码更具可读性。包括网络请求、图片压缩在内的诸多多线程任务案例都很好的使用了NSOperation。当然NSOperation还需要`NSOperationQueue`这一重要角色配合使用。

> 1. 支持在操作对象之间依赖关系，方便控制执行顺序。
> 2. 支持可选的完成块，它在操作的主要任务完成后执行。
> 3. 支持使用KVO通知监视操作执行状态的变化。
> 4. 支持设定操作的优先级，从而影响它们的相对执行顺序。
> 5. 支持取消操作，允许您在操作执行时暂停操作。

# 2、NSOperation任务和队列

## 2.1、NSOperation任务

和GCD一样NSOperation同样有任务的概念。所谓任务就是在线程中执行的那段代码，在GCD中是放在block执行的，而在NSOperation中是在其子类 `NSInvocationOperation`、`NSBlockOperation`、`自定义子类`中执行的。和GCD不同的是NSOperation需要NSOperationQueue的配合来实现多线程，NSOperation 单独使用时是同步执行操作，配合 NSOperationQueue 才能实现异步执行。

## 2.2、NSOperation队列

NSOperation中的队列是用`NSOperationQueue`表示的，用过来存放任务的队列。

- 不同于GCD中队列先进先出的原则，对于添加到NSOperationQueue队列中的任务，首先根据任务之间的依赖关系决定任务的就绪状态，然后进入就绪状态的任务由任务之间的相对优先级决定开始执行顺序。
- 同时NSOperationQueue提供设置最大并发任务数的途径。
- NSOperationQueue还提供了两种不同类型的队列：主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行。

# 3、NSOperation的基本使用

NSOperation是一个抽象类，为了做任何有用的工作，它必须被子类化。尽管这个类是抽象的，但它给了它的子类一个十分有用而且线程安全的方式来建立状态、优先级、依赖性和取消等的模型。NSOperation提供了三种方式来创建任务。 **1、使用子类 NSInvocationOperation； 2、使用子类 NSBlockOperation； 3、自定义继承自 NSOperation 的子类，通过实现内部相应的方法来封装操作。**

下面我们先来看下NSOperation上面三种不同方式的单独使用情况。

## 3.1、NSInvocationOperation

**`NSInvocationOperation`类是NSOperation的一个具体子类**，当运行时，它调用指定对象上指定的方法。使用此类可避免为应用程序中的每个任务定义大量自定义操作对象。

```objc
-(void)invocationOperation{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation) object:nil];
    [operation start];
}

-(void)operation{
    for (int i = 0; i < 5; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%d--%@",i,[NSThread currentThread]);
    }
}
```

> 打印结果：
> 2020-03-19 17:09:46.189458+0800 ThreadDemo[44995:12677738] 0--<NSThread: 0x600000ba9e40>{number = 1, name = main}
> 2020-03-19 17:09:48.190629+0800 ThreadDemo[44995:12677738] 1--<NSThread: 0x600000ba9e40>{number = 1, name = main}
> 2020-03-19 17:09:50.191219+0800 ThreadDemo[44995:12677738] 2--<NSThread: 0x600000ba9e40>{number = 1, name = main}
> 2020-03-19 17:09:52.192556+0800 ThreadDemo[44995:12677738] 3--<NSThread: 0x600000ba9e40>{number = 1, name = main}
> 2020-03-19 17:09:54.193900+0800 ThreadDemo[44995:12677738] 4--<NSThread: 0x600000ba9e40>{number = 1, name = main}

正如上面代码运行的结果显示，NSInvocationOperation单独使用时，并没有开启新的线程，任务都是在当前线程中执行的。

## 3.2、NSBlockOperation

**`NSBlockOperation`类是NSOperation的一个具体子类，它充当一个或多个块对象的包装**。该类为已经使用操作队列且不希望创建分派队列的应用程序提供了面向对象的包装器。您还可以使用块操作来利用操作依赖、KVO通知和其他可能与调度队列不可用的特性。

```objective-c
-(void)blockOperationDemo{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%d--%@",i,[NSThread currentThread]);
        }
    }];
    [operation start];
}
```

> 打印结果：
> 2020-03-19 17:19:38.673513+0800 ThreadDemo[45160:12689966] 0--<NSThread: 0x600001081100>{number = 1, name = main}
> 2020-03-19 17:19:40.675074+0800 ThreadDemo[45160:12689966] 1--<NSThread: 0x600001081100>{number = 1, name = main}
> 2020-03-19 17:19:42.676649+0800 ThreadDemo[45160:12689966] 2--<NSThread: 0x600001081100>{number = 1, name = main}
> 2020-03-19 17:19:44.677073+0800 ThreadDemo[45160:12689966] 3--<NSThread: 0x600001081100>{number = 1, name = main}
> 2020-03-19 17:19:46.677379+0800 ThreadDemo[45160:12689966] 4--<NSThread: 0x600001081100>{number = 1, name = main}

如上面代码运行结果所示，NSBlockOperation单独使用时，并未开启新的线程，任务的执行都是在当前线程中执行的。

在NSBlockOperation类中还提供一个`addExecutionBlock`方法，这个方法可以添加一个代码执行块，当需要执行NSBlockOperation对象时，该对象将其所有块提交给默认优先级的并发调度队列。然后对象等待，直到所有的块完成执行。当最后一个块完成执行时，操作对象将自己标记为已完成。因此，我们可以使用块操作来跟踪一组执行的块，这与使用线程连接来合并来自多个线程的结果非常相似。不同之处在于，由于块操作本身在单独的线程上运行，所以应用程序的其他线程可以在等待块操作完成的同时继续工作。需要说明的一点是，如果添加的任务较多的话，这些操作（包括 blockOperationWithBlock 中的操作）可能在不同的线程中并发执行，这是由系统决定的。

```objective-c
- (void)blockOperationDemo {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockOperation--%@", [NSThread currentThread]);
        }
    }];
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"executionBlock1--%@", [NSThread currentThread]);
        }
    }];
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"executionBlock2--%@", [NSThread currentThread]);
        }
    }];
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"executionBlock3--%@", [NSThread currentThread]);
        }
    }];
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"executionBlock4--%@", [NSThread currentThread]);
        }
    }];
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"executionBlock5--%@", [NSThread currentThread]);
        }
    }];
    [operation start];
}
```

> 打印结果：
> 2020-03-19 17:40:08.102543+0800 ThreadDemo[45536:12708941] executionBlock4--<NSThread: 0x600002a1ab00>{number = 1, name = main}
> 2020-03-19 17:40:08.102555+0800 ThreadDemo[45536:12709185] executionBlock2--<NSThread: 0x600002a57b80>{number = 8, name = (null)}
> 2020-03-19 17:40:08.102555+0800 ThreadDemo[45536:12709191] executionBlock5--<NSThread: 0x600002ab8980>{number = 9, name = (null)}
> 2020-03-19 17:40:08.102566+0800 ThreadDemo[45536:12709186] executionBlock3--<NSThread: 0x600002a7d440>{number = 4, name = (null)}
> 2020-03-19 17:40:08.102570+0800 ThreadDemo[45536:12709184] executionBlock1--<NSThread: 0x600002a3aa80>{number = 6, name = (null)}
> 2020-03-19 17:40:08.102576+0800 ThreadDemo[45536:12709187] blockOperation--<NSThread: 0x600002a7d600>{number = 5, name = (null)}
> 2020-03-19 17:40:10.103970+0800 ThreadDemo[45536:12709187] blockOperation--<NSThread: 0x600002a7d600>{number = 5, name = (null)}
> 2020-03-19 17:40:10.103970+0800 ThreadDemo[45536:12708941] executionBlock4--<NSThread: 0x600002a1ab00>{number = 1, name = main}
> 2020-03-19 17:40:10.103970+0800 ThreadDemo[45536:12709185] executionBlock2--<NSThread: 0x600002a57b80>{number = 8, name = (null)}
> 2020-03-19 17:40:10.103980+0800 ThreadDemo[45536:12709191] executionBlock5--<NSThread: 0x600002ab8980>{number = 9, name = (null)}
> 2020-03-19 17:40:10.103971+0800 ThreadDemo[45536:12709186] executionBlock3--<NSThread: 0x600002a7d440>{number = 4, name = (null)}
> 2020-03-19 17:40:10.103973+0800 ThreadDemo[45536:12709184] executionBlock1--<NSThread: 0x600002a3aa80>{number = 6, name = (null)}

正如上面代码运行结果所示，在调用了addExecutionBlock方法添加了组个多的任务后，开启新的线程，任务是并发执行的，blockOperationWithBlock中的任务执行也不是在当前的线程执行的。

## 3.3、自定义 NSOperation 的子类

如果使用子类 `NSInvocationOperation、NSBlockOperation`不能满足日常需求，我们还可以自定义子类。定一个类继承自`NSOperation`，重写它的`main`或者`start`方法便可。

```objc
@interface CustomerOperation : NSOperation

@end

@implementation CustomerOperation
- (void)main{
    if(!self.isCancelled){
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%d--%@",i,[NSThread currentThread]);
        }
    }
}

-(void)customerOperation{
    CustomerOperation *operation = [[CustomerOperation alloc]init];
    [operation start];
}
```

> 打印结果：
> 2020-03-19 20:28:54.473676+0800 ThreadDemo[47267:12811915] 0--<NSThread: 0x600001289040>{number = 1, name = main}
> 2020-03-19 20:28:56.474363+0800 ThreadDemo[47267:12811915] 1--<NSThread: 0x600001289040>{number = 1, name = main}
> 2020-03-19 20:28:58.474708+0800 ThreadDemo[47267:12811915] 2--<NSThread: 0x600001289040>{number = 1, name = main}
> 2020-03-19 20:29:00.476058+0800 ThreadDemo[47267:12811915] 3--<NSThread: 0x600001289040>{number = 1, name = main}

从上面代码运行结果显示可以看出，自定义的Operation并没有开启新的线程，任务的执行是在当前的线程中执行的。

上面讲解了NSOperation单独使用的情况，下面我们来看看NSOperationQueue队列配合NSOperation的使用情况。

## 3.4、添加任务到队列

在上面就已经提及过，NSOperation需要NSOperationQueue来配合使用实现多线程。那么我们就需要将创建好的NSOperation对象加载到NSOperationQueue队列中。 NSOperationQueue提供了主队列和自定义队里两种队列，其中自定义队列中包含了串行和并发两种不同的功能。

- 主队列：通过`[NSOperationQueue mainQueue]`方式获取，凡是添加到主队列中的任务都会放到主线程中执行。
- 自定义队列：通过`[[NSOperationQueue alloc] init]`方式创建一个队列，凡是添加到自定义队列中的任务会自动放到子线程中执行。

### 3.4.1、addOperation

调用`addOperation`方法将创建的operation对象添加到创建好的队列中。

```objective-c
- (void)operationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//    NSOperationQueue *queue = [NSOperationQueue mainQueue];

    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation1--%@", [NSThread currentThread]);
        }
    }];

    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation2--%@", [NSThread currentThread]);
        }
    }];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
}
```

> 打印结果：
> 2020-03-19 21:01:45.868610+0800 ThreadDemo[47889:12843365] operation1--<NSThread: 0x6000012cd900>{number = 3, name = (null)}
> 2020-03-19 21:01:45.868610+0800 ThreadDemo[47889:12843364] operation2--<NSThread: 0x6000012e0640>{number = 6, name = (null)}
> 2020-03-19 21:01:47.872040+0800 ThreadDemo[47889:12843365] operation1--<NSThread: 0x6000012cd900>{number = 3, name = (null)}
> 2020-03-19 21:01:47.872040+0800 ThreadDemo[47889:12843364] operation2--<NSThread: 0x6000012e0640>{number = 6, name = (null)}

从上面代码运行的结果可以看出，开启了新的线程，任务是并发执行的。如果将queue换成是mainQueue，那么任务将会在主线程中同步执行。

### 3.4.2、addOperations

如果任务很多时，一个个添加到队列不免有些麻烦，那么`addOperations`就起作用了。

```objective-c
- (void)operationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//    NSOperationQueue *queue = [NSOperationQueue mainQueue];

    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation1--%@", [NSThread currentThread]);
        }
    }];

    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation2--%@", [NSThread currentThread]);
        }
    }];
    NSArray *operationList = @[operation1,operation2];
    [queue addOperations:operationList waitUntilFinished:NO];
    NSLog(@"end");
}
```

> 打印结果：
> 2020-03-19 21:06:30.381594+0800 ThreadDemo[48047:12849411] end
> 2020-03-19 21:06:32.385653+0800 ThreadDemo[48047:12849496] operation1--<NSThread: 0x600001f4e880>{number = 8, name = (null)}
> 2020-03-19 21:06:32.385651+0800 ThreadDemo[48047:12849498] operation2--<NSThread: 0x600001fac740>{number = 4, name = (null)}
> 2020-03-19 21:06:34.390373+0800 ThreadDemo[48047:12849496] operation1--<NSThread: 0x600001f4e880>{number = 8, name = (null)}
> 2020-03-19 21:06:34.390373+0800 ThreadDemo[48047:12849498] operation2--<NSThread: 0x600001fac740>{number = 4, name = (null)}

从上面代码运行的记过可以看出，开启了新的线程，任务是并发执行的。如果将queue换成是mainQueue，那么任务将会在主线程中同步执行。

> 这里需要说明的一点的是`waitUntilFinished`参数，如果传YES，则表示会等待队列里面的任务执行完成后才会往下执行，也就是会阻塞线程。

### 3.4.3、addOperationWithBlock

NSOperationQueue还提供了一个`addOperationWithBlock`方法可以将operation对象添加到NSOperationQueue中。

```objective-c
-(void)addOperationWithBlock{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//        NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation1--%@", [NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation2--%@", [NSThread currentThread]);
        }
    }];
}
```

> 打印结果:
> 2020-03-19 21:11:54.069593+0800 ThreadDemo[48192:12856146] operation1--<NSThread: 0x600000b0f740>{number = 4, name = (null)}
> 2020-03-19 21:11:54.069593+0800 ThreadDemo[48192:12856148] operation2--<NSThread: 0x600000b324c0>{number = 3, name = (null)}
> 2020-03-19 21:11:56.070432+0800 ThreadDemo[48192:12856148] operation2--<NSThread: 0x600000b324c0>{number = 3, name = (null)}
> 2020-03-19 21:11:56.070430+0800 ThreadDemo[48192:12856146] operation1--<NSThread: 0x600000b0f740>{number = 4, name = (null)}

从上面代码运行的记过可以看出，开启了新的线程，任务是并发执行的。如果将queue换成是mainQueue，那么任务将会在主线程中同步执行。

## 3.5、同步执行&并发执行

在前面的内容已经提及过，NSOperation单独使用时默认是系统同步执行的，如果需要并发执行任务，就需要NSOperationQueue的协同。那么决定是并发执行还是同步执行的关键就在于最大并发任务数`maxConcurrentOperationCount`。

- 默认情况下`maxConcurrentOperationCount`的值是-1，并不做限制，可以并发执行，如上面提到的NSBlockOperation添加多个任务块。
- `maxConcurrentOperationCount`的值为1时，同步执行。
- `maxConcurrentOperationCount`的值大于1时，并发执行。
- `maxConcurrentOperationCount`的值并不是表示并发执行的线程数量，而是在一个队列中能够同时执行的任务的数量。

```objective-c
- (void)maxConcurrentOperationCount {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;//串行队列
//    queue.maxConcurrentOperationCount = 4;//并发队列
    NSLog(@"maxCount=%ld", (long)queue.maxConcurrentOperationCount);
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation1--%@", [NSThread currentThread]);
        }
    }];

    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation2--%@", [NSThread currentThread]);
        }
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"operation3--%@", [NSThread currentThread]);
        }
    }];
    NSArray *operationList = @[operation1, operation2, operation3];
    [queue addOperations:operationList waitUntilFinished:YES];

    NSLog(@"end");
}
```

> 打印结果：
> 2020-03-19 21:35:41.878534+0800 ThreadDemo[48619:12879620] maxCount=1
> 2020-03-19 21:35:43.882396+0800 ThreadDemo[48619:12879824] operation1--<NSThread: 0x600000c7b240>{number = 3, name = (null)}
> 2020-03-19 21:35:45.882889+0800 ThreadDemo[48619:12879824] operation1--<NSThread: 0x600000c7b240>{number = 3, name = (null)}
> 2020-03-19 21:35:47.886984+0800 ThreadDemo[48619:12879824] operation2--<NSThread: 0x600000c7b240>{number = 3, name = (null)}
> 2020-03-19 21:35:49.888093+0800 ThreadDemo[48619:12879824] operation2--<NSThread: 0x600000c7b240>{number = 3, name = (null)}
> 2020-03-19 21:35:51.893354+0800 ThreadDemo[48619:12879824] operation3--<NSThread: 0x600000c7b240>{number = 3, name = (null)}
> 2020-03-19 21:35:53.894355+0800 ThreadDemo[48619:12879824] operation3--<NSThread: 0x600000c7b240>{number = 3, name = (null)}
> 2020-03-19 21:35:53.894723+0800 ThreadDemo[48619:12879620] end

从上面的代码运行结果可以看出，开启了新的线程，任务是串行执行的。

如果将maxConcurrentOperationCount的值修改为2，那么打印的记过如下：

> 2020-03-19 21:36:59.126533+0800 ThreadDemo[48668:12881702] maxCount=2
> 2020-03-19 21:37:01.130238+0800 ThreadDemo[48668:12881793] operation1--<NSThread: 0x600003a92280>{number = 5, name = (null)}
> 2020-03-19 21:37:01.130246+0800 ThreadDemo[48668:12881794] operation2--<NSThread: 0x600003a45840>{number = 6, name = (null)}
> 2020-03-19 21:37:03.133480+0800 ThreadDemo[48668:12881793] operation1--<NSThread: 0x600003a92280>{number = 5, name = (null)}
> 2020-03-19 21:37:03.133489+0800 ThreadDemo[48668:12881794] operation2--<NSThread: 0x600003a45840>{number = 6, name = (null)}
> 2020-03-19 21:37:05.137502+0800 ThreadDemo[48668:12881794] operation3--<NSThread: 0x600003a45840>{number = 6, name = (null)}
> 2020-03-19 21:37:07.140419+0800 ThreadDemo[48668:12881794] operation3--<NSThread: 0x600003a45840>{number = 6, name = (null)}
> 2020-03-19 21:37:07.140713+0800 ThreadDemo[48668:12881702] end

从上面的运行结果可以看出，开启了新的线程，任务是并发执行的，而且每次执行的任务数最大为2个，那是因为我们设置了maxConcurrentOperationCount的值为2，而添加了3个任务在队列中。

## 3.6、NSOperation线程间的通讯

多线程操作可能永远也绕不过线程间通讯这个话题。通常我们将耗时的操作诸如网络请求、文件上传下载都放在子线程中执行，待执行完成之后需要回到主线程进行UI刷新操作，那么就会存在主线程和子线程之间的切换问题，好在NSOperation线程之间的通讯是十分简单的。

```objective-c
-(void)threadCommunication{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"子线程--%@", [NSThread currentThread]);
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2];
                NSLog(@"主线程--%@", [NSThread currentThread]);
            }
        }];
        
    }];
    [queue addOperation:operation];
}
```

> 打印结果：
> 2020-03-19 21:48:12.051256+0800 ThreadDemo[48922:12893188] 子线程--<NSThread: 0x600000b5fa80>{number = 6, name = (null)}
> 2020-03-19 21:48:14.056107+0800 ThreadDemo[48922:12893188] 子线程--<NSThread: 0x600000b5fa80>{number = 6, name = (null)}
> 2020-03-19 21:48:16.059279+0800 ThreadDemo[48922:12893188] 子线程--<NSThread: 0x600000b5fa80>{number = 6, name = (null)}
> 2020-03-19 21:48:18.062773+0800 ThreadDemo[48922:12893188] 子线程--<NSThread: 0x600000b5fa80>{number = 6, name = (null)}
> 2020-03-19 21:48:20.064401+0800 ThreadDemo[48922:12893108] 主线程--<NSThread: 0x600000bd2d00>{number = 1, name = main}
> 2020-03-19 21:48:22.065409+0800 ThreadDemo[48922:12893108] 主线程--<NSThread: 0x600000bd2d00>{number = 1, name = main}

## 3.7、NSOperation 操作依赖

NSOperation最大的亮点莫过于可以添加任务之间的依赖关系。所谓的依赖关系就是任务A需要等待任务B完成之后才能继续执行。NSOperation提供了三个方法为任务之间设置依赖关系。

- `-(void)addDependency:(NSOperation *)op;` 添加依赖，使当前操作依赖于操作 op 的完成。
- `-(void)removeDependency:(NSOperation *)op;` 移除依赖，取消当前操作对操作 op 的依赖。
- `NSArray<NSOperation *> *dependencies;` 在当前操作开始执行之前完成执行的所有操作对象数组。

```objective-c
- (void)addDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2---%@", [NSThread currentThread]);
        }
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3---%@", [NSThread currentThread]);
        }
    }];

    // operation1依赖于operation2和operation3，则先执行operation2和operation3，然后执行operation1
    [operation1 addDependency:operation2];
    [operation1 addDependency:operation3];
    NSArray *opList = @[operation1,operation2,operation3];
    NSArray *dependencies = [operation1 dependencies];
    NSLog(@"dependencies-%@",dependencies);
    [queue addOperations:opList waitUntilFinished:YES];
    NSLog(@"end");
}
```

> 打印结果：
> 2020-03-19 22:11:32.567850+0800 ThreadDemo[49369:12918472] dependencies-( "<NSBlockOperation: 0x7ff341a06e40>", "<NSBlockOperation: 0x7ff341a06f50>" )
> 2020-03-19 22:11:34.571689+0800 ThreadDemo[49369:12918726] 3---<NSThread: 0x6000037cf180>{number = 3, name = (null)}
> 2020-03-19 22:11:34.571694+0800 ThreadDemo[49369:12918732] 2---<NSThread: 0x6000037fbe40>{number = 7, name = (null)}
> 2020-03-19 22:11:36.577098+0800 ThreadDemo[49369:12918726] 3---<NSThread: 0x6000037cf180>{number = 3, name = (null)}
> 2020-03-19 22:11:36.577107+0800 ThreadDemo[49369:12918732] 2---<NSThread: 0x6000037fbe40>{number = 7, name = (null)}
> 2020-03-19 22:11:38.582249+0800 ThreadDemo[49369:12918726] 1---<NSThread: 0x6000037cf180>{number = 3, name = (null)}
> 2020-03-19 22:11:40.587676+0800 ThreadDemo[49369:12918726] 1---<NSThread: 0x6000037cf180>{number = 3, name = (null)}
> 2020-03-19 22:11:40.587996+0800 ThreadDemo[49369:12918472] end

从上面的代码运行结果可以看出operation2和operation3执行完成后才去执行的operation1。

## 3.8、NSOperation的优先级

NSOperation的另一个亮点就是NSOperation提供了`queuePriority`属性，该属性决定了任务在队列中执行的顺序。

- `queuePriority`属性只对同一个队列中的任务有效。
- `queuePriority`属性不能取代依赖关系。
- 对于进入准备就绪状态的任务优先级高的任务优先于优先级低的任务。
- 优先级高的任务不一定会先执行，因为已经进入准备就绪状态的任务即使是优先级低也会先执行。
- 新创建的operation对象的优先级默认是`NSOperationQueuePriorityNormal`，可以通过`setQueuePriority:`方法来修改优先级。

```objective-c
typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};
复制代码
- (void)addDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2---%@", [NSThread currentThread]);
        }
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3---%@", [NSThread currentThread]);
        }
    }];

    // operation1依赖于operation2和operation3，则先执行operation2和operation3，然后执行operation1
    [operation1 addDependency:operation2];
    [operation1 addDependency:operation3];
    operation1.queuePriority = NSOperationQueuePriorityVeryHigh;
    NSArray *opList = @[operation1,operation2,operation3];
    NSArray *dependencies = [operation1 dependencies];
    NSLog(@"dependencies-%@",dependencies);
    [queue addOperations:opList waitUntilFinished:YES];
    NSLog(@"end");
}
```

> 打印结果：
> 2020-03-19 22:31:15.086135+0800 ThreadDemo[49743:12937692] dependencies-( "<NSBlockOperation: 0x7ffa6140a980>", "<NSBlockOperation: 0x7ffa6140a760>" )
> 2020-03-19 22:31:17.087052+0800 ThreadDemo[49743:12937910] 3---<NSThread: 0x6000033d1f80>{number = 5, name = (null)}
> 2020-03-19 22:31:17.087060+0800 ThreadDemo[49743:12937909] 2---<NSThread: 0x6000033d1780>{number = 4, name = (null)}
> 2020-03-19 22:31:19.087421+0800 ThreadDemo[49743:12937909] 2---<NSThread: 0x6000033d1780>{number = 4, name = (null)}
> 2020-03-19 22:31:19.087421+0800 ThreadDemo[49743:12937910] 3---<NSThread: 0x6000033d1f80>{number = 5, name = (null)}
> 2020-03-19 22:31:21.090223+0800 ThreadDemo[49743:12937910] 1---<NSThread: 0x6000033d1f80>{number = 5, name = (null)}
> 2020-03-19 22:31:23.092879+0800 ThreadDemo[49743:12937910] 1---<NSThread: 0x6000033d1f80>{number = 5, name = (null)}
> 2020-03-19 22:31:23.093183+0800 ThreadDemo[49743:12937692] end

如上代码运行结果所示，即使将operation1的优先级设置为最高NSOperationQueuePriorityVeryHigh，operation1依然是最后执行的，那是因为operation1依赖于operation2和operation3，在operation2和operation3未执行完成之前，operation1一直是处于为就绪状态，即使优先级最高，也不会执行。

## 3.9、状态

NSOperation包含了一个十分优雅的状态机来描述每一个操作的执行。`isReady → isExecuting → isFinished`。为了替代不那么清晰的`state`属性，状态直接由上面那些`keypath`的`KVO`通知决定，也就是说，当一个操作在准备好被执行的时候，它发送了一个`KVO`通知给`isReady`的`keypath`，让这个`keypath`对应的属性`isReady`在被访问的时候返回`YES`。 每一个属性对于其他的属性必须是互相独立不同的，也就是同时只可能有一个属性返回YES，从而才能维护一个连续的状态：

- `isReady`: 返回`YES`表示操作已经准备好被执行, 如果返回`NO`则说明还有其他没有先前的相关步骤没有完成。
- `isExecuting`: 返回`YES`表示操作正在执行，反之则没在执行。
- `isFinished` : 返回`YES`表示操作执行成功或者被取消了，`NSOperationQueue`只有当它管理的所有操作的`isFinished`属性全标为`YES`以后操作才停止出列，也就是队列停止运行，所以正确实现这个方法对于避免死锁很关键。

## 3.10、其他API

1. `- (void)cancel;` 可取消操作，实质是标记 isCancelled 状态。 判断操作状态方法
2. `- (BOOL)isFinished;` 判断操作是否已经结束。
3. `- (BOOL)isCancelled;` 判断操作是否已经标记为取消。
4. `- (BOOL)isExecuting;` 判断操作是否正在在运行。
5. `- (BOOL)isReady;`判断操作是否处于准备就绪状态，这个值和操作的依赖关系相关。
6. `- (void)waitUntilFinished;` 阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
7. `- (void)setCompletionBlock:(void (^)(void))block;` completionBlock 会在当前操作执行完毕时执行 completionBlock。
8. `- (void)cancelAllOperations;`可以取消队列的所有操作。
9. `- (BOOL)isSuspended;` 判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态。10.`- (void)setSuspended:(BOOL)b;` 可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表恢复队列。
10. `- (void)waitUntilAllOperationsAreFinished;` 阻塞当前线程，直到队列中的操作全部执行完毕。
11. `- (NSUInteger)operationCount;` 当前队列中的操作数。 获取队列
12. `+ (id)currentQueue;` 获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。

# 4、NSOperation的线程安全

和其他多线程方案一样，解决NSOperation多线程安全问题，可以给线程加锁，在一个线程执行该操作的时候，不允许其他线程进行操作。iOS 实现线程加锁有很多种方式。`@synchronized、 NSLock、NSRecursiveLock、NSCondition、NSConditionLock、pthread_mutex、dispatch_semaphore、OSSpinLock`等等各种方式。

# 5、参考资料

- [苹果官方文档-Operation Queues](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FGeneral%2FConceptual%2FConcurrencyProgrammingGuide%2FOperationObjects%2FOperationObjects.html)
- [苹果官方文档-NSOperation](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FGeneral%2FConceptual%2FConcurrencyProgrammingGuide%2FOperationObjects%2FOperationObjects.html)
- [NSOperation](https://nshipster.cn/nsoperation/)