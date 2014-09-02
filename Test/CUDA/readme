/**
 * 
 * About
 * 
 * 在cuda外围打转很长时间，关于架构的知识不打算再纠结下去，从今天开始切入代码学习。
 * 主要方法是通过重写cuda samples 的同时google代码解析，同时学习架构。
 * 
 * chunk 2014
 * 
**/


//0902

今天第一个例程是asyncAPI，网上没有找到解析。
不过程序readme中给出：This sample uses CUDA streams and events to overlap execution on CPU and GPU.

这个程序很小，只有一个.cu文件。作为第一个例程，makefile和程序的结构是重点。
	$^ 所有的依赖目标的集合。以空格分隔。如果在依赖目标中有多个重复的,那个这个变量会去除重复的依赖目标,只保留一份。
	$@   表示规则中的目标文件集。在模式规则中,如果有多个目标,那么,"$@"就是匹配于目标中模式定义的集合。

	= 是最基本的赋值
	:= 是覆盖之前的值
	?= 是如果没有被赋值过就赋予等号后面的值
	+= 是添加等号后面的值

1.INCLUDES  := -I../../common/inc
2.cuda编程模型
《cuda编程模型》
	记住三个图：
	1.三级线程组织
	2.内存分配模型
	3.硬件(SM和内存)结构
	
	其中，内存分配模型是pull request，当block分配至SM之后，由硬件对request进行检查、分配。
3.cuda编译
(1)浅析CUDA编译流程与配置方法 (我们现在需要的是cuda程序的编译结构(例如.cu和cpp文件的综合处理))
	http://blog.csdn.net/shi06/article/details/5110017
	Nvcc是一种编译器驱动，通过命令行选项可以在不同阶段启动不同的工具完成编译工作，其目的在于隐藏了复杂的CUDA编译细节，并且它不是一个特殊的CUDA编译驱动而是在模仿一般的通用编译驱动如gcc，它接受一定的传统编译选项如宏定义，库函数路径以及编译过程控制等。CUDA程序编译的路径会因在编译选项时设置的不同CUDA运行模式而不同，如模拟环境的设置等。nvcc封装了四种内部编译工具，即在C:/CUDA/bin目录下的nvopencc(C:/CUDA/open64/bin)，ptxas，fatbin，cudafe

	1.首先是对输入的cu文件有一个预处理过程
		cudafe被称为CUDA frontend，会被调用两次，完成两个工作：一是将主机代码与设备代码分离，生成gpu文件，二是对gpu文件进行dead code analysis，传给nvopencc。 Nvopencc生成ptx文件传给ptxas，最后将cubin或ptx传给fatbin。
	2.同时，在编译阶段CUDA源代码对C语言所扩展的部分将被转成regular ANSI C的源文件，也就可以由一般的C编译器进行更多的编译和连接。
		也即是设备代码被编译成ptx（parallel thread execution）代码或二进制代码，host代码则以C文件形式输出，在编译时可将设备代码链接到所生成的host代码，将其中的cubin对象作为全局初始化数据数组包含进来
	Nvcc的各个编译阶段以及行为是可以通过组合输入文件名和选项命令进行选择的。它是不区分输入文件类型的，如object, library or resource files，仅仅把当前要执行编译阶段需要的文件传递给linker。

	
(2)参考 NVIDIA CUDA Compiler Driver NVCC 官方文档 - http://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/#axzz3CA54wmUH

	This compilation trajectory involves several splitting, compilation, preprocessing, and merging steps for each CUDA source file, and several of these steps are subtly different for different modes of CUDA compilation (such as compilation for device emulation, or the generation of device code repositories). It is the purpose of the CUDA compiler driver nvcc to hide the intricate details of CUDA compilation from developers.

	Compilation Phases
(3)Another Example ：

	http://stackoverflow.com/questions/9421108/g-nvcc-how-to-compile-cuda-code-then-link-it-to-a-g-c-project/9505239#9505239

		all: program
		program: cudacode.o
			g++ -o program -L/usr/local/cuda/lib64 -lcuda -lcudart main.cpp  cudacode.o 
		cudacode.o:
			nvcc -c -arch=sm_20 cudacode.cu 
		clean: rm -rf *o program
	
	暴力方式：
	
		all:
			nvcc cudafile.cu mainfile.cpp -o executable
		clean:
			rm -rf *.o
			
