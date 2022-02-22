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






 /*
//mythic system
const string MA_ABILITIES = "Strength,Dexterity,Constitution,Intelligence,Wisdom,Charisma";
const string MA_TIER_MINIMUMS = "1000,2000,4000,8000";
const string MA_POINTS = "nMythicPoints";
const string MA_TIER = "nMythicTier";
const string MA_TIER_MIGRATE = "MA_TIER_MIGRATE";

const string MA_TRAINING = "melee training,ranged weapon training,resilience,magic training,magic training,socializing";
const string MA_ADJECTIVE = "stronger,more dextrous,more hardy,more intellectual,more insightful,more charismatic";

string _GetAttributeDescription(int nAttribute, int nLowercase = FALSE, int nAbbreviate = FALSE)
{
    string sAttribute = GetListItem(MA_ABILITIES, nAttribute);

    if (nAbbreviate) sAttribute = GetStringLeft(sAttribute, 3);
    return (nLowercase ? GetStringLowerCase(sAttribute) : sAttribute);
}

int ma_CheckForAbilityIncrement(object oPC, int nAbility)
{

//    if (SQLocalsPlayer_GetInt(oPC, MA_TIER_MIGRATE) == FALSE)
//        _MigrateVariables(oPC);

    // Get the PC's standing for this ability's mythic points
    string sAbility = IntToString(nAbility);
    int nPCAttributePoints = SQLocalsPlayer_GetInt(oPC, MA_POINTS + sAbility);
    int nPCAttributeTier = SQLocalsPlayer_GetInt(oPC, MA_TIER + sAbility);
    int nTierMinimum = StringToInt(GetListItem(MA_TIER_MINIMUMS, nPCAttributeTier));

    // Check for already maxed tiers
    if (nPCAttributeTier >= CountList(MA_TIER_MINIMUMS)) return -1;

    // Adjust if required
    if (nPCAttributePoints >= nTierMinimum)
    {
        // Set the new tier on the PC
        SQLocalsPlayer_SetInt(oPC, MA_TIER + sAbility, ++nPCAttributeTier);

        // Create the message to send to the PC
        string sMessage = "Mythic " + _GetAttributeDescription(nAbility) + ": " +
            "Your " + GetListItem(MA_TRAINING, nAbility) + " pays off; ";

        if (nPCAttributeTier >= CountList(MA_TIER_MINIMUMS))
            sMessage += "Mythic " + _GetAttributeDescription(nAbility) + " is now capped!";
        else
            sMessage += "You've become " + GetListItem(MA_ADJECTIVE, nAbility) + "!";

        // Permanent modify the PC's raw ability score
        NWNX_Creature_ModifyRawAbilityScore(oPC, nAbility,1);
        SendMessageToPC(oPC, sMessage);
    }

    return SQLocalsPlayer_GetInt(oPC, MA_TIER + sAbility);
}

int ma_AccrueMythicAttribute(object oPC, int nAttribute, int nAmount)
{
    string sVarName = MA_POINTS + IntToString(nAttribute);

    SQLocalsPlayer_SetInt(oPC, sVarName, SQLocalsPlayer_GetInt(oPC, sVarName) + nAmount);
    //SendMessageToPC(oPC, "Mythic Attribute message: You receive " + IntToString(nAmount) + " " +
        //"points of Mythic " + _GetAttributeDescription(nAttribute) + " Training.");

    ma_CheckForAbilityIncrement(oPC, nAttribute);
    return SQLocalsPlayer_GetInt(oPC, sVarName);
}

int ma_GetCurrentAccrual(object oPC, int nAttribute)
{
    string sVarName = MA_POINTS + IntToString(nAttribute);
    return SQLocalsPlayer_GetInt(oPC, sVarName);
}

int ma_AwardAmount(object oPC, int nAttribute)
{
    int nMythicAmt;
    int nAppearance = GetAppearanceType(oPC);

    if(nAppearance > 6)//not a pc appearance, maybe polymorph or wildshape
    {
        return nMythicAmt = 0;
    }

    if(ma_GetCurrentAccrual(oPC,nAttribute) < 1000)
    {
        nMythicAmt = 5;
        return nMythicAmt;
    }
    else if(ma_GetCurrentAccrual(oPC,nAttribute) < 2000)
    {
        nMythicAmt = 2;
        return nMythicAmt;
    }
    else if(ma_GetCurrentAccrual(oPC,nAttribute) < 8000)
    {
        nMythicAmt = 1;
        return nMythicAmt;
    }
    else return nMythicAmt = 0;

    //return nMythicAmt;
}

*/

/*this can be used for spell point pool regen

int DetermineXPRate(int iXPRate)
{
    int i;
    switch(iXPRate)
    {
        case 1: //Deserts
        {
            i = GetLocalInt(GetModule(),"iDesertXP");
            break;
        }
        case 2: //Plains
        {
            i = GetLocalInt(GetModule(),"iPlainXP");
            break;
        }
        case 3: //Hills
        {
            i = GetLocalInt(GetModule(),"iHillXP");
            break;
        }
        case 4: //Marshes
        {
            i = GetLocalInt(GetModule(),"iMarshXP" );
            break;
        }
        case 5: //Forests
        {
            i = GetLocalInt(GetModule(),"iForestXP");
            break;
        }
        case 6: //Crypts
        {
            i = GetLocalInt(GetModule(),"iCryptXP");
            break;
        }
        case 7: //Roads
        {
            i = GetLocalInt(GetModule(),"iRoadXP");
            break;
        }
        case 8: //Towns
        {
            i = GetLocalInt(GetModule(),"iTownXP");
            break;
        }
        case 9: //Temples
        {
            i = GetLocalInt(GetModule(),"iTempleXP");
            break;
        }
        case 10: //Secret Areas
        {
            i = GetLocalInt(GetModule(),"iSecretXP");
            break;
        }
        case 11: //Taverns
        {
            i = GetLocalInt(GetModule(),"iTavernXP");
            break;
        }
        case 12: //Keeps
        {
            i = GetLocalInt(GetModule(),"iKeepXP");
            break;
        }
        case 13: //Low Gain Magical
        {
            i = GetLocalInt(GetModule(),"iMagicXP");
            break;
        }
        default:
        {
            i = GetLocalInt(GetModule(),"iDefXP");
            break;
        }
   }
   return i;
}
*/





 //void main(){}//comment me out!


