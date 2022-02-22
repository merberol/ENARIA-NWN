#include "rom_creatur_util"



void RM_NPC_DEATH_SYS(object dead, object killer);

object kobold_loot(object dead);

void RM_NPC_DEATH_SYS( object dead, object killer)
{
    // creation of base corpse type
    int creaturetype = RM_GET_CREATURE_TYPE(dead);
    object corpse;
    switch(creaturetype)
    {
        case RM_CREATURE_TYPE_KOBOLD:
        {
            corpse = kobold_loot(dead);
        }
    }

    // roll any extra coins.
    int roll = d100(1);
    int mod = FloatToInt(GetChallengeRating(dead) * 2);
    if (roll > (90 - mod))
    {
    int amount = d4(1) + mod >> 1;
    CreateItemOnObject("silvercoin", corpse, amount);
    }
}

object kobold_loot(object dead)
{
    object corpse = CreateObject(OBJECT_TYPE_PLACEABLE, "koboldcorpse", GetLocation(dead));
    string tag = GetTag(dead);
    int roll = d10(1);
    if(roll > 5)
    {
        CreateItemOnObject("rm_it_letharm001", corpse);
    }
    if(tag ==  "RM_KOBOLD_THUG")
    {
        return corpse;
    }
    if(tag ==  "RM_KOBOLD_ARCH")
    {
        int roll = d10(1);
        if(roll > 5)
        {
            CreateItemOnObject("RM_WBWSH001", corpse);
        }
        roll = d10(1);
        if(roll > 5)
        {
            //CreateItemOnObject("wamar001", corpse);
        }
        return corpse;
    }
    if(tag == "RM_KOBOLD_ARCH")
    {
        int roll = d10(1);
        if(roll > 5)
        {
            CreateItemOnObject("rm_it_shld_sm001", corpse);
        }
        roll = d10(1);
        if(roll > 5)
        {
            CreateItemOnObject("rm_it_sword", corpse);
        }
            return corpse;
    }
    return corpse;
}

//void main(){}
