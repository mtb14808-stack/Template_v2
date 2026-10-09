local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)
local GamePasses = require(ReplicatedStorage.SourceCode.Core.Configs.Monetization.GamePasses)
local Products = require(ReplicatedStorage.SourceCode.Core.Configs.Monetization.Products)
local Camera = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Camera)
local Vignette = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Vignette)

local CAMERA_ZOOM = 50
local CAMERA_NORMAL = 70
local VignetteSequence = {
	[1] = Color3.new(0.866666, 0.043137, 0.043137),
	[2] = Color3.new(0.956862, 0.909803, 0.066666),
	[3] = Color3.new(0.066666, 0.956862, 0.109803),
	[4] = Color3.new(0.066666, 0.866666, 0.956862),
	[5] = Color3.new(0.243137, 0.066666, 0.956862),
	[6] = Color3.new(0.792156, 0.066666, 0.956862),
}

local MonetizationClient = {}
MonetizationClient.IsPrompting = false

function MonetizationClient:Init()
	warn(
		"Quando Finisci Di Fare Esempio DI comprare un game pass o unriti al gruppo o rifuiti che si apre un menu tipo steal an egg "
	)
	self.ProductRequest = networker.client.new("Product_Request", self)
	self.BuyRequested = networker.client.new("Buy_Requested", self)
end

function MonetizationClient:CreateProductVignette()
	Vignette.ProductVignette(
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, VignetteSequence[1]),
			ColorSequenceKeypoint.new(0.2, VignetteSequence[2]),
			ColorSequenceKeypoint.new(0.4, VignetteSequence[3]),
			ColorSequenceKeypoint.new(0.6, VignetteSequence[4]),
			ColorSequenceKeypoint.new(0.8, VignetteSequence[5]),
			ColorSequenceKeypoint.new(1, VignetteSequence[6]),
		}),
		0.4,
		true,
		1.5
	)
end

function MonetizationClient:PromptGamePassRequest(Name: string)
	if self.IsPrompting then
		return
	end

	local Id = GamePasses[Name].Id
	if not Id then
		warn("Couldn't Find Product Id")
		return
	end

	self.IsPrompting = true
	self:CreateProductVignette()
	Camera.RunCameraFunction({
		FunctionName = "SetFov",
		GoalFov = 40,
	})
	self.BuyRequested:fire("HandleBuyRequest", Name)
end

function MonetizationClient:PromptProductRequest(Name: string)
	if self.IsPrompting then
		return
	end

	local Id = Products[Name].Id
	if not Id then
		warn("Couldn't Find Product Id")
		return
	end

	self.IsPrompting = true
	self:CreateProductVignette()
	Camera.RunCameraFunction({
		FunctionName = "SetFov",
		GoalFov = CAMERA_ZOOM,
	})
	self.ProductRequest:fire("HandleProductRequest", Id)
end

function MonetizationClient:RemoveVignette()
	self.IsPrompting = false
	if Vignette.IsProductVignetteSource() == true then
		Vignette.RemoveVignette()
		Camera.RunCameraFunction({
			FunctionName = "SetFov",
			GoalFov = CAMERA_NORMAL,
		})
	end
end

return MonetizationClient
