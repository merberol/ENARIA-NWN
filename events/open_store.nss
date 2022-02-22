#include "nw_i0_plot"
void main()
{
    string sTag = GetLocalString(OBJECT_SELF, "shopTag");
    object oStore = GetNearestObjectByTag(sTag);
    if (GetObjectType(oStore) == OBJECT_TYPE_STORE)
    {
        gplotAppraiseOpenStore(oStore, GetPCSpeaker());
    }
    else
    {
        ActionSpeakStringByStrRef(53090, TALKVOLUME_TALK);
    }

}
