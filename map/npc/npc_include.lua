--***************NPC加载头文件************************
require("npc.config.npc_loader")
require("npc.config.scene_loader")
require("npc.config.random_script_loader")
require("npc.config.action_loader")
require("npc.config.drill_loader")
require("npc.config.embed_loader")
require("config.loader.intensify_loader")
require("config.intensify_scale")
require("npc.config.merge_loader")
require("npc.config.strip_loader")
require("npc.config.tool_merge_loader")
require("npc.config.npc_exchange_loader")
require("npc.config.stone_polish_loader")
require("npc.config.reset_loader")
require("npc.config.reset_seal_loader")
require("npc.config.unlock_loader")
require("config.loader.formula_loader")
require("npc.config.faction_npc_loader")
require("npc.config.advanced_loader")
require("npc.npc_container_mgr")

require("npc.cmds.npc_process")
require("npc.cmds.equip_intensify")
require("npc.cmds.equip_drill")
require("npc.cmds.equip_reset")
require("npc.cmds.equip_unlock")
require("npc.cmds.equip_embed")
require("npc.cmds.equip_strip")
require("npc.cmds.equip_advanced")
require("npc.cmds.gem_merge")
require("npc.cmds.npc_exchange")
require("npc.cmds.stone_polish")
--require("npc.cmds.new_equip_operation")
require("config.activation_config")
--require("npc.genkey.activation_obj")
require("npc.genkey.npc_activation")

require("npc.daily_reward.daily_reward")
require("npc.daily_reward.daily_reward_mgr")

require("npc.random_script.random_script")
require("npc.random_script.random_script_mgr")
require("npc.cmds.random_script_process")

require("npc.dynamic.dynamic_include")

--雕像
require("npc.statue.statue")
require("npc.cmds.map_statue_process")

