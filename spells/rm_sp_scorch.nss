//::///////////////////////////////////////////////
//:: Scorching Ray
//:: [rm_sp_scorch.nss]
//:://////////////////////////////////////////////
/* 

*/
////////////////////////////////////////////////////////////////////////////////
//::                                             :://///////////////////////////
//::  Created by Charlie Simonsson feb 16 2022   :://///////////////////////////
//::                                             :://///////////////////////////
////////////////////////////////////////////////////////////////////////////////
#include "x2_inc_spellhook"
#include "rm_sp_inc"

void main()
{
/*
  Spellcast Hook Code
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more
*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook





    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nCasterLevel = RM_GetCasterLevel(OBJECT_SELF); 
    int nMetaMagic = GetMetaMagicFeat();

    int nDamage;
    int nRay, i;

    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M );
    // calculate number of rays.
    nRay = (nCasterLevel + 1) >> 2;
    if (nRay > 3) { nRay = 3; }

    while (nRay > 0)
    {
        nRay--;// = nRay - 1;
        int nTouch = TouchAttackRanged(oTarget,TRUE);

        effect eRay;

        if (nTouch > 0)
        {


            //Enter Metamagic conditions
            if (nMetaMagic == METAMAGIC_MAXIMIZE)
            {
                if (nTouch == 2)
                {
                    nDamage = 6 * 8;//Damage is at max
                }
                else
                {
                    nDamage = 6 * 4;//Damage is at max
                }
            }
            else
            {	
                if (nTouch == 2)
                {
                    nDamage = d6(8);
                }
                else
                {
                    nDamage = d6(4);
                }
            }
            if (nMetaMagic == METAMAGIC_EMPOWER)
            {
                nDamage = nDamage + (nDamage/2);
            }
            eRay = EffectBeam(VFX_BEAM_FIRE, OBJECT_SELF, BODY_NODE_HAND,FALSE);

            if(!GetIsReactionTypeFriendly(oTarget))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, 854));
                if (!MyResistSpell(OBJECT_SELF, oTarget))
                {
                    effect eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                    //Apply the VFX impact and effects
                    DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                }
            }
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, oTarget, 1.7);
        }
        else
        {
            eRay = EffectBeam(VFX_BEAM_COLD, OBJECT_SELF, BODY_NODE_HAND,TRUE);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, oTarget, 1.7);
        }
    }
}


