void RM_GivePCSkin(object oPC);

void RM_GivePCSkin(object oPC)
{
    object oPC = GetLastUsedBy();
    object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);
    if (GetObjectType(oSkin) == -1)
    {
        oSkin = CreateItemOnObject("pc_skin", oPC);
        ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR);
    }
}


// void main(){}
