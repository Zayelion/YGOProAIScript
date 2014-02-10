function HeraldicCount(cards)
  local result = 0
  for i=1,#cards do
    if cards[i].setcode==0x76 then result = result + 1 end
  end
  return result
end
function FieldCheck(level)
  local result=0
  local cards=AIMon()
  for i=1,#cards do
    if cards[i].level==level then
      result = result + 1
    end
  end
  return result
end
function HeraldicCanXYZ()
  local AIMon=AIMon()
  local cards=UseLists({AIHand(),AIMon})
  local handcount=HeraldicCount(AIHand())
  local gravecount=HeraldicCount(AIGrave())
  local fieldcount=HeraldicCount(AIMon)
  local result = false
  if not Duel.CheckNormalSummonActivity(player_ai) then
    if HasID(AIHand(),65367484) and handcount>0 and #AIMon==0 then --Thrasher
      result=true
    end
    if HasID(AIHand(),94656263) and handcount>0 then --Kagetokage
      result=true
    end
    if HasID(AIHand(),87255382) and (handcount>2 or HasID(AIHand(),82293134) and Duel.GetFlagEffect(player_ai,82293134)==0) then
      result=true
    end
    if HasID(UseLists({AIHand(),AIST()}),84220251) and handcount>0 and gravecount >0 then
      result=true
    end
    if FieldCheck(4)>0 then
      result=true
    end
  end
  return result
end
function HasBackrow(Setable)
  local cards=AIST()
  for i=1,#Setable do
    if SetBlacklist(Setable[i].id)==0 then
      return true
    end
  end
  for i=1,#cards do
    if bit32.band(cards[i].position,POS_FACEDOWN)>0 then
      return true
    end
  end
  return false
end
function SummonChidori()
  local cards = UseLists({OppMon(),OppST()})
  local result={0,0}
  for i=1,#cards do
    if bit32.band(cards[i].position,POS_FACEUP)>0 then result[1]=1 end
    if bit32.band(cards[i].position,POS_FACEDOWN)>0 then result[2]=1 end
  end
  return result[1]+result[2]>=2
end
function SummonLavalvalChain() 
  return not (HasID(UseLists({AIGrave(),AIHand(),AIMon()}),82293134) or Duel.GetFlagEffect(player_ai,82293134)==1) and Chance(30)
end
function SummonImpKing()
  return HasID(AIDeck(),94656263) and HasID(AIMon(),82293134) and (Chance(30) or HasID(AIMon(),23649496))
end
function UsePlainCoat()
  local cards=UseLists({AIMon(),OppMon()})
  local check={}
  local result=false
  for i=1,#cards do
    if check[cards[i].id] and (check[cards[i].id].owner==2 or cards[i].owner==2) then
      result=true
    end
    check[cards[i].id]=cards[i]
  end
  return result
end
function SummonPlainCoat()
  return UsePlainCoat() or not (HasID(UseLists({AIMon(),AIGrave()}),23649496)) and (Chance(50) or HasID(AIHand(),92365601))
end
function SummonGenomHeritage()
  local cards=OppMon()
  for i=1,#cards do
    if bit32.band(cards[i].type,TYPE_XYZ)>0 then
      return true
    end
  end
  return false
end
function SummonPaladynamo()
  local cards = OppMon()
  local c
  for i=1,#cards do
    c=cards[i]
    if c.attack>=2000 and bit32.band(c.position,POS_FACEUP_ATTACK)>0
    and c:is_affected_by(EFFECT_CANNOT_BE_EFFECT_TARGET)==0
    then
      return true
    end 
  end
end
function SummonRagnaZero()
  local cards = OppMon()
  local c
  for i=1,#cards do
    c=cards[i]
    if c.attack~=c.base_attack
    and bit32.band(c.position,POS_FACEUP_ATTACK)>0    
    and c:is_affected_by(EFFECT_INDESTRUCTABLE_EFFECT)==0
    and c:is_affected_by(EFFECT_CANNOT_BE_EFFECT_TARGET)==0
    then
      return true
    end 
  end
