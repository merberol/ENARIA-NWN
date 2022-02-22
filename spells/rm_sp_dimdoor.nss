//::///////////////////////////////////////////////
//:: Dimention door
//:: [rm_sp_dimdoor.nss]
//:://////////////////////////////////////////////
/*
    Transport the caster to the indicated porition
*/
//:://////////////////////////////////////////////
//:: Created By: Charlie Simonsson
//:: Created On: feb 14, 2022
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"
#include "rm_sp_inc"



void main()
{

    if (!X2PreSpellCastCode())
    {
        return;
    }

    object oPC = OBJECT_SELF;
    location lLoc = GetSpellTargetLocation();
    location lLoc1 = GetLocation(oPC);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(777), lLoc);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(776), lLoc1);
    ActionJumpToLocation(lLoc);
}
