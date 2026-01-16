--Elemental HERO Fusion Catcher
local s,id=GetID()
function s.initial_effect(c)
    --Effect 1: Special Summon itself if added to hand (except draw)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Effect 2: Search Polymerization / Fusion Spell on Special Summon by itself
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    --Effect 3: GY effect: recycle HERO monsters except itself
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+200)
    e3:SetCost(s.rmcost)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end

--=====================
-- Effect 1: Self SS
--=====================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsReason(REASON_DRAW)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--====================================
-- Effect 2: Search + HERO Extra Deck restriction
--====================================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL
        and e:GetHandler():IsReason(REASON_EFFECT)
end

function s.thfilter(c)
    return (c:IsCode(24094653) or (c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)))
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
        Duel.ConfirmCards(1-tp,g)
        -- Restriction: Cannot Special Summon from Extra Deck except HERO monsters
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x8)
end

--=====================
-- Effect 3: GY recycle
--=====================
function s.rmfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
        and not c:IsCode(id) -- cannot target itself
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
