--Amethyst Hunter Fusion Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Fusion procedure
	c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--Cannot be destroyed by monster effects
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
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--Gain ATK for each equipped monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,c)
		return e:GetHandler():GetEquipGroup():FilterCount(s.eqfilter,nil)*1000
	end)
	c:RegisterEffect(e3)
	--Can attack all monsters opponent controls with same Type or Attribute as equipped monster(s)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(s.atkall)
	c:RegisterEffect(e4)
	--Send equip to GY: destroy high-Level monsters and burn
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
function s.ffilter(c,fc,sumtype,sump,sub,matg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0 or (sg:IsExists(Card.IsAttribute,1,c,ATTRIBUTE_DARK,fc,sumtype,sump)
		and sg:IsExists(Card.IsRace,1,c,c:GetRace(fc,sumtype,sump),fc,sumtype,sump)
		and sg:IsExists(s.fusfilter1,1,c,fc,sumtype,sump)
		and sg:IsExists(s.fusfilter2,1,c,fc,sumtype,sump))
end
function s.fusfilter1(c,code,fc,sumtype,sump)
	return c:IsLevelAbove(7) and not c:IsHasEffect(511002961)
end
function s.fusfilter2(c,code,fc,sumtype,sump)
	return c:IsType(TYPE_FUSION) and not c:IsHasEffect(511002961)
end

function s.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
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
	end
end
function s.eqfilter(c)
	return c:GetEquipTarget()
end

function s.atkall(e,c)
	local eg=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)
	if #eg==0 then return false end
	local g=eg:GetFirst()
	while g do
		if c:IsRace(g:GetOriginalRace()) or c:IsAttribute(g:GetOriginalAttribute()) then return true end
		g=eg:GetNext()
	end
	return false
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local eg=c:GetEquipGroup():Filter(s.eqfilter,nil)
	if chk==0 then return #eg>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=eg:Select(tp,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoGrave(g,REASON_COST)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLevelAbove,tp,0,LOCATION_MZONE,1,nil,5) end
	local g=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,0,LOCATION_MZONE,nil,5)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,0,LOCATION_MZONE,nil,5)
	if #g==0 then return end
	local atk=g:GetMaxGroup(Card.GetBaseAttack):GetFirst():GetBaseAttack()
	if Duel.Destroy(g,REASON_EFFECT)>0 and atk>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