end
function SummonAmphisbaena()
  return FieldCheck(4)==1 or FieldCheck(4)==0 and HasID(AIHand(),94656263)
end
function UseAmphisbaena(card)
  if bit32.band(card.location,LOCATION_HAND)>0 then
    return Duel.CheckNormalSummonActivity(player_ai) and FieldCheck(4)==1 
    or HeraldicCanXYZ() and HasID(AIHand(),82293134) and HeraldicCount(AIHand())==2 and FieldCheck(4)==0
  else
    return false
  end
end
function UseAberconway()
  local hand = AIHand()
  return #hand <= 4 or HeraldicCount(hand)<=2
end
function UseHeraldryReborn()
  return Duel.CheckNormalSummonActivity(player_ai) and FieldCheck(4)==1
end
function C101Filter(c)
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)>0 and not c:IsType(TYPE_TOKEN) 
end
function UseC101()
  local cg=Duel.GetMatchingGroup(C101Filter,1-player_ai,LOCATION_MZONE,0,nil)
  return cg:GetCount() > 0 
end
function UsedSHarkFilter(c)
  return c.id == 48739166 and c.xyz_material_count < 2
end
function UseRUM()
  return HasID(AIMon(),23649496) or (HasID(AIGrave(),48739166) or CardsMatchingFilter(AIMon(),UsedSHarkFilter)>0) and UseC101()
