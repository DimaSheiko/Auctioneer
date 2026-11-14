--[[
	Auctioneer - Stat-MinBuyout module

	Prices an item at the lowest buyout per item among the auctions in the
	last scan, so Appraiser, Enchantrix and the other pricing model lists
	can follow the cheapest current listing.
--]]
if not AucAdvanced then return end

local lib = AucAdvanced.NewModule("Stat", "MinBuyout")
if not lib then return end

local const = AucAdvanced.Const
local query = {}
local array = {}

-- No GetItemPDF on purpose: the cheapest listing must not drag down the combined Market Price
function lib.GetPrice(hyperlink, serverKey)
	local linkType, itemId, suffix, factor = AucAdvanced.DecodeLink(hyperlink)
	if linkType ~= "item" then return end
	query.itemId, query.suffix, query.factor = itemId, suffix, factor

	local lowest, seen = nil, 0
	for _, auction in ipairs(AucAdvanced.API.QueryImage(query, serverKey)) do
		local buyout, count = auction[const.BUYOUT], auction[const.COUNT] or 1
		if buyout and buyout > 0 then
			local each = buyout / count
			if not lowest or each < lowest then lowest = each end
			seen = seen + count
		end
	end
	return lowest, seen
end

function lib.GetPriceArray(hyperlink, serverKey)
	array.price, array.seen = lib.GetPrice(hyperlink, serverKey)
	return array
end
