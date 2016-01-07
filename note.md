scrollView的contentInset是指content到边界的距离, 和textContainerInset的概念是一样的. offset是指scrollView的原点相对于content原点的偏移. 所以是以content的原点为基准的.

controller的`automaticallyAdjustScrollViewInset`变量修改的是contentInset. 

所有用户和scrollView的滑动交互修改的都是contentOffset.

对contentInset的修改只能我们在代码里或者系统根据xib或者sb的设定去修改


开发的时候, 需要考虑代码的扩展性. 比如下一版服务器字段添加了新值的时候, 老版本能够保证不出问题.

Swift用`!`一定会出错! Swift用`!`一定会出错! Swift用`!`一定会出错! 重要的事说三遍...... 
