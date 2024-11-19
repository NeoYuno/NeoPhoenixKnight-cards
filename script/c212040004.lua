--Spell Power Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),extrafil=s.extrafil,stage2=s.stage2})
	local tg=e1:GetTarget()
	local op=e1:GetOperation()
	e1:SetTarget(s.target(tg))
	e1:SetOperation(s.operation(op))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0xef}
function s.target(target)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			if e:GetLabel()==0 then
				return target(e,tp,eg,ep,ev,re,r,rp,0)
			end
			e:SetLabel(0)
			return true
		end
		e:SetLabel(0)
		return target(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.operation(operation)
	return function(e,...)
		e:SetLabel(1)
		local res=operation(e,...)
		e:SetLabel(0)
		return res
	end
end
function s.check(e)
	return function(tp,sg,fc)
		return e:GetLabel()==1 or (not e:GetLabelObject() or not sg:IsContains(e:GetLabelObject()))
	end
end
function s.extrafil(e,tp,mg1)
	return nil,s.check(e)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
        local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,38943357,75014062),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
		local cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,nil)
		if #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(38943357,0)) then
            local spellcount=ct+1
			Duel.BreakEffect()
			while spellcount>0 and #cg>0 do
				cg:Select(tp,1,1,nil):GetFirst():AddCounter(COUNTER_SPELL,1)
				spellcount=spellcount-1
				cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,nil)
			end
		end
	end
end
