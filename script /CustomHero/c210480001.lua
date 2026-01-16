--Elemental HERO Fusion Catcher
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand if added by card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 "Masked HERO" monster from your Deck or GY to your hand, except "Masked HERO Dusk Crow"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end


s.listed_series={0x8,0xc008}
s.material_setcode={0x8,0xc008}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0xc008,fc,sumtype,tp) and c:IsLevelAbove(6)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsSetCard(0xc008) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.ConfirmCards(1-tp,tc)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:CanChainAttack(0,true)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then 
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(1000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
        Duel.ChainAttack()
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e2)
	end
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
