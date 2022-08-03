--[[
    lua中for i=1, fn(), step=1 ==>  for(int i=1, j=fn(); i<=j; i+=step) 
--]]

--lua里^是幂，没有整数相除
*math{
	pi、huge
	max(a,b)
	min(a,b)	

	ceil(x)	 --向上取整
	floor(x)  --向下取整
	
	sin(x)	
	cos(x)
	tan(x)
	
	asin(x)  
	acos(x)
	atan(x)  --arctan(x)
	atan2(y,x)	--arctan(y/x)

	sinh(x)
	cosh(x)
	tanh(x)

	log(x)  --ln(x)
	log10(x)	--lg(x)	
	exp(x)	
	pow(x,y)  --Lua中可以直接x^y	

	randomseed(seed)  --set seed:number	
	random(a,b)  --如果a=b=nil,返回0-1的浮点数。否则返回a~b的整数	
		
	ldexp(x,y)  --return x*2^y	
	frexp(x)  --return m,y.  m*2^y = x	
	
	abs(x)
	sqrt(x)	
	
	fmod(a,b)  --返回a/b的余数。 while(a>b){a-=b;} return a; 	
	modf(x)  --返回	整数部分,小数部分
	
	deg(x)	 --return 180 * x / math.pi	
	rad(angle)  --return math.pi * angle/180	
	--饥荒追加
	clamp(num, min, max)    
}

*string{		--用 [[  ]]可返回生字符串，用..连接字符串与数字.
	--都是返回copy的string
	find(string,pattern)  --return from,to
	match(string,pattern[,from])	-->string | nil
	gmatch(string,pattern)  -->function, fuction()返回符合pattern的下一个子串或nil		for word in string.gmatch("Hello Lua user", "%a+") do print(word) end
	--[[
		格式：特殊字符包括 ^$()%.[]*+-? 
		%d,%x,%w  --单个数字，十六进数字，字母/数字
		%u,%l,$u  --大写，小写，空白字符
		%a,%c,%p,%w  --任意字母，控制字符(\n等)，标点,字母/数字
		. , %z    --任意字符，任意代表0的字符
		%特殊字符  --转义
		[]、[^]、^、$、()、*、+、?、. 同正则，  - 表示尽可能短，取代了正则的?x中的?
		%b()、%b[]、$b{}	--匹配括号
		%n	--第n个捕获物之后的子串
	]]	
	format("the value is %d",arg1,...)  -->string  同C的,追加：
	-- %q - 接受一个字符串并将其转化为可安全被Lua编译器读入的格式.如："%q","One\nTwo" 返回字符串 \"One\\换行Two\"
	-- %02d  - 表示占2位，前面补0或无效
	rep(string,n)  -->string  string..string.. 共n个string
	gsub(str,findstr,repstr[,num])  	
	len(str)  -->number	
	reverse(str) -->string	
	byte(string,from=1,to=1)  --字符转ASCII	
	char(number[,number2,...])	-->string ASCII转字符串	
	upper(str)	-->string
	lower(str)	-->string
	sub(string,from[,to])  -->string  from、to可以为负数(-10,-1)，表示从后面开始	
}

io{
	stdin、stdout、stderr : file	--userdata
	tmpfile()  -->file ，程序关闭删除临时文件
	lines(filename[,"format"]) --> function,  function()返回  strline或按格式返回		
	open(filename,mode)  -->file|nil [,errorstr]
	input(filename)	  -->file 只读
	output(filename)	-->file 只写
	--file
	:read(...)
	:write(...)	
	:flush()	
	:close()	
	:type()	
	
}

