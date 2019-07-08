# 关于console.log

工作中console可能是用来debug的最频繁的原生方法了，它不仅仅非常实用，而且还有一些有趣的东西。
* console.log
	1. 常见占位符

		__%o__:接受Object
		__%s__:接受String
		__%d__:接受Number
		
		![图片](https://foxdaxian.github.io/assets/01_console/base_log.png)
	1. css占位符
		__%c__:接受CSS
		
		![图片](https://foxdaxian.github.io/assets/01_console/color_log.png)
		
--------

* console.dir
	1. 打印对象的时候与console.log无明显区别，但是当打印元素的时候有明显区别，如图：
	![图片](https://foxdaxian.github.io/assets/01_console/dir.gif)
	log会展示当前节点以及子孙节点，dir会展示节点的所有属性

------

* console.warn
	1. 在输出上与console.log不同，它的输出为黄色警告样式
	
-------

* console.table
	1. 输出漂亮的格式化后的数组，并且提供排序功能，有可选的第二个数组参数，过滤想要展示的key。不过该方法仅仅能展示最多1000行，所以不适合处理数据量大的数组。如图：
	 ![图片](https://foxdaxian.github.io/assets/01_console/table.gif)

--------

* console.assert
	1. 有至少两个参数，第一个参数为条件，当条件为真的时候，无任何输出，当条件为false的时候，像console.log一样输出之后的所有参数

-------

* console.count
	1. 记录调用的次数，接受一个参数作为输出前缀，可以通过```console.countReset ()```重置

-------

* console.trace
	1. 输出堆栈跟踪记录，如图
	 ![图片](https://foxdaxian.github.io/assets/01_console/trace.png)

------

* console.time & console.timeEnd
	1. 记录js操作花费了多长时间，接受一个参数，该参数在两个方法里必须都一致才能输出计算时间，单位为毫秒，如图
	 ![图片](https://foxdaxian.github.io/assets/01_console/time.png)

------

* console.group & console.groupEnd
	1. 在控制台创建新的缩进列，以group开始，以groupEnd接受，group接受一个参数，来表示缩进前缀，如图
	 ![图片](https://foxdaxian.github.io/assets/01_console/group.png)

------

### 总结
__console对象上还有一些其他方法，这里就不过多介绍了，以上方法，用的做多的仅仅只有console.log，其他的偶会会用到，不过知道了真的就是知道了。__