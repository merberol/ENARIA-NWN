//::///////////////////////////////////////////////
//:: Chromatic Orb
//:: [rm_sp_chromorb.nss]
//:://////////////////////////////////////////////
/* Description from baldurs gate.
This spell causes a 2-ft. diameter sphere to appear in the caster's hand. When thrown, 
the sphere heads unerringly to its target. 
The effect the orb has upon the target varies with the level of the caster. 
Each orb will do damage to the target against which there is no save and an effect 
against which the target must save vs. Spell with a +6 bonus:

1st Level: 1d4 damage and blinds the target for 1 round.
2nd Level: 1d4 damage and inflicts pain (-1 penalty to Strength, Dexterity, AC, and THAC0) upon the victim.
3rd Level: 1d6 damage and burns the victim for an additional 1d8 damage.
4th Level: 1d6 damage and blinds the target for 1 turn.
5th Level: 1d8 damage and stuns the target for 3 rounds.
6th Level: 1d8 damage and causes weakness (-4 penalty to THAC0) in the victim.
7th Level: 1d10 damage and paralyzes the victim for 2 turns.
10th Level: 1d12 acid damage and turns the victim to stone.
12th Level: 2d8 acid damage and instantly kills the victim.
NOTE: The victim saves vs. Spell with a +6 bonus against all the effects and gets no save against the damage.
*/
////////////////////////////////////////////////////////////////////////////////
//::                                             :://///////////////////////////
//::  Created by Charlie Simonsson feb 16 2022   :://///////////////////////////
//::                                             :://///////////////////////////
////////////////////////////////////////////////////////////////////////////////


#include "x2_inc_spellhook"
#include "rm_sp_inc"

effect _LEVEL2_HELPER();

void main()
{

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    object oTarget =  GetSpellTargetObject();
    object oCaster = OBJECT_SELF;
    int nCasterLevel = RM_GetCasterLevel(oCaster);

    effect eProjectile = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, 843));
    effect eDam;
    effect eVis;
    switch(nCasterLevel)
    {
     case 1:
     {

        if(!MyResistSpell(oCaster, oTarget ))   // for proper 2e rules this save shuld be at a 6 bonus.
        {
            effect eBlind = EffectBlindness();
            eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
            eDur = EffectLinkEffects(eBlind, eDur);
        }
        eDam = EffectDamage(d4(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);

        break;
     }
     case 2:
     {
        if(!MyResistSpell(oCaster, oTarget ))   // for proper 2e rules this save shuld be at a 6 bonus.
        {
            effect eEffect = _LEVEL2_HELPER();
            eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
            eDur = EffectLinkEffects(eDur, eEffect);
        }
        eDam = EffectDamage(d4(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);
        break;
     }
     case 3:
     {
        eDam = EffectDamage(d6(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);
        break;
     }
     case 4:
     {
        if(!MyResistSpell(oCaster, oTarget ))   // for proper 2e rules this save shuld be at a 6 bonus.
        {
            effect eBlind = EffectBlindness();
            eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
            eDur = EffectLinkEffects(eBlind, eDur);
        }
        eDam = EffectDamage(d6(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);
        break;
     }
     case 5:
     {
        eDam = EffectDamage(d8(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);
        break;
     }
     case 6:
     {
        eDam = EffectDamage(d8(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);
        break;
     }
     case 7:
     case 8:
     case 9:
     {
        eDam = EffectDamage(d10(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);

        break;
     }
     case 10:
     case 11:
     {
        eDam = EffectDamage(d12(1),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);

        break;
     }
     default:
     {
        eDam = EffectDamage(d8(2),DAMAGE_TYPE_ACID,DAMAGE_POWER_ENERGY);

        break;
     }
    }

    if(nCasterLevel != 4)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, RoundsToSeconds(1));
    }
    else
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, TurnsToSeconds(1));
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eProjectile, oTarget);
}



//  (-1 penalty to Strength, Dexterity, AC, and THAC0) upon the victim.
effect _LEVEL2_HELPER()
{
    effect str = EffectAbilityDecrease(ABILITY_STRENGTH, 1);
    effect dex = EffectAbilityDecrease(ABILITY_DEXTERITY, 1);
    effect ac = EffectACDecrease(1);
    effect attc = EffectAttackDecrease(1);
    effect eLink = EffectLinkEffects(str, dex);
    eLink = EffectLinkEffects(eLink, ac);
    eLink = EffectLinkEffects(eLink, attc);
    return eLink;
}