debug{
	debug()	--进入命令行模式
	setupvalue(f,upindex,value)  --> return upvalue_name or nil.   upvalue为f中调用的local全局变量出现的次序(1~huge)	
	getupvalue(f,upindex)	--> return upvalue_name,value or nil,nil

	getregistry() --> table{ ["FILE*"] = {} , _LOADED = {io,os,table,math,coroutine等}, _LOADLIB = {__gc:funcion}, _PRELOAD = {ffi:function} } 	
	traceback([thread,][,message[,level]])  -->string.  	
	getinfo([thread,]fn[,mode])	--> table, 返回函数信息，参数格式，书写位置，来源，是否参有...等，不过饥荒里的有些数据没有	
	--mode："S".what = C/main/?		"f".func	"n".namewhat
	
	setlocal(thread,level,local,value)	
	getlocal(thread,f,local)

	sethook(thread,hook,mask[,count])	-- mask='c'(每调用一个函数),'r'(每函数返回),'l'(每行). hook = function(str,line=nil(只有'l'时才有)) str="call","return","line"	
	gethook(thread) --> hook:function,mask:string,count:number	
	getmetatable(object)  --> table|nil 	注：_G.getmetatable ~= debug.getmetatable	
	setmetatable(object,table=nil)	-->设置userdata(或其他)的metatable.  5.2追加返回object
	setfenv(object,table)  --设置object的环境
	getfenv(object)  --返回object的环境  5.2弃用(deprecated)
	--饥荒追加
	getsize()
	
	--5.2
	setuservalue(userdata,table=nil)  -->return userdata. 设置userdata的metatable
	getuservalue(userdata)	--> return getmetatable(userdata)
	upvalueid(f,n)	--> userdata,常用来判断是否两函数同用个upvalue.	 ok = userdata1==userdata2
	upvaluejoin(f1,n1,f2,n2)  --让f1引用f2的upvalue	
}

os{
	execute(command:string)  --> bool[,string,number]   相对于C的system	
	exit(number)  --相对于C的exit(number).   Lua5.2, (number|bool[,close])	true/false -> SUCCESS/FAILURE, close:true-> close lua state before exiting
	setlocale(locale:string[,catagory:string])  --> name:string or nil.  locale="C"   catagory="all","time","numberic","ctype"等等	
	getenv(varname)  --> string or nil. varname不区分大小写：
	 --[[  varname 不区分大小写
		OS		操作系统的名称
		COMPUTERNAME	计算机的名称
		SystemRoot	系统根目录
		SYSTEMDRIVE		系统根目录的驱动器
		
		ALLUSERSPROFILE		所有“用户配置文件”的位置

		COMSPEC		命令行解释器可执行程序(CMD)的绝对路径
		
		HOMEDRIVE	连接到用户主目录的本地工作站驱动器号
		HOMEPATH	用户主目录的完整路径，无C:

		NUMBER_OF_PROCESSORS	安装在计算机上的处理器的数目
		PROCESSOR_LEVEL		计算机上安装的处理器的型号
		PROCESSOR_REVISION		处理器修订号的系统变量

		PATHEXT		连接到用户主目录的本地工作站驱动器号		
		TEMP		临时目录
	]]	
		
	clock()  --> sec:number. 返回大概CPU使用在本程序的时间，不是很准确而且会无效
	time(table=nil)  --> sec:number.  	table{	year,month,day = ... , hour=12,min=0,sec=0,isdst=nil} 只有year,month,day是必须的
	difftime(time1,time2)	--> 相差的秒数 return time1-time2(WINDOW/POSIX)
	date([format:string[,time:number]])	--> stirng or table. 全空->当前时间的str.  format: "*t"(return table), "%c"(locale格式)
	tmpname()	--> filename.   have to open and remove it, even if we don't use it!
	rename(oldname,newname)	 --> bool[,string,number].  rename file or directory of oldname to newname
	remove(filename)  -->bool[,string,number]
}

协程：Lua里没线程，不过可以把函数拆成几部分运行
coroutine{
	creat(fn) -->thread
	resume(fn,...)  -->true,...  |   false,strerror. start with ... or restart with old paragms/environment
	yield(...)  --挂起suspended. ...将作为resume的第二参数返回。其参数下次继续用.当然也可以写在非thread函数中，然后在thread中调用该函数
	running()  -->thread,bool.  返回真正运行的thread，bool为true表示主协程
	wrap(fn)  --> fuction, 创建个thread，每次调用function相对于resume，返回fn的结果或报错
	status(co:thread)  -->string: dead，suspended(挂起/未运行)，running,nomal(内部调用其他thread)
}

