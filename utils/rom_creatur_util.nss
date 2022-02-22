#include "nbde_inc"


// persistent vars on pc's skin
#include "x3_inc_skin"

#include "x0_i0_match"


const int RM_CREATURE_TYPE_QUESSIR = 1;
const int RM_CREATURE_TYPE_KOBOLD = 2;


int RM_GET_CREATURE_TYPE(object creature);

int RM_GET_CREATURE_TYPE(object creature)
{
    return GetLocalInt(creature, "CREATURE_TYPE");
}
