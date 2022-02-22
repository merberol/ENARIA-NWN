//::///////////////////////////////////////////////
//:: Spell Inc
//:: [rm_sp_inc.nss]
//:://////////////////////////////////////////////
/*
	Library for spell utility functions
*/
//:://////////////////////////////////////////////
//:: Created By: Charlie Simonsson
//:: Created On: feb 14, 2022
//:://////////////////////////////////////////////



#include "nw_i0_spells"
#include "x2_i0_spells"

const int RM_SPELL_RANGE_PERSONAL = 0x00000001;
const int RM_SPELL_RANGE_TOUCH = 0x00000002;
const int RM_SPELL_RANGE_SHORT = 0x00000006;
const int RM_SPELL_RANGE_MEDIUM = 0x00000008;
const int RM_SPELL_RANGE_LONG = 0x0000000A;


/*
 * Wrapper for the Get casterlevel function
*/
int RM_GetCasterLevel(object oCreature);

int RM_GetIsCaster(object oPC);

//Helper function that calculates range of a spell
// Personal -> 0
// touch  -> 3
// short  -> 25 + 5 / clvl
// medium -> 100 + 10 / clvl
// long   -> 400 + 40 / clvl
// THESE MIGHT BE UNBALANCED SO MIGHT GET REVISITED AFTER TESTING!!!
int RM_CalculateRange(object oCaster, int nRange);



/*HELPER FUNCTION DONT USE OUTSIDE OF rm_sp_inc*/
int _CALC_SHORT(int nCLVL);
/*HELPER FUNCTION DONT USE OUTSIDE OF rm_sp_inc*/
int _CALC_MEDIUM(int nCLVL);
/*HELPER FUNCTION DONT USE OUTSIDE OF rm_sp_inc*/
int _CALC_LONG(int nCLVL);

int RM_GetCasterLevel(object oCreature)
{
  return GetCasterLevel(oCreature);
}

int RM_GetIsCaster(object oPC)
{
   int class1 = GetClassByPosition(1, oPC);
   switch(class1)
   {
        case CLASS_TYPE_WIZARD:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_BARD:
            return TRUE;
   }
   int class2 = GetClassByPosition(2, oPC);
   switch(class2)
   {
        case CLASS_TYPE_WIZARD:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_BARD:
            return TRUE;
   }
   int class3 = GetClassByPosition(3, oPC);
   switch(class3)
   {
        case CLASS_TYPE_WIZARD:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_BARD:
            return TRUE;
   }
   return FALSE;
}


int RM_CalculateRange(object oCaster, int nRange)
{
    int nCLVL = RM_GetCasterLevel(oCaster);
    switch(nRange)
    {
        case RM_SPELL_RANGE_PERSONAL:
            return 0;
        case RM_SPELL_RANGE_TOUCH:
            return 3;
        case RM_SPELL_RANGE_SHORT:
            return _CALC_SHORT(nCLVL);
        case RM_SPELL_RANGE_MEDIUM:
            return _CALC_MEDIUM(nCLVL);
        case RM_SPELL_RANGE_LONG:
            return _CALC_LONG(nCLVL);
    }
    return -1;
}





/*HELPER FUNCTION DONT USE OUTSIDE OF rm_sp_inc*/
int _CALC_SHORT(int nCLVL)
{
    return ( 25 + ( 5 *  nCLVL ) );
}
/*HELPER FUNCTION DONT USE OUTSIDE OF rm_sp_inc*/
int _CALC_MEDIUM(int nCLVL)
{
    return ( 100 + ( 10 * nCLVL ) );
}
/*HELPER FUNCTION DONT USE OUTSIDE OF rm_sp_inc*/
int _CALC_LONG(int nCLVL)
{
    return ( 400 + ( 40 * nCLVL ) );
}

// void main(){}
