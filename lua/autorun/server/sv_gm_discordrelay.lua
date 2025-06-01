-- This file is part of a project licensed under the MIT License.
-- See the LICENSE file in the root directory for full terms.


util.AddNetworkString("say_relay")


-- Message receiver.

local messageChunks = {}

concommand.Add( 'say_relay',function(ply,_,args)
	if IsValid(ply) then return end
	if not istable(args) then return end	
	
	-- This runs only for chunked messages.
	if #args > 2 then
		if args[1] == "0" then
			local requestsAmount = tonumber(args[2])
			local messageHash = args[3]
			local username = args[4]
			
			messageChunks[messageHash] = {
				["chunks"] = {},
				["username"] = username,
				["requestsAmount"] = requestsAmount
			}
			
			return
		else
			local requestID = tonumber(args[1])
			local messageHash = args[2]
			local chunk = args[3]
			
			messageChunks[messageHash].chunks[requestID] = chunk
			
			if #messageChunks[messageHash].chunks >= messageChunks[messageHash].requestsAmount then
				args[1] = messageChunks[messageHash].username
				args[2] = ""
				for _,v in pairs(messageChunks[messageHash].chunks) do
					args[2] = args[2]..v
				end
				
				messageChunks[messageHash] = nil
			else
				return
			end	
		end
	end
	
	local username = util.Base64Decode(args[1])
	local message = util.Base64Decode(args[2])
	
	if (string.len(message) > 1000) then
		local compressed_message = util.Compress(message)
		net.Start("say_relay")
			net.WriteBool(true)
			net.WriteString(username)
			net.WriteUInt(#compressed_message,16)
			net.WriteData(compressed_message,#compressed_message)
		net.Broadcast()
		return
	end
	
	net.Start("say_relay")
		net.WriteBool(false)
		net.WriteString(username)
		net.WriteString(message)
	net.Broadcast()
end)


-- Function for sending your own messages to the relay in Lua.

function SendRelayMessage(displayname,message)
	if not displayname or string.len(displayname) == 0 then
		displayname = "NoUsername"
	end
	if not message or string.len(message) == 0 then
		message = "NoMessage"
	end
	local usernameb64 = util.Base64Encode(displayname)
	local messageb64 = util.Base64Encode(message)
	
	ServerLog("<CustomRelayMessage><"..usernameb64.."><"..messageb64.."> ")
end