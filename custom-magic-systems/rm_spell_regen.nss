//::///////////////////////////////////////////////
//:: Dimention door
//:: [rm_spell_regen.nss]
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Charlie Simonsson
//:: Created On: feb 14, 2022
//:://////////////////////////////////////////////

#include "utl_i_sqlplayer"
#include "nwnx_player"
#include "nwnx_creature"
#include "util_i_csvlists"
#include "utl_i_sqlplayer"

#include "nwnx_item"
#include "x2_inc_itemprop"
//runs the spel regen system
void SpellRegenSys(object oMod, object oPC);


//Replace the first unmemorized spell of the lowest level
void DoSpellRegen(object oPC);





void SpellRegenSys(object oMod, object oPC)
{
    // Guard statment to only run regen for caster
    if(GetLevelByClass(CLASS_TYPE_WIZARD,oPC) == 0){return;}	
    int sptic = GetLocalInt(oMod, "SPTIC");
    int SpellRegenTic = sptic >> 2;
    if (SpellRegenTic)
    {
        DoSpellRegen(oPC);
        sptic = 0;
    }
    else
    {
        sptic++;
    }
    SetLocalInt(oMod, "SPTIC", sptic );
}

void DoSpellRegen(object oPC)
{

    int spelllvl, spellindex, nSpells; 
     //SendMessageToPC(oPC, "DEBUG: Spell regen");


    for(spelllvl = 0; spelllvl < 10; spelllvl++)
    {
        nSpells = NWNX_Creature_GetMemorisedSpellCountByLevel(oPC, CLASS_TYPE_WIZARD, spelllvl);
        for(spellindex = 0; spellindex  < nSpells; spellindex ++)
        {
            struct NWNX_Creature_MemorisedSpell stMemorized =
                NWNX_Creature_GetMemorisedSpell(oPC, CLASS_TYPE_WIZARD, spelllvl, spellindex);

            if(stMemorized.ready == FALSE)
            {
                stMemorized.ready = TRUE;
                NWNX_Creature_SetMemorisedSpell(oPC,CLASS_TYPE_WIZARD,spelllvl,spellindex,stMemorized);

                return;
            }
        }
    }
    return;
}
