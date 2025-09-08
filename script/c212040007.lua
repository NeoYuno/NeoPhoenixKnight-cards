--Violet Hunter Fusion Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Fusion procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--Cannot be destroyed by effects of Level 5 or higher monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Equip opponent's monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
    e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--Battle destruction replacement
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
	--Destroy same Type in battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.ffilter(c,fc,sumtype,sump,sub,matg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0 or (sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(fc,sumtype,sump),fc,sumtype,sump)
		and sg:IsExists(Card.IsRace,1,c,c:GetRace(fc,sumtype,sump),fc,sumtype,sump))
        and not sg:IsExists(Card.IsType,1,nil,TYPE_TOKEN)
end
function s.efilter(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsMonster() and rc:IsLevelAbove(5)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return #g==0
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsMonster() then
		if not Duel.Equip(tp,tc,c,false) then return end
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetOwner() end)
		tc:RegisterEffect(e1)
		--Gain ATK
		local atk=tc:GetBaseAttack()//2
		if atk<0 then atk=0 end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local egc=c:GetEquipGroup()
	if chk==0 then return #egc>0 end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=egc:Select(tp,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local egc=c:GetEquipGroup():GetFirst()
	return bc and egc and bc:GetOriginalRace()==egc:GetOriginalRace()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
