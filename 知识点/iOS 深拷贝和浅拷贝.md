

#### 概述

> 浅拷贝：只创建一个新的指针，指向原指针指向的内存。
>
> 深拷贝：创建一个新的指针，并开辟一块新的内存空间，内容拷贝为原指针指向的内存，并指向它。

#### 非容器对象

> - 非容器对象使用的mutableCopy都是深拷贝
> - 非容器对象使用的Copy ，不可变对象都是浅拷贝，可变对象都是深拷贝
> - 非容器对象copy得到的类型一定是不可变的；mutableCopy得到的类型一定是可变的

例子

##### NSString  Copy/mutableCopy

```objective-c
NSString *string = @"HelloWorld";
// 没有开辟新的内存，浅拷贝
NSString *copyString = [string copy];
// 开辟了新的内存，深拷贝
NSMutableString *mutableCopyString = [string mutableCopy];
[mutableCopyString appendString:@"你好"];

NSLog(@"string = %p  copyString = %p  mutableCopyString = %p",string,copyString,mutableCopyString);
NSLog(@"string = %@  copyString = %@  mutableCopyString = %@",string,copyString,mutableCopyString);

//打印结果
2019-08-01 11:58:01.961414+0800 Dynamic[1901:97559] 
  string     				= 0x10839f068 
  copyString			  = 0x10839f068 
  mutableCopyString = 0x6000015f8d50
2019-08-01 11:58:01.961547+0800 Dynamic[1901:97559] 
  string						= HelloWorld  
  copyString 				= HelloWorld 
  mutableCopyString = HelloWorld你好
// 可以看到string和copyString的地址是相同的，mutableCopyString的地址是一个新的地址，说明对于不可变对象NSString的copy是浅拷贝，mutableCopy是深拷贝，只不过copy得到的类型是不可变的，mutableCopy得到的类型是可变的
```

##### NSMutableString Copy/mutableCopy

```objective-c
NSMutableString *string = [NSMutableString stringWithString:@"HelloWorld"];
// 开辟了新的内存，深拷贝
NSString *copyString = [string copy];
// 开辟了新的内存，深拷贝
NSMutableString *mutableCopyString = [string mutableCopy];
[mutableCopyString appendString:@"你好"];

NSLog(@"string = %p  copyString = %p  mutableCopyString = %p",string,copyString,mutableCopyString);
NSLog(@"string = %@  copyString = %@  mutableCopyString = %@",string,copyString,mutableCopyString);

// 打印结果
2019-08-01 12:04:26.177294+0800 Dynamic[1984:102247] 
  string 						= 0x600003583ed0  
  copyString 				= 0x600003b843c0  
  mutableCopyString = 0x600003583f90
2019-08-01 12:04:26.177414+0800 Dynamic[1984:102247] 
  string 						= HelloWorld 
  copyString 				= HelloWorld 
  mutableCopyString = HelloWorld你好
// 可以看到string、copyString和mutableCopyString的地址都不相同，说明对于可变对象NSMutableString的copy和mutableCopy都是深拷贝，只不过copy得到的类型是不可变的，mutableCopy得到的类型是可变的
```



#### 容器对象

> - 容器对象（NSArray，NAMutableArray；NSDictionary，NSMutableDictionary；NSSet集合）遵循非容器对象的拷贝原则
> - 容器内的元素都是浅拷贝

##### copy/mutableCopy NSArray

