//::///////////////////////////////////////////////
//:: Heartbeat Event
//:: a_rom_mod_hb
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Deva Winblood
//:: Created On: April 2nd, 2008
//:://////////////////////////////////////////////

#include "x3_inc_horse"


#include "rm_utils_inc"
#include "rm_spell_regen"



//:://////////////////////////////////////////////
//:: Created By: Deva Winblood
//:: Created On: April 2nd, 2008
//:: Modified for this Heartbeat script by charlie simonsson feb 6 2022
//:://////////////////////////////////////////////
void do_mount_check(object oPC);

/////////////////////////////////////////////////////////////[ MAIN ]///////////
void main()
{
    object oMod = GetModule();
    int iCurrentHour = GetTimeHour();
    int nCurrentMinute = GetTimeMinute();
    int nCurrentSecond = GetTimeSecond();
    int nCurrentMilli = GetTimeMillisecond();
    int nTimeStamp = GetUnixTimeStamp();
    // check for things to run every minute.
    int nTurn;
    if(GetLocalInt(oMod, "CheckMinute") != GetTimeMinute())
    {
        SetLocalInt(oMod, "CheckMinute", GetTimeMinute());
        nTurn = 1;
    }

    // call your modules here
    object oPC=GetFirstPC();


    while (GetIsObjectValid(oPC))
    { // PC traversal
        // call your modules here.
        SpellRegenSys(oMod, oPC);
        do_mount_check(oPC);

        oPC = GetNextPC();
    } // PC traversal



}




/////////////////////////////////////////////////////////////[ MAIN ]///////////
void do_mount_check(object oPC)
{
    int nRoll;
    int bNoCombat=GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT");
    // PC traversal
    if (GetLocalInt(oPC,"bX3_STORE_MOUNT_INFO"))
    { // store
        DeleteLocalInt(oPC,"bX3_STORE_MOUNT_INFO");
        HorseSaveToDatabase(oPC,X3_HORSE_DATABASE);
    } // store
    if (!bNoCombat&&GetHasFeat(FEAT_MOUNTED_COMBAT,oPC)&&HorseGetIsMounted(oPC))
    { // check for AC increase
        nRoll=d20()+GetSkillRank(SKILL_RIDE,oPC);
        nRoll=nRoll-10;
        if (nRoll>4)
        { // ac increase
            nRoll=nRoll/5;
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectACIncrease(nRoll),oPC,7.0);
        } // ac increase
    } // check for AC increase
}

/////////////////////////////////////////////////////////////[ MAIN ]///////////
