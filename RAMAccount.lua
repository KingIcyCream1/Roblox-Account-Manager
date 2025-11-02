local Account = {}
Account.__index = Account

local WebserverSettings = { Port = "7963", Password = "" }

function WebserverSettings:SetPort(port)
	self.Port = tostring(port)
end

function WebserverSettings:SetPassword(password)
	self.Password = password or ""
end

local HttpService = game:GetService("HttpService")
local Request = (syn and syn.request) or request or (http and http.request) or http_request

local function encode(str)
	return HttpService:UrlEncode(tostring(str))
end

local function buildUrl(method, account, args)
	local url = string.format("http://localhost:%s/%s?Account=%s", WebserverSettings.Port, method, account)
	for _, arg in ipairs(args) do
		if typeof(arg) ~= "boolean" then
			url ..= "&" .. arg
		end
	end
	if #WebserverSettings.Password >= 6 then
		url ..= "&Password=" .. encode(WebserverSettings.Password)
	end
	return url
end

local function GET(method, account, ...)
	local url = buildUrl(method, account, { ... })
	local response = Request({ Method = "GET", Url = url })
	if not response or response.StatusCode ~= 200 then return false end
	return response.Body
end

local function POST(method, account, body, ...)
	local url = buildUrl(method, account, { ... })
	local response = Request({ Method = "POST", Url = url, Body = body })
	if not response or response.StatusCode ~= 200 then return false end
	return response.Body
end

function Account.new(username, skipValidation)
	local self = setmetatable({}, Account)
	local valid = skipValidation or GET("GetCSRFToken", username)
	if not valid or valid == "Invalid Account" then return false end
	self.Username = username
	return self
end

function Account:GetCSRFToken()
	return GET("GetCSRFToken", self.Username)
end

function Account:BlockUser(arg)
	if typeof(arg) == "Instance" and arg:IsA("Player") then
		return self:BlockUser(arg.UserId)
	elseif typeof(arg) == "number" then
		arg = tostring(arg)
	end
	if typeof(arg) == "string" then
		return GET("BlockUser", self.Username, "UserId=" .. arg)
	end
end

function Account:UnblockUser(arg)
	if typeof(arg) == "Instance" and arg:IsA("Player") then
		return self:UnblockUser(arg.UserId)
	elseif typeof(arg) == "number" then
		arg = tostring(arg)
	end
	if typeof(arg) == "string" then
		return GET("UnblockUser", self.Username, "UserId=" .. arg)
	end
end

function Account:GetBlockedList()
	return GET("GetBlockedList", self.Username)
end

function Account:UnblockEveryone()
	return GET("UnblockEveryone", self.Username)
end

function Account:GetAlias()
	return GET("GetAlias", self.Username)
end

function Account:GetDescription()
	return GET("GetDescription", self.Username)
end

function Account:SetAlias(alias)
	return POST("SetAlias", self.Username, alias)
end

function Account:SetDescription(desc)
	return POST("SetDescription", self.Username, desc)
end

function Account:AppendDescription(desc)
	return POST("AppendDescription", self.Username, desc)
end

function Account:GetField(field)
	return GET("GetField", self.Username, "Field=" .. encode(field))
end

function Account:SetField(field, value)
	return GET("SetField", self.Username, "Field=" .. encode(field), "Value=" .. encode(value))
end

function Account:RemoveField(field)
	return GET("RemoveField", self.Username, "Field=" .. encode(field))
end

function Account:SetServer(placeId, jobId)
	return GET("SetServer", self.Username, "PlaceId=" .. placeId, "JobId=" .. (jobId or ""))
end

function Account:SetRecommendedServer(placeId)
	return GET("SetServer", self.Username, "PlaceId=" .. placeId)
end

function Account:ImportCookie(token)
	return GET("ImportCookie", "Cookie=" .. encode(token))
end

function Account:GetCookie()
	return GET("GetCookie", self.Username)
end

function Account:LaunchAccount(placeId, jobId, followUser, joinVip)
	return GET("LaunchAccount", self.Username,
		"PlaceId=" .. placeId,
		jobId and ("JobId=" .. jobId),
		followUser and "FollowUser=true",
		joinVip and "JoinVIP=true"
	)
end

return Account, WebserverSettings
