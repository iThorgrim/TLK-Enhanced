--------------------------------------------------------------------------------
--
--  ATLAS HELPER FOR WOTLK
--  Retail-like C_Texture Atlas API for WotLK 3.3.5a
--
--  Copyright (c) 2026 iThorgrim
--  https://github.com/iThorgrim
--
--------------------------------------------------------------------------------
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU Affero General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Affero General Public License for more details.
--
--  You should have received a copy of the GNU Affero General Public License
--  along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
--------------------------------------------------------------------------------
--
--  DESCRIPTION:
--    Provides a Retail WoW-compatible atlas system for WotLK 3.3.5a (build 12340).
--    Implements C_Texture. * API and SetAtlas() function for seamless atlas usage.
--
--  FEATURES:
--    • C_Texture.LoadAtlasData() - Load atlas coordinate data
--    • C_Texture. GetAtlasInfo()  - Retrieve atlas information
--    • SetAtlas()                - Apply atlas to texture objects
--    • Automatic SetTexture() hook for "atlas: name" syntax support
--
--  USAGE:
--    -- Load atlas data (typically done in AtlasInfo.lua)
--    C_Texture.LoadAtlasData(atlasTable)
--
--    -- Apply atlas to texture
--    SetAtlas(myTexture, "atlas-name", useAtlasSize)
--
--    -- Or use in XML
--    <Texture file="atlas: atlas-name" />
--
--  DEPENDENCIES:
--    • WotLK 3.3.5a (build 12340)
--    • AtlasInfo.lua (atlas coordinate data)
--
--  AUTHOR:
--    iThorgrim (https://github.com/iThorgrim)
--
--  VERSION:
--    1.0.0
--
--  DATE:
--    2026-01-14
--
--  REPOSITORY:
--    https://github.com/iThorgrim/WotLK-Atlas-System
--
--------------------------------------------------------------------------------

if not C_Texture then
    C_Texture = {};
end

local AtlasCache = {};

function C_Texture.LoadAtlasData(atlasInfo)
    if not atlasInfo then
        return 0;
    end

    local count = 0;

    for fileKey, atlasGroup in pairs(atlasInfo) do
        local texturePath;

        texturePath = fileKey;
        if texturePath then
            for atlasName, atlasData in pairs(atlasGroup) do
                local width = atlasData[1];
                local height = atlasData[2];
                local left = atlasData[3];
                local right = atlasData[4];
                local top = atlasData[5];
                local bottom = atlasData[6];

                local name = atlasName;
                AtlasCache[name] = {
                    width = width,
                    height = height,
                    left = left,
                    right = right,
                    top = top,
                    bottom = bottom,
                    file = texturePath
                };

                count = count + 1;
            end
        end
    end

    return count;
end

function C_Texture.GetAtlasInfo(atlasName)
    if not atlasName or atlasName == "" then
        return nil;
    end

    local name = atlasName;
    return AtlasCache[name];
end

function SetAtlas(texture, atlasName, useAtlasSize)
    if not texture or not atlasName or atlasName == "" then
        return false;
    end

    local info = C_Texture.GetAtlasInfo(atlasName);

    if not info or not info.file then
        return false;
    end

    local success = pcall(function()
        texture:SetTexture(info.file);
        texture:SetTexCoord(info.left, info. right, info.top, info.bottom);

        if useAtlasSize then
            texture:SetWidth(info.width);
            texture:SetHeight(info.height);
        end
    end);

    return success;
end

C_Texture.SetAtlas = SetAtlas;