end
function HeraldicOnSelectInit(cards, to_bp_allowed, to_ep_allowed)
  local Activatable = cards.activatable_cards
  local Summonable = cards.summonable_cards
  local SpSummonable = cards.spsummonable_cards
  local Repositionable = cards.repositionable_cards
  local SetableMon = cards.monster_setable_cards
  local SetableST = cards.st_setable_cards
  local HasBackrow = HasBackrow(SetableST)
  if HasID(Activatable,81439173) then   -- Foolish Burial
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,32807846) then   -- Reinforcement of the Army
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,34086406) then   -- Lavalval Chain
    if Activatable[CurrentIndex-1].id==34086406 then
      GlobalCardMode = 1
      GlobalActivatedCardID = 34086406
      return {COMMAND_ACTIVATE,CurrentIndex-1}
    end
  end
  if HasIDNotNegated(Activatable,11398059) then   -- Imp King
    GlobalCardMode = 1
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,47387961) then   -- Genom Heritage
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,23649496) and UsePlainCoat() then
    GlobalCardMode = 2
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(SpSummonable,65367484) then -- Photon Thrasher
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end 
  if HasID(Activatable,87255382) and UseAmphisbaena(Activatable[CurrentIndex]) then   -- Amphisbaena
    return {COMMAND_ACTIVATE,IndexByID(Activatable,87255382)}
  end
  if HasID(Activatable,60316373) and UseAberconway() then   -- Aberconway
    GlobalCardMode = 1
    return {COMMAND_ACTIVATE,IndexByID(Activatable,60316373)}
  end
  if HasID(Activatable,45705025) then  -- Unicorn
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,92365601) and UseRUM() then   -- Rank-Up Magic - Limited Barian's Force
    GlobalCardMode = 1
    return {COMMAND_ACTIVATE,IndexByID(Activatable,92365601)}
  end
  if HasID(Activatable,84220251) and UseHeraldryReborn() then 
    return {COMMAND_ACTIVATE,IndexByID(Activatable,84220251)}
  end
  if HasID(Activatable,61314842) then 
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(SpSummonable,1042) and SummonRagnaZero() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,1042)}
  end  
  if HasID(SpSummonable,22653490) and SummonChidori() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,61344030) and SummonPaladynamo() and Chance (50) then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,61344030)}
  end
  if HasID(SpSummonable,23649496) and SummonPlainCoat() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,23649496)}
  end
  if HasID(SpSummonable,47387961) and SummonGenomHeritage() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,34086406) and SummonLavalvalChain() and MP2Check() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,34086406)}
  end
  if HasID(SpSummonable,11398059) and SummonImpKing() and MP2Check() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,11398059)}
  end
  if HasID(SpSummonable,23649496) and not HasID(AIMon(),23649496) and MP2Check() then -- Plain Coat
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,23649496)}
  end
  if HasID(Summonable,82293134) and HeraldicCanXYZ() then   -- Leo
    return {COMMAND_SUMMON,IndexByID(Summonable,82293134)}
  end
  if HasID(Summonable,60316373) and HeraldicCanXYZ() then   -- Aberconway
    return {COMMAND_SUMMON,IndexByID(Summonable,60316373)}
  end
  if HasID(Summonable,45705025) and HeraldicCanXYZ() then   -- Unicorn
    return {COMMAND_SUMMON,IndexByID(Summonable,45705025)}
  end
  if HasID(Summonable,19310321) and HeraldicCanXYZ() then   -- Twin Eagle
    return {COMMAND_SUMMON,IndexByID(Summonable,19310321)}
  end
  if HasID(Summonable,82315772) and HeraldicCanXYZ() then   -- Eale
    return {COMMAND_SUMMON,IndexByID(Summonable,82315772)}
  end
  if HasID(Summonable,56921677) and HeraldicCanXYZ() then   -- Basilisk
    return {COMMAND_SUMMON,IndexByID(Summonable,56921677)}
  end
  if HasID(Summonable,87255382) and SummonAmphisbaena() then   -- Amphisbaena
    return {COMMAND_SUMMON,IndexByID(Summonable,87255382)}
  end
  if HasID(Summonable,56921677) and HasBackrow then   -- Basilisk
    return {COMMAND_SUMMON,IndexByID(Summonable,56921677)}
  end
  if HasID(Summonable,60316373) and HasBackrow then   -- Aberconway
    return {COMMAND_SUMMON,IndexByID(Summonable,60316373)}
  end
  if HasID(Summonable,45705025) and HasBackrow then   -- Unicorn
    return {COMMAND_SUMMON,IndexByID(Summonable,45705025)}
  end
  if HasID(Summonable,19310321) and HasBackrow then   -- Twin Eagle
    return {COMMAND_SUMMON,IndexByID(Summonable,19310321)}
  end
  if HasID(Summonable,82315772) and HasBackrow then   -- Eale
    return {COMMAND_SUMMON,IndexByID(Summonable,82315772)}
  end
  if HasID(Summonable,60316373) then   -- Aberconway
    return {COMMAND_SUMMON,IndexByID(Summonable,60316373)}
  end
  if HasID(SetableMon,82293134) then   -- Leo
    return {COMMAND_SET_MONSTER,CurrentIndex}
  end
  if HasID(SetableMon,56921677) then   -- Basilisk
    return {COMMAND_SET_MONSTER,CurrentIndex}
  end
  if HasID(SetableMon,45705025) then   -- Unicorn
    return {COMMAND_SET_MONSTER,CurrentIndex}
  end
  return nil
end
GlobalLeoCheck = 0
function HeraldicToGravePriority(card)
  local id=card.id
  if id==82293134 then
    if Duel.GetFlagEffect(player_ai,82293134)==0 and Duel.GetTurnCount()~=GlobalLeoCheck and card.location ~= LOCATION_REMOVED then
      GlobalLeoCheck=Duel.GetTurnCount()
      return 10
    elseif card.location == LOCATION_REMOVED then
      return 2
    else
      return 0
    end
  end
  if id==45705025 then
    if HasID(AIGrave(),id) then
      return 4
    else
      return 7
    end
  end
  if id==19310321 then
    if HasID(AIGrave(),id) then
      return 3
    else
      return 6
    end
  end
  if id==60316373 then return 5 end
  return 1
