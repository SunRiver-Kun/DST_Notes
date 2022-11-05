--[]表示里面的内容可省略
--modmain环境
env{
	GLOBAL
	_G
	env
	Class	
	TUNING	
	KEYS	
	Prefab	
	各种Add
	...  -- main环境
	modname = "mod的名字"
	modinfo	
	MODROOT	= "../mods/modname/"
	modassert	
	moderror	
	mod的global变量
	CHARACTERLIST	
	modimport	
	print、type、table、math、pairs、ipairs、string
}
--无法直接调用  env ThePlayer/assert/io/os/coroutine/debug/metatable等
--*把表示有
--ThePlayer不会出现在客户端

modimport("scripts/sollyz_skill.lua") 	--直接插入代码，和require的调用不同

PrefabFiles = {		--scripts/prefabs里面的代码文件
	"",
	"",
}

Assets = {		--预加载资源
		Asset("代称","文件夹/[文件夹/]文件")
--IMAGE -> tex	//  ATLAS -> xml // SCRIPT -> lua // ANIM -> zip(只有anim也可)		
--PKGREF 通用文件(build,atlas)，其他类型见global.lua
}

local require = GLOBAL.require		--记载官方代码才要加GLOBAL
local STRINGS = GLOBAL.STRINGS		--strings字符串

GetModConfigData("name")	--返回modinfo里面的data，

--选人界面
STRINGS.CHARACTER_TITLES.人物标记 = "人物标题"
STRINGS.CHARACTER_NAMES.人物标记 = "人物名字"
STRINGS.CHARACTER_DESCRIPTIONS.人物标记 = "人物特性\n"
STRINGS.CHARACTER_QUOTES.人物标记 = "\"人物名言\""
STRINGS.CHARACTERS.人物标记 = require "speech_人物标记"		--说话的内容

--人物在游戏中的名字
STRINGS.NAMES.人物标记 = "人物名字"

AddMinimapAtlas("images/map_icons/人物标记.xml")	--小地图标志

AddModCharacter("人物标记", "FEMALE")		--加入为人物mod，和标签

------------------------------------------------------其他
--变量

--常量
FRAMES