userdata: 一般是C/C++的数据类型
newproxy(bool|proxy) -->Creates a blank userdata with(bool)without an empty metatable,
 					 --or with the metatable of another proxy

表：
--index = number/string
--t[key]、t.str
--table[key]: key可以为非nil的任意类型！
--for k,v in pairs(table) do ... end   ipair只遍历num
--#table  最后的index(只记number的)
--[[
	metatable={
		--5.1
		__index = function(t,k)  end  or  table --table[k]时调用
		__nexindex = fuction(t,k,v)  end  --table[new_k]时调用
		__len = function(t) return length end  --返回#table的值 
		__call = function(t,...)  end	-- table(...)时调用此函数
		__tostring = function(t) return "string"  end  -- print(t)时调用
		__add = function(t1,t2) end  -- t1 + t2 时调用
		同上的还有，__sub(-)、__mul(*)、__div(/)、__mod(%)、__unm(-)、__concat(..)、__eq(==)、__lt(<)、__le(<=)
		__metatable = {...}  --调用 getmetatable时返回该值，无则返回metatable(大多数情况)
		--5.2
		__gc = function(t) ... end  --析构函数. 在5.1可以local proxy = newproxy(true)   getmetatable(proxy).__gc = function(t) ... end
	}
	
]]
*table
table.insert(name,[index,]value)
table.remove(table,index=#table)	--> 返回被删除的元素值
table.maxn(table) --最大的数字index
table.concat(table,seq="",begin=1,end=#table)  --table全是字符串或数字， table[1]..seq..table[2]...seq...table[end]
table.pack(...) --> table，...放在了arg这个table里
table.unpack(table) --> table[1],..,table[#table]
table.sort(table,[function(a,b) return a<b end])
next(table,[index=initial index])  --> next_index,table[next_index]

rawget(table,index)  --get table.index. don't call any metatable 
rawset(table,index,value)
rawequal(a,b)
rawlen(table|string) --> return #table(number)、the length of string

setmetatable(table,metatable=nil) 
getmetatable(table)  -- nil or metatable or metatable.__metatable. 所以不一定是table or nil

getfenv(f)  --> table. f=function|number    num=1,call args.  num=0,global
setfenv(f,table)  --> f=function|number

pack(...) --> table
unpack(table) -->...
select(index,...) --> index=-1最后一个， or 第index个及以后的.	 print( select(1,1,2,3,4,5,6,7,8,9)) --return 1,..,9

*tostring(v)
*type(v) -- return string.  "number"、"string"、"table"、"userdata"、"boolean"、"function"、"nil"
*pairs/ipairs/
tonumber(v)


assert(bool,...) --> true return ..., false error
error(message,[level=1])  --终止最后一个protected function and return message
xpcall(f,msgh~=nil,...)  --safe mode call f. success: return true,f(...)  failure:false, msgh(error)
pcall(f,...) --safe mode call f. success:return true,f(...)  failure: return nil,errorstring
module(name[,...]) --name:string   package or global里叫name的table is a module. 及之后只能使用module里的成员

*require(modname) --在package.loaded里找，不见在 package.path里找	cpath里是dll等
load(ld:func|str[,source:string,mode:string,env:table]) --return function,errorstring; 
loadfile(filename[,mode:string[,env:table]])  --return function,errorstring; 
loadstring(filename[,chunkname]) --return function,errorstring;   assert(loadstring(string))() --safe ok
dofile(filnename)  -->...   not safe call. filename=nil then return the values of stdin

--newproxy、gcinfo
type_table: math、table、io、os、string、debug、arg(main函数参数)、jit(即使编译)、bit(位运算函数)、package(加载路径等)、_G
value: _VERSION   --饥荒是 Lua 5.1
_G：global table，以上都是for k,v in pairs(_G) do print(k,v) end