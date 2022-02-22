#include "utl_i_sqlplayer"
#include "x3_inc_horse"

void main()
{
    object oPC = GetEnteringObject();
    location start = GetStartingLocation();

    location pos = SQLocalsPlayer_GetLocation( oPC, "CurrentPos");
    SendMessageToPC(oPC, LocationToString(pos));

    SendMessageToPC(oPC, "onenter before transport check");


    if (GetLevelByPosition(1, oPC) < 3)
    {
        SendMessageToPC(oPC, "transporting to newplayer area");

        GiveXPToCreature(oPC, 300);

        object NPWP = GetObjectByTag("RM_NEWPLAYER_START");
        AssignCommand(GetEnteringObject(), ActionJumpToObject(NPWP));
        return;
    }
    else
    {

        if(!GetIsObjectValid(GetAreaFromLocation(pos)) || pos == start)
        {
            SendMessageToPC(oPC, "transporting to 'HOME'");
            AssignCommand(GetEnteringObject(), ActionJumpToObject(GetObjectByTag("RM_HOME")));
            return;
        }
        SendMessageToPC(oPC, "transporting to pos");
        AssignCommand(GetEnteringObject(), ActionJumpToLocation(pos));
    }



}
