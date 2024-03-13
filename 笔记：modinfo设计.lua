name = " 猫妹子"
description = [[
喜欢吃鱼的萌妹子
吃鱼升级，自带钓鱼竿
早上的时候跑的快]]
author = "Haruz"
version = "1.10"
forumthread = ""   --可以填mod的来源网站，也可忽略
api_version = 10	--显示版本，更新它
priority = 0

dst_compatible = true		--联机版兼容
dont_starve_compatible = false	--单机版兼容
reign_of_giants_compatible = false	--与伟大的时期兼容？
all_clients_require_mod = true	--开服后进入者必须有此mod（大部分都是开的）
--client_only_mod = true

icon_atlas = "modicon.xml"	--图标的相对位置，一般不动
icon = "modicon.tex"	--128x128的mod图标
------------------------------------------------------------------------------------客户端（客机）与服务端（主机）
all_clients_require_mod = true	--所有客机都需要该mod
client_only_mod = false 		--只有客户端有这mod是否运行
server_only_mod = true		--只有服务端有这mod是否运行
--------------------------------------------------------------------------------------------------------------------------设置
configuration_options=
{
--[[name是配合GetModConfigData("name")来用得到数据的;label是设置里显示的名字；hover，设置里鼠标预览时的文字]]
	{
		name = "MinWaitTime",
		label = "最小等待时间",
		--hover = "Minimum time to wait before you hook a fish.",
		options =		{
				{description = "0 秒", data = 0--[[,hover=""]]},
					},
		default = 2,
	},
	{
和上面一样的表
	},
}


--[[  包含的东西
包含
for、#tb、function、str..num、可以共用一个options表（自动拷贝）

不包含
pairs/ipairs
table.xxx
tostring
]]
mod_dependencies = {	--priority大的先运行！
    {	
        workshop = "workshop-XXXXXXXXX",	--依赖workshop的mod
        ["FolderName"] = false,	--依赖mods/FolderName
        ["ModName"] = true,		--依赖name=Modname的mod
    },
}