```objective-c
NSArray *array = @[[NSMutableString stringWithString:@"Hello"],@"World"];
// 未创建了新的容器(浅拷贝)，容器内的元素是指针赋值
NSArray *copyArray = [array copy];
// 创建了新的容器(深拷贝)，容器内的元素是指针赋值
NSMutableArray *mutableCopyArray = [array mutableCopy];
    
NSMutableString *tempString = [array objectAtIndex:0];
[tempString appendString:@"World"];
    
NSLog(@"array = %p copyArray = %p mutableCopyArray = %p",array,copyArray,mutableCopyArray);
NSLog(@"array[0] = %@  copyArray[0] = %@  mutableCopyArray[0] = %@",array[0],copyArray[0],mutableCopyArray[0]);
NSLog(@"array[0] = %p copyArray[0] = %p mutableCopyArray[0] = %p",array[0],copyArray[0],mutableCopyArray[0]);

// 打印结果
2019-08-01 12:41:24.978156+0800 Dynamic[2294:126131]
  array 					 = 0x600001d28720
  copyArray 			 = 0x600001d28720 
  mutableCopyArray = 0x600001334cf0
2019-08-01 12:41:24.978278+0800 Dynamic[2294:126131] 
  array[0] 						= HelloWorld 
  copyArray[0] 				= HelloWorld 
  mutableCopyArray[0] = HelloWorld
2019-08-01 12:41:24.978346+0800 Dynamic[2294:126131] 
  array[0] 						= 0x600001334660 
  copyArray[0]			  = 0x600001334660 
  mutableCopyArray[0] = 0x600001334660
// 可以看到array和copyArray的地址是相同的，mutableCopyArray的地址是一个新的地址，说明对于不可变对象NSArray的copy是浅拷贝，mutableCopy是深拷贝，只不过copy得到的类型是不可变的，mutableCopy得到的类型是可变的
// 我们也看到即使创建了新的容器，容器内的元素指针指向的还是原来元素指向的内存地址，并没有开辟新的内存空间，所以容器内的元素是指针拷贝或者是浅拷贝

```



##### copy/mutableCopy NSMutableArray

```objective-c
NSMutableArray *array = [NSMutableArray arrayWithObjects:[NSMutableString stringWithString:@"Hello"], @"World", nil];
// 创建了新的容器(深拷贝)，容器内的元素是指针赋值
NSArray *copyArray = [array copy];
// 创建了新的容器(深拷贝)，容器内的元素是指针赋值
NSMutableArray *mutableCopyArray = [array mutableCopy];
    
NSMutableString *tempString = [array objectAtIndex:0];
[tempString appendString:@"World"];

NSLog(@"array = %p copyArray = %p mutableCopyArray = %p",array,copyArray,mutableCopyArray);
NSLog(@"array[0] = %@  copyArray[0] = %@  mutableCopyArray[0] = %@",array[0],copyArray[0],mutableCopyArray[0]);
NSLog(@"array[0] = %p copyArray[0] = %p mutableCopyArray[0] = %p",array[0],copyArray[0],mutableCopyArray[0]);

// 打印结果
2019-08-01 12:58:36.230903+0800 Dynamic[2436:138399] array = 0x60000222ea60 copyArray = 0x600002c33960 mutableCopyArray = 0x60000222e700
2019-08-01 12:58:36.231016+0800 Dynamic[2436:138399] array[0] = HelloWorld  copyArray[0] = HelloWorld  mutableCopyArray[0] = HelloWorld
2019-08-01 12:58:36.231089+0800 Dynamic[2436:138399] array[0] = 0x60000222e790 copyArray[0] = 0x60000222e790 mutableCopyArray[0] = 0x60000222e790

// 可以看到array、copyArray和mutableCopyArray的地址都不相同，说明对于可变对象NSMutableArray的copy和mutableCopy都是深拷贝，只不过copy得到的类型是不可变的，mutableCopy得到的类型是可变的
// 我们也看到即使创建了新的容器，容器内的元素指针指向的还是原来元素指向的内存地址，并没有开辟新的内存空间，所以容器内的元素是指针拷贝或者是浅拷贝

```



##### 容器中元素的深拷贝

```objective-c
NSArray *array = [NSArray arrayWithObjects:[NSMutableString stringWithString:@"Hello"], @"World", nil];
// 创建了新的容器(深拷贝)，容器内的元素得到复制
NSArray *deepCopyArray = [[NSArray alloc] initWithArray:array copyItems:YES];
// 创建了新的容器(深拷贝)，容器内的元素得到复制
NSArray *trueDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];

NSMutableString *tempString = [array objectAtIndex:0];
    [tempString appendString:@"World"];
   
NSLog(@"array = %p deepCopyArray = %p trueDeepCopyArray = %p",array,deepCopyArray,trueDeepCopyArray);
NSLog(@"array[0] = %@  deepCopyArray[0] = %@  trueDeepCopyArray[0] = %@",array[0],deepCopyArray[0],trueDeepCopyArray[0]);
NSLog(@"array[0] = %p deepCopyArray[0] = %p trueDeepCopyArray[0] = %p",array[0],deepCopyArray[0],trueDeepCopyArray[0]);

// 打印结果
2019-08-01 13:26:50.430120+0800 Dynamic[2692:158714] array = 0x6000035a7de0 deepCopyArray = 0x6000035a7da0 trueDeepCopyArray = 0x6000035a7f40
2019-08-01 13:26:50.430242+0800 Dynamic[2692:158714] array[0] = HelloWorld  deepCopyArray[0] = Hello  trueDeepCopyArray[0] = Hello
2019-08-01 13:26:50.430347+0800 Dynamic[2692:158714] array[0] = 0x600003bf4bd0 deepCopyArray[0] = 0xfd90af5bb30ad2a2 trueDeepCopyArray[0] = 0x600003bf4d50

// 可以看到array、copyArray和mutableCopyArray的地址都不相同，说明创建了新的容器，容器内的元素指针指向的已经不是原来元素指向的内存地址，开辟新的内存空间，所以这是真正意思上容器对象的深拷贝

```



