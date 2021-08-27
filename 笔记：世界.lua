--开启受虐模式，错误不再打印而是报错，更多栈堆信息！
EnableModError(bool=false)
modassert(test, message)
moderror(message)
assert() or error() --影响较小
--API
AddGameMode()
AddGamePostInit()
AddRoomPreInit(name,function(room) end)	--  AddRoomPreInit("Marsh", function(room) room.contents.distributeprefabs.berrybush = 0.1 end)
AddLevel and/or AddTaskSet    --添加世界初始化界面选项，Modworldgenmain.lua。 专服也可修改，看worldgenoverride.lua


--Custom game modes 自定义游戏模式
--This will cause PIGFEED to be the only available preset when the PigFeed game mode is selected.
modsettings.ini:
game_modes =
{
    {
        name = "pigfeed",
        label = "PigFeed",
        description = "Feed the pig king the most in each round to get points!",
        settings =
        {
            ghost_sanity_drain = false,
            portal_rez = true,
            level_type = "LEVELTYPE_PIGFEED", -- NEW!
        }
    }
}
--modmain  参考代码：Modworldgenmain.lua   专服： worldgenoverride.lua
AddLevel( "LEVELTYPE_PIGFEED", {
    id = "PIGFEED",
    name = "Pigfeed preset",
    desc = "Pigfeed preset description!",
    location = "forest",
    version = 2,
    overrides={
        flint = "often",
        grass = "often",
    },
})