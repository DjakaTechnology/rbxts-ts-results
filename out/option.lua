-- Compiled with roblox-ts v2.3.0
local TS = _G[script]
local toString = TS.import(script, script.Parent, "utils").toString
local _result = TS.import(script, script.Parent, "result")
local Ok = _result.Ok
local Err = _result.Err
--[[
	*
	 * Contains the None value
	 
]]
local NoneImpl
do
	NoneImpl = setmetatable({}, {
		__tostring = function()
			return "NoneImpl"
		end,
	})
	NoneImpl.__index = NoneImpl
	function NoneImpl.new(...)
		local self = setmetatable({}, NoneImpl)
		return self:constructor(...) or self
	end
	function NoneImpl:constructor()
		self.some = false
		self.none = true
	end
	function NoneImpl:unwrapOr(val)
		return val
	end
	function NoneImpl:expect(msg)
		error(`{msg}`)
	end
	function NoneImpl:unwrap()
		error(`Tried to unwrap None`)
	end
	function NoneImpl:map(_mapper)
		return self
	end
	function NoneImpl:andThen(op)
		return self
	end
	function NoneImpl:toResult(err)
		return Err(err)
	end
	function NoneImpl:toString()
		return "None"
	end
	function NoneImpl:__tostring()
		return self:toString()
	end
end
-- Export None as a singleton
local None = NoneImpl.new()
--[[
	*
	 * Contains the success value
	 
]]
local Some
local SomeImpl
do
	SomeImpl = setmetatable({}, {
		__tostring = function()
			return "SomeImpl"
		end,
	})
	SomeImpl.__index = SomeImpl
	function SomeImpl.new(...)
		local self = setmetatable({}, SomeImpl)
		return self:constructor(...) or self
	end
	function SomeImpl:constructor(val)
		if not (TS.instanceof(self, SomeImpl)) then
			return SomeImpl.new(val)
		end
		self.some = true
		self.none = false
		self.val = val
	end
	function SomeImpl:unwrapOr(_val)
		return self.val
	end
	function SomeImpl:expect(_msg)
		return self.val
	end
	function SomeImpl:unwrap()
		return self.val
	end
	function SomeImpl:map(mapper)
		return Some(mapper(self.val))
	end
	function SomeImpl:andThen(mapper)
		return mapper(self.val)
	end
	function SomeImpl:toResult(_err)
		return Ok(self.val)
	end
	function SomeImpl:safeUnwrap()
		return self.val
	end
	function SomeImpl:toString()
		return `Some({toString(self.val)})`
	end
	function SomeImpl:__tostring()
		return self:toString()
	end
	SomeImpl.EMPTY = SomeImpl.new(nil)
end
-- This allows Some to be callable - possible because of the es5 compilation target
Some = SomeImpl
local Option = {}
do
	local _container = Option
	--[[
		*
		     * Parse a set of `Option`s, returning an array of all `Some` values.
		     * Short circuits with the first `None` found, if any
		     
	]]
	local function all(...)
		local options = { ... }
		local someOption = {}
		for _, option in options do
			if option.some then
				local _val = option.val
				table.insert(someOption, _val)
			else
				return option
			end
		end
		return Some(someOption)
	end
	_container.all = all
	--[[
		*
		     * Parse a set of `Option`s, short-circuits when an input value is `Some`.
		     * If no `Some` is found, returns `None`.
		     
	]]
	local function any(...)
		local options = { ... }
		-- short-circuits
		for _, option in options do
			if option.some then
				return option
			else
				return option
			end
		end
		-- it must be None
		return None
	end
	_container.any = any
	local function isOption(value)
		return TS.instanceof(value, Some) or value == None
	end
	_container.isOption = isOption
end
return {
	None = None,
	Some = Some,
	Option = Option,
}
