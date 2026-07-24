-- AllStats_vDnD - Ascension 3.3.5
-- Lokale Referenzen für Performance (vermeidet globale Lookups pro Aufruf)
local hooksecurefunc          = hooksecurefunc
local PaperDollFrame_SetStat            = PaperDollFrame_SetStat
local PaperDollFrame_SetDamage          = PaperDollFrame_SetDamage
local PaperDollFrame_SetAttackSpeed     = PaperDollFrame_SetAttackSpeed
local PaperDollFrame_SetAttackPower     = PaperDollFrame_SetAttackPower
local PaperDollFrame_SetRating          = PaperDollFrame_SetRating
local PaperDollFrame_SetMeleeCritChance = PaperDollFrame_SetMeleeCritChance
local PaperDollFrame_SetExpertise       = PaperDollFrame_SetExpertise
local PaperDollFrame_SetRangedDamage    = PaperDollFrame_SetRangedDamage
local PaperDollFrame_SetRangedAttackSpeed = PaperDollFrame_SetRangedAttackSpeed
local PaperDollFrame_SetRangedAttackPower = PaperDollFrame_SetRangedAttackPower
local PaperDollFrame_SetRangedCritChance  = PaperDollFrame_SetRangedCritChance
local PaperDollFrame_SetSpellBonusDamage  = PaperDollFrame_SetSpellBonusDamage
local PaperDollFrame_SetSpellBonusHealing = PaperDollFrame_SetSpellBonusHealing
local PaperDollFrame_SetSpellCritChance   = PaperDollFrame_SetSpellCritChance
local PaperDollFrame_SetSpellHaste        = PaperDollFrame_SetSpellHaste
local PaperDollFrame_SetManaRegen         = PaperDollFrame_SetManaRegen
local PaperDollFrame_SetArmor             = PaperDollFrame_SetArmor
local PaperDollFrame_SetDefense           = PaperDollFrame_SetDefense
local PaperDollFrame_SetDodge             = PaperDollFrame_SetDodge
local PaperDollFrame_SetParry             = PaperDollFrame_SetParry
local PaperDollFrame_SetBlock             = PaperDollFrame_SetBlock
local PaperDollFrame_SetResilience        = PaperDollFrame_SetResilience

local CR_HIT_MELEE  = CR_HIT_MELEE
local CR_HIT_RANGED = CR_HIT_RANGED
local CR_HIT_SPELL  = CR_HIT_SPELL

-- Frame-Referenzen werden einmalig aufgelöst statt bei jedem UpdateStats-Call
local frames

local function InitFrames()
	frames = {
		str = AllStatsFrameStat1, agi = AllStatsFrameStat2, sta = AllStatsFrameStat3,
		int = AllStatsFrameStat4, spi = AllStatsFrameStat5,

		md = AllStatsFrameStatMeleeDamage, ms = AllStatsFrameStatMeleeSpeed,
		mp = AllStatsFrameStatMeleePower,  mh = AllStatsFrameStatMeleeHit,
		mc = AllStatsFrameStatMeleeCrit,   me = AllStatsFrameStatMeleeExpert,

		rd = AllStatsFrameStatRangeDamage, rs = AllStatsFrameStatRangeSpeed,
		rp = AllStatsFrameStatRangePower,  rh = AllStatsFrameStatRangeHit,
		rc = AllStatsFrameStatRangeCrit,

		sd = AllStatsFrameStatSpellDamage, she = AllStatsFrameStatSpellHeal,
		shi = AllStatsFrameStatSpellHit,   sc = AllStatsFrameStatSpellCrit,
		sha = AllStatsFrameStatSpellHaste, sr = AllStatsFrameStatSpellRegen,

		armor = AllStatsFrameStatArmor, def = AllStatsFrameStatDefense,
		dodge = AllStatsFrameStatDodge, parry = AllStatsFrameStatParry,
		block = AllStatsFrameStatBlock, res = AllStatsFrameStatResil,
	}

	frames.md:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
	frames.rd:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
	frames.sd:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
	frames.sc:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
end

function PrintStats()
	if AscensionCharacterStatsPanel:GetUnit() ~= "player" then
		return
	end

	if not frames then
		InitFrames()
	end
	local f = frames

	PaperDollFrame_SetStat(f.str, 1)
	PaperDollFrame_SetStat(f.agi, 2)
	PaperDollFrame_SetStat(f.sta, 3)
	PaperDollFrame_SetStat(f.int, 4)
	PaperDollFrame_SetStat(f.spi, 5)

	PaperDollFrame_SetDamage(f.md)
	PaperDollFrame_SetAttackSpeed(f.ms)
	PaperDollFrame_SetAttackPower(f.mp)
	PaperDollFrame_SetRating(f.mh, CR_HIT_MELEE)
	PaperDollFrame_SetMeleeCritChance(f.mc)
	PaperDollFrame_SetExpertise(f.me)

	PaperDollFrame_SetRangedDamage(f.rd)
	PaperDollFrame_SetRangedAttackSpeed(f.rs)
	PaperDollFrame_SetRangedAttackPower(f.rp)
	PaperDollFrame_SetRating(f.rh, CR_HIT_RANGED)
	PaperDollFrame_SetRangedCritChance(f.rc)

	PaperDollFrame_SetSpellBonusDamage(f.sd)
	PaperDollFrame_SetSpellBonusHealing(f.she)
	PaperDollFrame_SetRating(f.shi, CR_HIT_SPELL)
	PaperDollFrame_SetSpellCritChance(f.sc)
	PaperDollFrame_SetSpellHaste(f.sha)
	PaperDollFrame_SetManaRegen(f.sr)

	PaperDollFrame_SetArmor(f.armor)
	PaperDollFrame_SetDefense(f.def)
	PaperDollFrame_SetDodge(f.dodge)
	PaperDollFrame_SetParry(f.parry)
	PaperDollFrame_SetBlock(f.block)
	PaperDollFrame_SetResilience(f.res)
end

function AllStats_OnLoad()
	hooksecurefunc(AscensionCharacterStatsPanel, "UpdateStats", PrintStats)
end

local AllStatsShowFrame = true

function AllStatsButtonShowFrame_OnClick()
	AllStatsShowFrame = not AllStatsShowFrame
	if AllStatsShowFrame then
		AllStatsFrame:Show()
	else
		AllStatsFrame:Hide()
	end
end