end
function HeraldicAssignPriority(cards,toLocation)
  local func = nil
  if toLocation==LOCATION_GRAVE then
    func = HeraldicToGravePriority
  end
  for i=1,#cards do
    cards[i].priority=func(cards[i])
  end
end
function HeraldicToGrave(cards,amount)
  result = {}
  for i=1,#cards do
    cards[i].index=i
  end
  HeraldicAssignPriority(cards,LOCATION_GRAVE)
  table.sort(cards,function(a,b) return a.priority>b.priority end)
  for i=1,amount do
    result[i]=cards[i].index
  end
  return result
end
function HeraldicToFieldPriority(card)
  local id=card.id
  if id==82293134 then
    return 4
  end
  if id==87255382 then
    return 3
  end
  if id==60316373 then
    return 2
  end
  if id==56921677 then
    return 2
  end
  if id==45705025 then
    return 0
  end
  if id==19310321 then
    return 0
  end
  return 1
end
function HeraldicToField(cards,amount)
  result = {}
  for i=1,#cards do
    cards[i].index=i
  end
  table.sort(cards,function(a,b) return HeraldicToFieldPriority(a)>HeraldicToFieldPriority(b) end)
  for i=1,amount do
    result[i]=cards[i].index
  end
  return result
end
function HeraldicToHand(cards)
  local AICards=UseLists({AIMon(),AIHand()})
  local AICardsGrave=UseLists({AICards,AIGrave()})
  if NeedsCard(82293134,cards,AICardsGrave) 
  or NeedsCard(82293134,cards,AIHand()) and HasID(AIHand(),87255382) then -- Leo
    return IndexByID(cards,82293134)
  end
  if NeedsCard(87255382,cards,AICards)          -- Amphisbaena
  and (HeraldicCount(AIHand())>1 or HasID(AIHand(),82293134) )
  then 
    return IndexByID(cards,87255382)
  end
  if NeedsCard(45705025,cards,AICardsGrave) then -- Unicorn
    return CurrentIndex
  end

  if NeedsCard(82293134,cards,AICards) then -- Leo
    return CurrentIndex
  end
  if NeedsCard(60316373,cards,AICards) then -- Aberconway
    return CurrentIndex
  end
  if NeedsCard(87255382,cards,AICards) then -- Amphisbaena
    return CurrentIndex
  end
  if NeedsCard(56921677,cards,AICards) then -- Basilisk
    return CurrentIndex
  end
  if NeedsCard(82315772,cards,AICards) then -- Eale
    return CurrentIndex
  end
  if HasID(cards,60316373) then --Aberconway
    return CurrentIndex
  end
  if NeedsCard(19310321,cards,AICardsGrave) then -- Twin Eagle
    return CurrentIndex
  end  
  if HasID(cards,82293134) then --Leo
    return CurrentIndex
  end
  return math.random(#cards)
end
function LavalvalChainTarget(cards)
    local result = nil
    if GlobalCardMode == 1 then
      GlobalCardMode = nil
    end
    result = HeraldicToGrave(cards,1)
    if result then return result end
    return {math.random(#cards)}
end
function ImpKingTarget(cards)
    local result = nil
    if GlobalCardMode == 1 then
      GlobalCardMode = nil
      result = HeraldicToGrave(cards,1)
    end
    if result then return result end
    return {math.random(#cards)}
end
function PlainCoatTarget(cards)
    local result = nil
    local e=Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
    local c=Duel.GetFirstTarget()
    if e and e:GetActivateLocation()==LOCATION_GRAVE then 
      result = HeraldicToGrave(cards,2)
    elseif c then
      for i=1,#cards do
        if cards[i].owner == 1 then
          result = {i}
        end
      end
    else
      result = HeraldicToGrave(cards,1)
    end
    if result then return result end
    return {math.random(#cards)}
end
function AberconwayTarget(cards)
  local result=nil
  if GlobalCardMode == 1 then
    GlobalCardMode = nil
  else
    result={HeraldicToHand(cards)}
  end
  if result == nil then result={math.random(#cards)} end
  return result
end
function SafeZoneTarget(cards)
  result = {}
  if GlobalCardMode == 1 then
    GlobalCardMode = nil
    result=Index_By_Loc(cards,2,"Highest",TYPE_MONSTER,nil,"==",LOCATION_MZONE)
  else
    result={IndexByID(cards,GlobalTargetID)}
    GlobalTargetID=nil
  end  
  if result == nil then result={math.random(#cards)} end
  return result
end
function LanceTarget(cards)
  result = {}
  if GlobalCardMode == 1 then
    GlobalCardMode = nil
    result=Index_By_Loc(cards,2,"Highest",TYPE_MONSTER,nil,"==",LOCATION_MZONE)
  else
    result={IndexByID(cards,GlobalTargetID)}
    GlobalTargetID=nil
  end  
  if result == nil then result={math.random(#cards)} end
  return result
end
function RUMTarget(cards)
  local c=Duel.GetFirstTarget()
  local cg=Duel.GetMatchingGroup(nil,1-player_ai,LOCATION_MZONE,0,nil)
  local g = cg:GetMaxGroup(Card.GetAttack)
  local result = nil
  if c then
    if c:IsCode(48739166) then
      result = IndexByID(cards,12744567)
    else
      if Chance(50) or g and g:GetFirst():GetAttack()>2600 then
        result = IndexByID(cards,11522979)
      else
        result = IndexByID(cards,55888045)
      end
    end
  else
    if HasID(cards,48739166) and UseC101() then
      result = IndexByID(cards,48739166)
    end
    if HasID(cards,23649496) then
      result = CurrentIndex
    end
  end
  if result == nil then result = math.random(#cards) end
  return {result}
end
function ChidoriCheck(cards)
  result=0
  for i=1,#cards do
    if bit32.band(cards[i].attribute,ATTRIBUTE_WIND)>0 then
      result = result + 1
    end
  end
  return result>=2
end
function AHATarget(cards)
 local c=Duel.GetFirstTarget()
 local result=nil
 if c then
  if HasID(cards,23649496) and not HasID(AIMon(),23649496) then
    result=IndexByID(cards,23649496)
  end
  if HasID(cards,12014404) and SummonCowboyAtt() then
    result=IndexByID(cards,12014404)
  end
  if HasID(cards,34086406) and SummonLavalvalChain() then
    result=IndexByID(cards,34086406)
  end
  if HasID(cards,11398059) and SummonImpKing() then
    result=IndexByID(cards,11398059)
  end
  if HasID(cards,23649496) and SummonPlainCoat() then
    result=IndexByID(cards,23649496)
  end
  --[[if HasID(cards,48739166) and SummonSharkKnight() then 
    result=IndexByID(cards,48739166)
  end]]
  if HasID(cards,22653490) and SummonChidori() then
    result=IndexByID(cards,22653490)
  end
  if HasID(cards,1042) and SummonRagnaZero() then
    return IndexByID(cards,1042)
  end
  if HasID(cards,61344030) and SummonPaladynamo() then
    result=IndexByID(cards,61344030)
  end 
  if HasID(cards,47387961) and SummonGenomHeritage() then
    result=IndexByID(cards,47387961)
  end
  if HasID(cards,46772449) and SummonBelzebuth() then
    result=IndexByID(cards,46772449)
  end  
  if HasID(cards,12014404) and SummonCowboyDef() then
    result=IndexByID(cards,12014404)
  end
  if result == nil then result=math.random(#cards) end
  return {result}
 else
  if SummonChidori() then 
    for i=1,#cards do
      if bit32.band(cards[i].attribute,ATTRIBUTE_WIND)>0 then
        result = {i}
      end
    end 
  end
  if result == nil then result = HeraldicToField(cards,1) end
  return result
 end
end
function HeraldicOnSelectCard(cards, minTargets, maxTargets, triggeringID)
  local result = {}
  if triggeringID == 34086406 then -- Lavalval Chain
    return LavalvalChainTarget(cards)
  end
  if triggeringID == 11398059 then -- King of the Feral Imps
    return ImpKingTarget(cards)
  end
  if triggeringID == 23649496 then -- Plain Coat
    return PlainCoatTarget(cards)
  end
  if triggeringID == 81439173 then -- Foolish Burial
    return HeraldicToGrave(cards,1)
  end
  if triggeringID == 82293134 then -- Leo
    return {HeraldicToHand(cards)}
  end
  if triggeringID == 60316373 then -- Aberconway
    return AberconwayTarget(cards)
  end
  if triggeringID == 87255382 then -- Amphisbaena
    return HeraldicToGrave(cards,1)
  end
  if triggeringID == 38296564 then -- Safe Zone
    return SafeZoneTarget(cards)
  end
  if triggeringID == 27243130 then -- Forbidden Lance
    return LanceTarget(cards)
  end
  if triggeringID == 84220251 then -- Heraldry Reborn
    return HeraldicToField(cards,1)
  end
  if triggeringID == 92365601 then -- Rank-Up Magic - Limited Barian's Force
    return RUMTarget(cards)
  end
  if triggeringID == 61314842 then -- Advanced Heraldry Art
    return AHATarget(cards)
  end
  if triggeringID == 55888045 then -- C106: Giant Hand Red
    GlobalC106=Duel.GetTurnCount()
    return HeraldicToGrave(cards,1)
  end
  return nil
end
GlobalC106=0
function ChainPlainCoat()
  result = true
  local effect
  for i=1,Duel.GetCurrentChain() do
    effect = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT)
    if effect and effect:GetHandler():GetCode()==23649496 then
      result=false
    end
  end
  effect = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
  if effect and effect:IsHasCategory(CATEGORY_DISABLE+CATEGORY_NEGATE) then 
    result = true 
  end
  return result and UsePlainCoat() 
end
function SafeZoneFilter(card)
  return card:IsControler(player_ai) and card:IsType(TYPE_MONSTER) and not card:IsCode(23649496) and card:GetCode()~=82293134 and card:IsPosition(POS_FACEUP_ATTACK)
end
function SafeZoneFilterEnemy(card)
  return card:IsControler(1-player_ai) and card:IsType(TYPE_MONSTER) and card:IsPosition(POS_FACEUP_ATTACK)
end
function RemovalCheck()
  local c={CATEGORY_DESTROY,CATEGORY_REMOVE,CATEGORY_TOGRAVE,CATEGORY_TOHAND,CATEGORY_TODECK}
  for i=1,#c do
    local ex,cg = Duel.GetOperationInfo(0,c[i])
    if ex then return cg end
  end
  return false
end
function ChainSafeZone()
	local cg = RemovalCheck()
	if cg then
		if cg:IsExists(function(c) return c:IsControler(player_ai) and c:IsCode(38296564) end, 1, nil) then
      local g=Duel.GetMatchingGroup(SafeZoneFilterEnemy,1-player_ai,LOCATION_MZONE,0,nil)
      if g and g:GetCount()>0 then
        GlobalCardMode=1
        return true
      end
    end	
  end
  local cardtype = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_EXTTYPE)
  local ex,cg = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
  local tg = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TARGET_CARDS)
  if ex then
    if tg then
      local g = tg:GetMaxGroup(Card.GetAttack)
      if g then
        GlobalTargetID = g:GetFirst():GetCode() 
      end
      return tg:IsExists(SafeZoneFilter, 1, nil) and Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_PLAYER)~=player_ai
    else
      local g = cg:Filter(SafeZoneFilter, nil):GetMaxGroup(Card.GetAttack)
      if g then
        GlobalTargetID = g:GetFirst():GetCode()
      end
    return cg:IsExists(SafeZoneFilter, 1, nil) and Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_PLAYER)~=player_ai
    end
  end
  if Duel.GetCurrentPhase() == PHASE_BATTLE then
		local source = Duel.GetAttacker()
		local target = Duel.GetAttackTarget()
    if source and target then
      if source:IsControler(player_ai) then
        target = Duel.GetAttacker()
        source = Duel.GetAttackTarget()
      end
      if source:GetAttack() >= target:GetAttack() and target:IsControler(player_ai) 
      and target:IsPosition(POS_FACEUP_ATTACK) and not target:IsCode(23649496)
      then
        GlobalTargetID=target:GetCode()
        return true
      end
    end
  end
  return false
end

function LanceFilter(card)
	return card:IsControler(player_ai) and card:IsType(TYPE_MONSTER) and card:IsLocation(LOCATION_MZONE) and card:IsPosition(POS_FACEUP)
end
function ChainLance()
	local ex,cg = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
	if ex then
		if cg:IsExists(function(c) return c:IsControler(player_ai) and c:IsCode(27243130) end, 1, nil) then
      --return true
    end	
  end
  local cardtype = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_EXTTYPE)
  local ex,cg = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
  local tg = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TARGET_CARDS)
  if ex then
    local g = cg:Filter(LanceFilter, nil):GetMaxGroup(Card.GetAttack)
    if g then
      GlobalTargetID = g:GetFirst():GetCode()
   end
    return bit32.band(cardtype, TYPE_SPELL+TYPE_TRAP) ~= 0 and cg:IsExists(LanceFilter, 1, nil) and Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_PLAYER)~=player_ai
  elseif tg then
    local g = tg:GetMaxGroup(Card.GetAttack)
    if g then
      GlobalTargetID = g:GetFirst():GetCode() 
    end
    return bit32.band(cardtype, TYPE_SPELL+TYPE_TRAP) ~= 0 and tg:IsExists(LanceFilter, 1, nil) and Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_PLAYER)~=player_ai
  end
  if Duel.GetCurrentPhase() == PHASE_DAMAGE then
		local source = Duel.GetAttacker()
		local target = Duel.GetAttackTarget()
    if source and target then
      if source:IsControler(player_ai) then
        target = Duel.GetAttacker()
        source = Duel.GetAttackTarget()
      end
      if source:GetAttack() >= target:GetAttack() and math.max(source:GetAttack()-800,0) <= target:GetAttack() 
      and source:IsPosition(POS_FACEUP_ATTACK) and target:IsPosition(POS_FACEUP_ATTACK) and target:IsControler(player_ai)
      then
        GlobalTargetID=source:GetCode()
        return true
      end
    end
  end
  return false
end

function ChainKage()
  return FieldCheck(4)==1
end

function HeraldicOnSelectChain(cards,only_chains_by_player)
  if HasIDNotNegated(cards,23649496) and ChainPlainCoat() then
    return {1,CurrentIndex}
  end
  if HasID(cards,38296564) and ChainSafeZone() then
    return {1,CurrentIndex}
  end
  if HasID(cards,27243130) and ChainLance() then
    return {1,CurrentIndex}
  end
  if HasID(cards,94656263) and ChainKage() then
    return {1,IndexByID(cards,94656263)}
  end
  return nil
end

function HeraldicOnSelectOption(options)
  return nil
end
HeraldicAtt={
  65367484,60316373,87255382,61344030,
  47387961,11398059,34086406,22653490,
  11522979,55888045,12744567,00001042
}
HeraldicDef={
  19310321,45705025,82315772,56921677
}
function HeraldicOnSelectPosition(id, available)
  result = nil
  for i=1,#HeraldicAtt do
    if HeraldicAtt[i]==id then result=POS_FACEUP_ATTACK end
  end
  for i=1,#HeraldicDef do
    if HeraldicDef[i]==id then result=POS_FACEUP_DEFENCE end
  end
  if id==23649496 then
    if AI.GetCurrentPhase() == PHASE_MAIN2 or Duel.GetTurnCount() == 1 then
      result=POS_FACEUP_DEFENCE
    else
      result=POS_FACEUP_ATTACK
    end
  end
  return result
end