--------------------------------------------------------------------------------
-- NineSlice.lua
--------------------------------------------------------------------------------

if not C_NineSlice then
	C_NineSlice = {}
end

--- Applies a NineSlice layout to a frame
-- @param frame Frame - The frame to apply the layout to
-- @param layoutName string - Name of the layout in NineSliceLayouts table
function C_NineSlice.ApplyLayout(frame, layoutName)
	if not frame or not layoutName then
		return
	end

	local layout = NineSliceLayouts[layoutName]
	if not layout then
		return
	end

	-- Get or create texture regions for each piece
	local pieces = {
		"TopLeftCorner",
		"TopRightCorner",
		"BottomLeftCorner",
		"BottomRightCorner",
		"TopEdge",
		"BottomEdge",
		"LeftEdge",
		"RightEdge",
		"Center"
	}

	for _, pieceName in pairs(pieces) do
		local pieceData = layout[pieceName]
		if pieceData then
			-- Get or create texture
			local textureName = frame:GetName() .. pieceName
			local texture = _G[textureName] or frame:CreateTexture(textureName, pieceData.layer or "BORDER", nil, pieceData.subLevel or 0)

			if pieceData.atlas then
				SetAtlas(texture, pieceData.atlas, true)
			end

			-- Apply position/anchoring based on piece type
			texture:ClearAllPoints()

			if pieceName == "TopLeftCorner" then
				texture:SetPoint("TOPLEFT", frame, "TOPLEFT", pieceData.x or 0, pieceData.y or 0)
			elseif pieceName == "TopRightCorner" then
				texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", pieceData.x or 0, pieceData.y or 0)
			elseif pieceName == "BottomLeftCorner" then
				texture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", pieceData.x or 0, pieceData.y or 0)
			elseif pieceName == "BottomRightCorner" then
				texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", pieceData.x or 0, pieceData.y or 0)
			elseif pieceName == "TopEdge" then
				local leftCornerTexture = _G[frame:GetName() .. "TopLeftCorner"]
				local rightCornerTexture = _G[frame:GetName() .. "TopRightCorner"]
				if leftCornerTexture and rightCornerTexture then
					texture:SetPoint("TOPLEFT", leftCornerTexture, "TOPRIGHT", pieceData.x or 0, pieceData.y or 0)
					texture:SetPoint("TOPRIGHT", rightCornerTexture, "TOPLEFT", pieceData.x1 or 0, pieceData.y1 or 0)
				end
			elseif pieceName == "BottomEdge" then
				local leftCornerTexture = _G[frame:GetName() .. "BottomLeftCorner"]
				local rightCornerTexture = _G[frame:GetName() .. "BottomRightCorner"]
				if leftCornerTexture and rightCornerTexture then
					texture:SetPoint("BOTTOMLEFT", leftCornerTexture, "BOTTOMRIGHT", pieceData.x or 0, pieceData.y or 0)
					texture:SetPoint("BOTTOMRIGHT", rightCornerTexture, "BOTTOMLEFT", pieceData.x1 or 0, pieceData.y1 or 0)
				end
			elseif pieceName == "LeftEdge" then
				local topCornerTexture = _G[frame:GetName() .. "TopLeftCorner"]
				local bottomCornerTexture = _G[frame:GetName() .. "BottomLeftCorner"]
				if topCornerTexture and bottomCornerTexture then
					texture:SetPoint("TOPLEFT", topCornerTexture, "BOTTOMLEFT", pieceData.x or 0, pieceData.y or 0)
					texture:SetPoint("BOTTOMLEFT", bottomCornerTexture, "TOPLEFT", pieceData.x1 or 0, pieceData.y1 or 0)
				end
			elseif pieceName == "RightEdge" then
				local topCornerTexture = _G[frame:GetName() .. "TopRightCorner"]
				local bottomCornerTexture = _G[frame:GetName() .. "BottomRightCorner"]
				if topCornerTexture and bottomCornerTexture then
					texture:SetPoint("TOPRIGHT", topCornerTexture, "BOTTOMRIGHT", pieceData.x or 0, pieceData.y or 0)
					texture:SetPoint("BOTTOMRIGHT", bottomCornerTexture, "TOPRIGHT", pieceData.x1 or 0, pieceData.y1 or 0)
				end
			elseif pieceName == "Center" then
				local topLeftTexture = _G[frame:GetName() .. "TopLeftCorner"]
				local bottomRightTexture = _G[frame:GetName() .. "BottomRightCorner"]
				if topLeftTexture and bottomRightTexture then
					texture:SetPoint("TOPLEFT", topLeftTexture, "BOTTOMRIGHT", pieceData.x or 0, pieceData.y or 0)
					texture:SetPoint("BOTTOMRIGHT", bottomRightTexture, "TOPLEFT", pieceData.x1 or 0, pieceData.y1 or 0)
				end
			end

			-- Store reference in frame
			if not frame.NineSlice then
				frame.NineSlice = {}
			end
			frame.NineSlice[pieceName] = texture
		end
	end
end

--- OnLoad handler for frames with layoutType attribute
function C_NineSlice.OnLoad(self)
	local layoutType = self:GetAttribute("layoutType")
	if layoutType then
		C_NineSlice.ApplyLayout(self, layoutType)
	end
end