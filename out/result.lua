-- Compiled with roblox-ts v2.3.0
local TS = _G[script]
local _option = TS.import(script, script.Parent, "option")
local None = _option.None
local Some = _option.Some
local toString = TS.import(script, script.Parent, "utils").toString
--[[
	
	 * Missing Rust Result type methods:
	 * pub fn contains<U>(&self, x: &U) -> bool
	 * pub fn contains_err<F>(&self, f: &F) -> bool
	 * pub fn map_or<U, F>(self, default: U, f: F) -> U
	 * pub fn map_or_else<U, D, F>(self, default: D, f: F) -> U
	 * pub fn and<U>(self, res: Result<U, E>) -> Result<U, E>
	 * pub fn or<F>(self, res: Result<T, F>) -> Result<T, F>
	 * pub fn or_else<F, O>(self, op: O) -> Result<T, F>
	 * pub fn unwrap_or_else<F>(self, op: F) -> T
	 * pub fn expect_err(self, msg: &str) -> E
	 * pub fn unwrap_err(self) -> E
	 * pub fn unwrap_or_default(self) -> T
	 
]]
--[[
	*
	 * Contains the error value
	 
]]
local Err
local ErrImpl
do
	ErrImpl = setmetatable({}, {
		__tostring = function()
			return "ErrImpl"
		end,
	})
	ErrImpl.__index = ErrImpl
	function ErrImpl.new(...)
		local self = setmetatable({}, ErrImpl)
		return self:constructor(...) or self
	end
	function ErrImpl:constructor(val)
		if not (TS.instanceof(self, ErrImpl)) then
			return ErrImpl.new(val)
		end
		self.ok = false
		self.err = true
		self.val = val
		self._stack = debug.traceback()
	end
	ErrImpl["else"] = function(self, val)
		return val
	end
	function ErrImpl:unwrapOr(val)
		return val
	end
	function ErrImpl:expect(msg)
		error(`{msg} - Error: {toString(self.val)}\n{self._stack}`)
	end
	function ErrImpl:expectErr(_msg)
		return self.val
	end
	function ErrImpl:unwrap()
		error(`Tried to unwrap Error: {toString(self.val)}\n{self._stack}`)
	end
	function ErrImpl:map(_mapper)
		return self
	end
	function ErrImpl:andThen(op)
		return self
	end
	function ErrImpl:mapErr(mapper)
		return Err.new(mapper(self.val))
	end
	function ErrImpl:toOptional()
		return nil
	end
	function ErrImpl:toOption()
		return None
	end
	function ErrImpl:toString()
		return `Err({toString(self.val)})`
	end
	function ErrImpl:__tostring()
		return self:toString()
	end
	ErrImpl.EMPTY = ErrImpl.new(nil)
end
-- This allows Err to be callable - possible because of the es5 compilation target
Err = ErrImpl
--[[
	*
	 * Contains the success value
	 
]]
local Ok
local OkImpl
do
	OkImpl = setmetatable({}, {
		__tostring = function()
			return "OkImpl"
		end,
	})
	OkImpl.__index = OkImpl
	function OkImpl.new(...)
		local self = setmetatable({}, OkImpl)
		return self:constructor(...) or self
	end
	function OkImpl:constructor(val)
		if not (TS.instanceof(self, OkImpl)) then
			return OkImpl.new(val)
		end
		self.ok = true
		self.err = false
		self.val = val
	end
	OkImpl["else"] = function(self, _val)
		return self.val
	end
	function OkImpl:unwrapOr(_val)
		return self.val
	end
	function OkImpl:expect(_msg)
		return self.val
	end
	function OkImpl:expectErr(msg)
		error(msg)
	end
	function OkImpl:unwrap()
		return self.val
	end
	function OkImpl:map(mapper)
		return Ok.new(mapper(self.val))
	end
	function OkImpl:andThen(mapper)
		return mapper(self.val)
	end
	function OkImpl:mapErr(_mapper)
		return self
	end
	function OkImpl:toOptional()
		return self.val
	end
	function OkImpl:toOption()
		return Some(self.val)
	end
	function OkImpl:safeUnwrap()
		return self.val
	end
	function OkImpl:toString()
		return `Ok({toString(self.val)})`
	end
	function OkImpl:__tostring()
		return self:toString()
	end
	OkImpl.EMPTY = OkImpl.new(nil)
end
-- This allows Ok to be callable - possible because of the es5 compilation target
Ok = OkImpl
local Result = {}
do
	local _container = Result
	--[[
		*
			 * Parse a set of `Result`s, returning an array of all `Ok` values.
			 * Short circuits with the first `Err` found, if any
			 
	]]
	local function all(...)
		local results = { ... }
		local okResult = {}
		for _, result in results do
			if result.ok then
				local _val = result.val
				table.insert(okResult, _val)
			else
				return result
			end
		end
		return Ok.new(okResult)
	end
	_container.all = all
	--[[
		*
			 * Parse a set of `Result`s, short-circuits when an input value is `Ok`.
			 * If no `Ok` is found, returns an `Err` containing the collected error values
			 
	]]
	local function any(...)
		local results = { ... }
		local errResult = {}
		-- short-circuits
		for _, result in results do
			if result.ok then
				return result
			else
				local _val = result.val
				table.insert(errResult, _val)
			end
		end
		-- it must be a Err
		return Err.new(errResult)
	end
	_container.any = any
	--[[
		*
			 * Wrap an operation that may throw an Error (`try-catch` style) into checked exception style
			 * @param op The operation function
			 
	]]
	local function wrap(op)
		local _exitType, _returns = TS.try(function()
			return TS.TRY_RETURN, { Ok.new(op()) }
		end, function(e)
			return TS.TRY_RETURN, { Err.new(e) }
		end)
		if _exitType then
			return unpack(_returns)
		end
	end
	_container.wrap = wrap
	--[[
		*
			 * Wrap an async operation that may throw an Error (`try-catch` style) into checked exception style
			 * @param op The operation function
			 
	]]
	local function wrapAsync(op)
		local _exitType, _returns = TS.try(function()
			return TS.TRY_RETURN, { op():andThen(function(val)
				return Ok.new(val)
			end):catch(function(e)
				return Err.new(e)
			end) }
		end, function(e)
			return TS.TRY_RETURN, { TS.Promise.resolve(Err.new(e)) }
		end)
		if _exitType then
			return unpack(_returns)
		end
	end
	_container.wrapAsync = wrapAsync
	local function isResult(val)
		return TS.instanceof(val, Err) or TS.instanceof(val, Ok)
	end
	_container.isResult = isResult
end
return {
	ErrImpl = ErrImpl,
	Err = Err,
	OkImpl = OkImpl,
	Ok = Ok,
	Result = Result,
}