#### 自定义对象

自定义对象使用copy和mutableCopy需要遵守`NSCopying`和`NSMutableCopying`协议，实现`- (id)copyWithZone:(nullable NSZone *)zone`和`- (id)mutableCopyWithZone:(nullable NSZone *)zone`方法。

```objective-c
#import "Person.h"

@interface Person ()<NSCopying>

@end

@implementation Person

- (id)copyWithZone:(NSZone *)zone {
    
    Person *person = [[Person allocWithZone:zone] init];
    
    person.name = self.name;
    person.age = self.age;
    
    return person;
}

@end

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *person = [[Person alloc] init];
    person.name = @"张三";
    person.age = 18;
    
    Person *copyPerson = [person copy];
    NSLog(@"person = %@  person.name = %@  person.age = %ld",person,person.name,person.age);
    NSLog(@"copyPerson = %@  copyPerson.name = %@  copyPerson.age = %ld",copyPerson,copyPerson.name,copyPerson.age);
}

@end

// 打印结果
2019-08-01 15:04:04.245831+0800 Dynamic[3175:197448] person = <Person: 0x600002920760>  person.name = 张三  person.age = 18
2019-08-01 15:04:04.245989+0800 Dynamic[3175:197448] copyPerson = <Person: 0x6000029208e0>  copyPerson.name = 张三  copyPerson.age = 18

// 我们可以看到copyWithZone重新分配了内存空间，如果调用mutableCopy需要遵守NSMutableCopying实现mutableCopyWithZone方法，结果也是重新分配了内存空间

```



#### 应用｜面试题

> 在面试的时候面试官会经常问到NSString属性是用copy还是用strong修饰，如果用strong会有什么样的问题，NSMutableString属性用copy还是用strong，如果用copy会有什么样的问题，通过以上内容我们会很容易做出判断。

##### 问：`@property (nonatomic, strong) NSMutableString *name;`为什么不用copy修饰？

答：使用copy修饰其实在属性的setter方法中调用了`[name copy]`，我们知道不管是NSString还是NSMutableString使用copy都会生成NSString类型，显然这里调用了NSMutableString的`appendString:`方法会报错。我们定义一个NSMutableString类型，当然希望能够使用NSMutableString可变的特性，如果使用copy会变成NSString类型，这样也违背了我们定义NSMutableString类型的初衷了，不如干脆定义一个NSString类型。

##### 问：NSString类型的属性用`copy`，还是`strong`修饰？

答：所以，NSMutableString类型使用`strong`修饰，NSString类型`最好`使用`copy`，谨慎使用`strong`

```objective-c
#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *name;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableString *string = [NSMutableString stringWithFormat:@"Hello"];
    
    self.name = string;
    [string appendString:@"World"];
    
    NSLog(@"%@",self.name);
}

// 打印结果
2019-08-01 15:44:28.251950+0800 Dynamic[3494:225545] HelloWorld

// 我们可以看到我们定义的NSString类型的属性用strong修饰，当我们给它传一个NSMutableString类型的数据时，它的指针指向了该数据，之后会随NSMutableString的特性去改变
// 这样就违背了我们定义NSString类型的初衷了，在项目里面谨慎使用
// 如果使用copy就不会有这样的问题，我们定义NSString类型，使用copy，不管给它传的值是NSString还是NSMutableString最后都会得到NSString类型

```



参考链接

[iOS深拷贝和浅拷贝](https://juejin.im/post/5d9de2d3f265da5bb414bf4e)

