SellingLocations = {
	["PawnShop"] = {
        label = "Pawn Shop",
		model = {
			"mp_m_shopkeep_01",
			"S_F_Y_Shop_LOW",
			"S_F_Y_SweatShop_01",
		},
        coords = {
			vec4(410.32, 313.2, 103.02, 207.05),
			--vec4(0.0, 0.0, 0.0, 0.0),
		},
        products = SellingProducts["pawnshop"],
        blipsprite = 431,
		blipcolour = 5,
    },

    ["casinoSell"] = {
		label = "Diamond Casino",
		targetLabel = "Trade Chips",
		targetIcon = "fab fa-galactic-republic",
		model = {
			"S_M_Y_CASINO_01",
		},
        coords = {
			vec4(950.37, 34.72, 71.87, 33.82),
		},
        products = SellingProducts["casinoSell"],
        blipsprite = 617,
		blipcolour = 0,
    },
}