(4)(from http://stackoverflow.com/users/749748/harrism)
	A couple of additional notes:

	1.You don't need to compile your .cu to a .cubin or .ptx file. You need to compile it to a .o object file and then link it with the .o object files from your .cpp files compiled wiht g++.
	
	2.In addition to putting your cuda kernel code in cudaFunc.cu, you also need to put a C or C++ wrapper function in that file that launches the kernel (unless you are using the CUDA driver API, which is unlikely and not recommended). Also add a header file with the prototype of this wrapper function so that you can include it in your C++ code which needs to call the CUDA code. Then you link the files together using your standard g++ link line.

	http://stackoverflow.com/questions/9363827/building-gpl-c-program-with-cuda-module

(5)/**
看起来像是终级解决方案：
	http://stackoverflow.com/questions/9363827/building-gpl-c-program-with-cuda-module
	
	You don't need to compile everything with nvcc. Your guess that you can just compile your CUDA code with NVCC and leave everything else (except linking) is correct. Here's the approach I would use to start.

	1. Add a 1 new header (e.g. myCudaImplementation.h) and 1 new source file (with .cu extension, e.g. myCudaImplementation.cpp). The source file contains your kernel implementation as well as a (host) C wrapper function that invokes the kernel with the appropriate execution configuration (aka <<<>>>) and arguments. The header file contains the prototype for the C wrapper function. Let's call that wrapper function runCudaImplementation()

	2. I would also provide another host C function in the source file (with prototype in the header) that queries and configures the GPU devices present and returns true if it is successful, false if not. Let's call this function configureCudaDevice().

	3.Now in your original C code, where you would normally call your CPU implementation you can do this.
		// must include your new header
		#include "myCudaImplementation.h"

		// at app initialization
		// store this variable somewhere you can access it later
		bool deviceConfigured = configureCudaDevice;          
		...                             
		// then later, at run time
		if (deviceConfigured) 
			runCudaImplementation();
		else
			runCpuImplementation(); // run the original code
	
	4.(最重要的)Now, since you put all your CUDA code in a new .cu file, you only have to compile that file with nvcc. Everything else stays the same, except that you have to link in the object file that nvcc outputs. e.g.
 
		nvcc -c -o myCudaImplementation.o myCudaImplementation.cu <other necessary arguments>

	Then add myCudaImplementation.o to your link line (something like:) g++ -o myApp myCudaImplementation.o

	5.(补充)Got it working. One additional step others may need to do is add extern "C" { } around the wrapper method. This is probably obvious to linking veterans, though. –  emulcahy
	(再补充)You shouldn't have to use extern "C" unless you only have C linkage (e.g. calling it from a .c file). –  harrism
*/
(6)	补充：
	关于extern "C" {} http://xlhnuaa.blog.163.com/blog/static/17233660320124293147308/
	1. 使用extern和包含头文件来引用函数有什么区别呢？extern的引用方式比包含头文件要简洁得多！extern的使用方法是直接了当的，想引用哪个函数就用extern声明哪个函数。这大概是KISS原则的一种体现吧！这样做的一个明显的好处是，会加速程序的编译（确切的说是预处理）的过程，节省时间。在大型C程序编译过程中，这种差异是非常明显的。
	
	2. 　作为一种面向对象的语言，C++支持函数重载，而过程式语言C则不支持。函数被C++编译后在符号库中的名字与C语言的不同。例如，假设某个函数的原型为：voidfoo( int x, int y );该函数被C编译器编译后在符号库中的名字为_foo，而C++编译器则会产生像_foo_int_int之类的名字
	
	未加extern "C"声明时的连接方式 - 实际上，在连接阶段，连接器会从模块A生成的目标文件moduleA.obj中寻找_foo_int_int这样的符号！
	
	加extern "C"声明后的编译和连接方式 - 
	extern "C" int foo( int x, int y );
	在模块B的实现文件中仍然调用foo（2,3），其结果是：（1）模块A编译生成foo的目标代码时，没有对其名字进行特殊处理，采用了C语言的方式；（2）连接器在为模块B的目标代码寻找foo(2,3)调用时，寻找的是未经修改的符号名_foo。

	3.extern "C"通常的使用技巧






















