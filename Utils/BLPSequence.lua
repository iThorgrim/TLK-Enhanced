--------------------------------------------------------------------------------
-- BLPSequence.lua
--------------------------------------------------------------------------------

local BLPSequence = {};
local sequences = {};
local activeSequences = {};

-- Create a new BLP sequence
-- @param name: Unique identifier for this sequence
-- @param basePath: Path to BLP files (without number, e.g., "Interface\\LoginScreen\\frame_")
-- @param frameCount: Total number of frames (not BLP files)
-- @param fps: Frames per second
-- @param loop: Whether to loop the sequence
-- @param atlasLayout: Optional, table {filesPerFrame = 2, layout = "horizontal"} for atlas textures
function BLPSequence:Create(name, basePath, frameCount, fps, loop, atlasLayout)
	sequences[name] = {
		basePath = basePath,
		frameCount = frameCount,
		fps = fps,
		loop = loop or false,
		frameDuration = 1 / fps,

		-- Atlas support
		atlasLayout = atlasLayout or {filesPerFrame = 2, layout = "horizontal"},
		framesPerFile = atlasLayout and atlasLayout.filesPerFrame or 1,

		-- Precompute BLP count
		blpCount = atlasLayout and math.ceil(frameCount / (atlasLayout.filesPerFrame or 1)) or frameCount,
	};
	return true;
end

-- Play a sequence on a texture
-- @param name: Sequence name
-- @param textureName: Name of the texture object (string or table)
function BLPSequence:Play(name, textureName)
	local seq = sequences[name];
	if not seq then return false; end

	local texture = type(textureName) == "string" and _G[textureName] or textureName;
	if not texture then return false; end

	activeSequences[name] = {
		currentFrame = 1,
		elapsed = 0,
		texture = texture,
		sequence = seq,
		playing = true,

		-- Cache
		lastBlpIndex = -1,
		lastTexturePath = nil,
	};

	self:UpdateFrame(name);
	return true;
end

-- Stop a sequence
function BLPSequence:Stop(name)
	if activeSequences[name] then
		activeSequences[name].playing = false;
	end
end

-- Pause a sequence
function BLPSequence:Pause(name)
	if activeSequences[name] then
		activeSequences[name].playing = false;
	end
end

-- Resume a sequence
function BLPSequence:Resume(name)
	if activeSequences[name] then
		activeSequences[name].playing = true;
	end
end

-- Set specific frame
function BLPSequence:SetFrame(name, frameNum)
	local active = activeSequences[name];
	if not active then return false; end

	active.currentFrame = math.max(1, math.min(frameNum, active.sequence.frameCount));
	active.elapsed = 0;
	self:UpdateFrame(name);
	return true;
end

-- Update frame texture and TexCoords
function BLPSequence:UpdateFrame(name)
	local active = activeSequences[name];
	if not active then return; end

	local seq = active.sequence;
	local texture = active.texture;
	local currentFrame = active.currentFrame;

	-- Calculate which BLP file to use
	local blpIndex = math.ceil(currentFrame / seq.framesPerFile);

	if blpIndex ~= active.lastBlpIndex then
		local texturePath = string.format("%s%06d", seq.basePath, blpIndex);
		texture:SetTexture(texturePath);
		active.lastBlpIndex = blpIndex;
		active.lastTexturePath = texturePath;
	end

	-- Calculate TexCoords for atlas texture
	if seq.atlasLayout then
		local frameInFile = ((currentFrame - 1) % seq.framesPerFile) + 1;
		local layout = seq.atlasLayout.layout or "horizontal";

		if layout == "horizontal" then
			-- Frames arranged left to right
			local segmentWidth = 1.0 / seq.framesPerFile;
			local left = (frameInFile - 1) * segmentWidth;
			local right = frameInFile * segmentWidth;

			local parent = texture:GetParent();
			if parent then
				local screenRatio = parent:GetWidth() / parent:GetHeight();
				local imageRatio = 1.0;
				local cropAmount = (1.0 - (imageRatio / screenRatio)) / 2;
				texture:SetTexCoord(left, right, cropAmount, 1 - cropAmount);
			else
				texture:SetTexCoord(left, right, 0, 1);
			end
		elseif layout == "vertical" then
			-- Frames arranged top to bottom
			local segmentHeight = 1.0 / seq.framesPerFile;
			local top = (frameInFile - 1) * segmentHeight;
			local bottom = frameInFile * segmentHeight;
			texture:SetTexCoord(0, 1, top, bottom);
		elseif layout == "grid" then
			-- Frames in 2D grid
			local cols = seq.atlasLayout.columns or 2;
			local rows = math.ceil(seq.framesPerFile / cols);
			local col = ((frameInFile - 1) % cols) + 1;
			local row = math.ceil(frameInFile / cols);

			local segmentWidth = 1.0 / cols;
			local segmentHeight = 1.0 / rows;
			local left = (col - 1) * segmentWidth;
			local right = col * segmentWidth;
			local top = (row - 1) * segmentHeight;
			local bottom = row * segmentHeight;

			texture:SetTexCoord(left, right, top, bottom);
		end
	else
		texture:SetTexCoord(0, 1, 0, 1);
	end
end

-- Update all active sequences (call from OnUpdate)
function BLPSequence:Update(elapsed)
	for name, active in pairs(activeSequences) do
		if active.playing then
			active.elapsed = active.elapsed + elapsed;

			while active.elapsed >= active.sequence.frameDuration do
				active.elapsed = active.elapsed - active.sequence.frameDuration;
				active.currentFrame = active.currentFrame + 1;

				if active.currentFrame > active.sequence.frameCount then
					if active.sequence.loop then
						active.currentFrame = 1;
					else
						active.currentFrame = active.sequence.frameCount;
						active.playing = false;
						break;
					end
				end

				self:UpdateFrame(name);
			end
		end
	end
end

-- Get sequence info
function BLPSequence:GetInfo(name)
	local seq = sequences[name];
	if not seq then return nil; end

	local active = activeSequences[name];
	return {
		frameCount = seq.frameCount,
		fps = seq.fps,
		loop = seq.loop,
		blpCount = seq.blpCount,
		currentFrame = active and active.currentFrame or 0,
		isPlaying = active and active.playing or false,
	};
end

-- Cleanup
function BLPSequence:Destroy(name)
	sequences[name] = nil;
	activeSequences[name] = nil;
	BLPSequence:Stop(name);
end

-- Global update function (attach to frame's OnUpdate)
local updateFrame = CreateFrame("Frame");
updateFrame:SetScript("OnUpdate", function(self, elapsed)
	BLPSequence:Update(elapsed);
end);

-- Export to global scope
_G["BLPSequence"] = BLPSequence;