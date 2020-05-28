SEL : 类成员方法的指针，但不同于C语言中的函数指针，函数指针直接保存了方法的地址，但SEL只是方法编号。

IMP:一个函数指针,保存了方法的地址

IMP和SEL关系

每一个继承于NSObject的类都能自动获得runtime的支持。在这样的一个类中，有一个isa指针，指向该类定义的数据结构体,这个结构体是由编译器编译时为类（需继承于NSObject）创建的.在这个结构体中有包括了指向其父类类定义的指针以及 Dispatch table. Dispatch table是一张SEL和IMP的对应表。[(http://blog.csdn.net/fengsh998/article/details/8614486)](http://blog.csdn.net/fengsh998/article/details/8614486)

也就是说方法编号SEL最后还是要通过Dispatch table表寻找到对应的IMP，IMP就是一个函数指针，然后执行这个方法

#### Q1:有什么办法可以知道方法编号呢

@selector()就是取类方法的编号。

```objective-c
SEL methodId=@selector(func1);
```



#### Q2:编号获取后怎么执行对应方法呢

```objective-c
[self performSelector:methodIdwithObject:nil];
```



#### Q3:有没有办法通过编号获取方法

```objective-c
NSString*methodName = NSStringFromSelector(methodId);
```



#### Q4:IMP怎么获得和使用

```objective-c
IMP methodPoint = [self methodForSelector:methodId];
methodPoint();
```



#### Q5:为什么不直接获得函数指针，而要从SEL这个编号走一圈再回到函数指针呢？

有了SEL这个中间过程，我们可以对一个编号和什么方法映射做些操作，也就是说我们可以一个SEL指向不同的函数指针，这样就可以完成一个方法名在不同时候执行不同的函数体。另外可以将SEL作为参数传递给不同的类执行。也就是说我们某些业务我们只知道方法名但需要根据不同的情况让不同类执行的时候，SEL可以帮助我们。