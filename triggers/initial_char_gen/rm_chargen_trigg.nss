#include "colors_inc"
#include "nwnx_player"
#include "nwnx_creature"
void main()
{
    object pc = GetEnteringObject();
    object item = GetFirstItemInInventory(pc);
    while(GetIsObjectValid(item))
    {
        DestroyObject(item);
        item = GetNextItemInInventory(pc);
    }

	// to do change to better colors
    string message =  ColorTokenGameEngine() + "As you approach the mountain in the distance you start pondering your life,\nwho you are, who you where.";
    message +=  "\nYour memories of what came before are hazy but you remember a wild and desperate fight,\nA hasty retreat into the center of the Peoples house.";
    message += "\nyou dont quite know where you are but all you know is you need to go back." +ColorTokenWhite()+ "\nThe sancuary Must be defended." + ColorTokenGameEngine();
    message += "\nyou think to yourself as you hurry towards the mountain.";

    SendMessageToPC(pc, message);
}
