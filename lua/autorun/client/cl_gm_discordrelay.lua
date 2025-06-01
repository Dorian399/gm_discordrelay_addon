-- This file is part of a project licensed under the MIT License.
-- See the LICENSE file in the root directory for full terms.

local prefix = "*RELAY* "
local prefix_color = Color(255,0,0) -- red
local username_color = Color(100,100,100) -- grey
local message_color = Color(255,255,255) -- white

net.Receive("say_relay",function()
	local isCompressed = net.ReadBool()
	local username = net.ReadString()
	local message = ""
	if not isCompressed then
		message = net.ReadString()
	else
		local size = net.ReadUInt(16)
		local compressed_message = net.ReadData(size)
		message = util.Decompress(compressed_message)
	end
	if isstring(username) and isstring(message) then
		chat.AddText(prefix_color,prefix,username_color,username,message_color,": "..message)
	end
end)
