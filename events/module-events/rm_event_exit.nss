#include "utl_i_sqlplayer"
#include "nwnx_player"
#include "nwnx_events"

void main()
{
    object pc = OBJECT_SELF;

    string sCurrentEvent = NWNX_Events_GetCurrentEvent();
    location pos = GetLocation(pc);
    SQLocalsPlayer_SetLocation(pc, "CurrentPos", pos);

}
