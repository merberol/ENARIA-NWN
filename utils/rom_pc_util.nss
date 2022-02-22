#include "nbde_inc"


// Returns a unique string identifying the PC - [FILE: _inc_util]

string GetPCID(object oPC);




string GetPCID(object oPC)

{

    string pcid    = GetLocalString(oPC, "CHARACTER_ID");

    if(pcid!="")

        return pcid;



        if(GetIsPC(oPC))

                pcid = IntToString( NBDE_Hash(GetPCPublicCDKey(oPC, TRUE)+"_"+GetName(oPC)) );

            else

                pcid = IntToString( NBDE_Hash(GetResRef(oPC)+"_"+GetTag(oPC)+"_"+GetName(oPC)) );





    SetLocalString(oPC, "CHARACTER_ID", pcid);

    return pcid;

}
