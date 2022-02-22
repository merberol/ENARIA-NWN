#include "crp_inc_control"
#include "x2_inc_itemprop"

object oMerch = OBJECT_SELF;

// Adjust the alignment of oSubject.
// - oSubject
// - nAlignment:
//   -> ALIGNMENT_LAWFUL/ALIGNMENT_CHAOTIC/ALIGNMENT_GOOD/ALIGNMENT_EVIL: oSubject's
//      alignment will be shifted in the direction specified
//   -> ALIGNMENT_ALL: nShift will be added to oSubject's law/chaos and
//      good/evil alignment values
//   -> ALIGNMENT_NEUTRAL: nShift is applied to oSubject's law/chaos and
//      good/evil alignment values in the direction which is towards neutrality.
//     e.g. If oSubject has a law/chaos value of 10 (i.e. chaotic) and a
//          good/evil value of 80 (i.e. good) then if nShift is 15, the
//          law/chaos value will become (10+15)=25 and the good/evil value will
//          become (80-25)=55
//     Furthermore, the shift will at most take the alignment value to 50 and
//     not beyond.
//     e.g. If oSubject has a law/chaos value of 40 and a good/evil value of 70,
//          then if nShift is 15, the law/chaos value will become 50 and the
//          good/evil value will become 55
// - nShift: this is the desired shift in alignment
// * No return value
void AdjustAlignmentSinglePlayer(object oPC, int iAlignment, int iShift);

void GiveCoinsTo(object oPC, int nNum, string sType);

int GetCoins(object oPC, string sType);

//SetMerchantItem (ListNumber, "ItemName", "Item resref", NumberOfCoins, TYPE_OF_COIN);
//
//    ListNumber----- The order that the item will show up in the menu.
//                    Use 1,2,3,... in order, on each of your lines.
//    "ItemName"----- The text that will show up in the merchant's menu dialog
//                    for each item.
//    "Item resref"-- The blueprint name or resref of the item that the player
//                    should receive when they select this item. (case sensitive)
//    NumberOfCoins-- The number of coins that the item costs.  If the item
//                    costs 3cp, then this number should be 3.  If the item
//                    costs 2sp, then this number should be 2...
//    TYPE_OF_COIN--- The only legal values for this field are:
//                    COIN_COPPER
//                    COIN_SILVER or
//                    COIN_GOLD
//                    I'm not sure why you would want to use COIN_GOLD,
//                    but you might. If you want something to cost 2sp, then
//                    NumberOfCoins = 2, and TYPE_OF_COIN = COIN_SILVER.
void SetMerchantItem(int nListNum, string sItemName, string sItemResRef, int nCoinCost, string sCoinType);

string GetCoinFriendlyName(string sCoinType)
{
    if(sCoinType == COIN_COPPER) return "copper piece(s)";
    else if(sCoinType == COIN_SILVER) return "silver piece(s)";
    else if(sCoinType == COIN_ELECTRUM) return "electrum piece(s)";
    else if(sCoinType == COIN_GOLD) return "gold piece(s)";
    else if(sCoinType == COIN_PLATINUM) return "platinum piece(s)";
    else return "grimy coin(s) of unknown denomination";
}
int GetCoins(object oPC, string sType)
{
    int nCoin = 0;
    object oCoin = GetFirstItemInInventory(oPC);
    while(oCoin != OBJECT_INVALID)
    {
        if(GetTag(oCoin) == sType)
           nCoin = nCoin + GetItemStackSize(oCoin);
        oCoin = GetNextItemInInventory(oPC);
    }
    return nCoin;
}
void TakeCoinsFrom(object oPC, int nNum, string sType)
{
    int nCoin = 0;
    object oCoin = GetFirstItemInInventory(oPC);
    while(oCoin != OBJECT_INVALID)
    {
        if(GetTag(oCoin) == sType)
        {
            nCoin = GetItemStackSize(oCoin);
            if(nCoin > nNum)
            {
                SetItemStackSize(oCoin, nCoin - nNum);
                return;
            }
            else
            {
                DestroyObject(oCoin);
                nNum = nNum - nCoin;
            }
        }
        oCoin = GetNextItemInInventory(oPC);
    }
}
int TakeCoinsMakeChange(object oPC, int nNum, string sType, string sChangeCoin="", int nChangeCoinValue=0)
{
    string sMessage1, sMessage2;
    string sNextCoinUp;
    int nCoinUpValue;
    int nCoinValue;

    if(GetCoins(oPC, sType) < nNum)
    {
        //first, determine the requested coin types value
        if(sType == COIN_COPPER)
        {
            sNextCoinUp = COIN_SILVER;
            nCoinUpValue = VALUE_SILVER;
            nCoinValue = VALUE_COPPER;
        }
        else if(sType == COIN_SILVER)
        {
            sNextCoinUp = COIN_GOLD;
            nCoinUpValue = VALUE_GOLD;
            nCoinValue = VALUE_SILVER;
        }
        else if(sType == COIN_GOLD)
        {
            sNextCoinUp = COIN_PLATINUM;
            nCoinUpValue = VALUE_PLATINUM;
            nCoinValue = VALUE_GOLD;
        }
        else return 0; //can't make change

        //if ChangeCoin hasn't been defined, define it
        if(sChangeCoin == "")
        {
            sChangeCoin = sNextCoinUp;
            nChangeCoinValue = nCoinUpValue;
        }
        //we have the change coin and its value - determine if
        //we have at least one of those coins in inventory
        if(GetCoins(oPC, sChangeCoin) >= 1)
        {
            //we do - take it and make change
            TakeCoinsFrom(oPC, 1, sChangeCoin);
            sMessage1 = "You hand the merchant 1 " + GetCoinFriendlyName(sChangeCoin) + ".";

            int nCoinsBack;
            int nChangeValue = (nChangeCoinValue - (nCoinValue * nNum));
            if(nChangeValue >= nCoinUpValue)
            {
                nCoinsBack = nChangeValue / nCoinUpValue;
                GiveCoinsTo(oPC, nCoinsBack, sNextCoinUp);
                sMessage2 = "The merchant gives you " +
                            IntToString(nCoinsBack) + " " +
                            GetCoinFriendlyName(sNextCoinUp);
                nChangeValue = nChangeValue - (nCoinsBack * nCoinUpValue);
                if(nChangeValue >= nCoinValue)
                {
                    nCoinsBack = nChangeValue / nCoinValue;
                    GiveCoinsTo(oPC, nCoinsBack, sType);
                    sMessage2 = sMessage2 + " and " + IntToString(nCoinsBack) +
                               " " + GetCoinFriendlyName(sType);
                }
                sMessage2 = sMessage2 + " in change.";
                SendMessageToPC(oPC, sMessage1);
                SendMessageToPC(oPC, sMessage2);
            }
            else
            {
                nCoinsBack = nChangeValue / nCoinValue;
                GiveCoinsTo(oPC, nCoinsBack, sType);
                sMessage2 = "The merchant gives you " +
                            IntToString(nCoinsBack) + " " +
                            GetCoinFriendlyName(sType) + " in change.";
                SendMessageToPC(oPC, sMessage1);
                SendMessageToPC(oPC, sMessage2);
            }
            return 1;
        }
        else
        {
            //we don't - what's the next highest coin after that?
            if(sChangeCoin == COIN_SILVER)
            {
                sNextCoinUp = COIN_GOLD;
                nCoinUpValue = VALUE_GOLD;
            }
            else if(sChangeCoin == COIN_GOLD)
            {
                sNextCoinUp = COIN_PLATINUM;
                nCoinUpValue = VALUE_PLATINUM;
            }
            else
                return 0; //can't make change

            return TakeCoinsMakeChange(oPC, nNum, sType, sNextCoinUp, nCoinUpValue);
        }
     }
     else
     {
        TakeCoinsFrom(oPC, nNum, sType);
        sMessage1 = "You hand the merchant " + IntToString(nNum) + " " +
                   GetCoinFriendlyName(sType) + ".";
        SendMessageToPC(oPC, sMessage1);
        return 1; //success
     }
}
void GiveCoinsTo(object oPC, int nNum, string sType)
{
    object oContainer = GetLocalObject(oPC, "COIN_POUCH");
    int nCount;

    if(!GetIsObjectValid(oContainer))
        oContainer = oPC;
    else
    {
        object oItem = GetFirstItemInInventory(oContainer);
        while(oItem != OBJECT_INVALID)
        {
            nCount++;
            oItem = GetNextItemInInventory(oContainer);
        }
        if(nCount >= 35)
            oContainer = oPC;
    }

    if(nNum <= 100)
    {
        CreateItemOnObject(sType, oContainer, nNum);
        return;
    }
    else
    {
        while(nNum > 100)
        {
            nCount++;
            CreateItemOnObject(sType, oContainer, 100);
            nNum = nNum - 100;
            if(nCount >= 35)
                oContainer = oPC;
        }
        CreateItemOnObject(sType, oContainer, nNum);
    }
}
object GetExchangeNoteOfValue(int nValue, object oPC)
{
    object oNote = GetFirstItemInInventory(oPC);
    while(oNote != OBJECT_INVALID)
    {
        if(GetTag(oNote) == "crp_banknote")
        {
            if(GetLocalInt(oNote, "VALUE") >= nValue)
                return oNote;
        }
        oNote = GetNextItemInInventory(oPC);
    }

    return OBJECT_INVALID;
}
int InitContainer(object oBaseCont)
{
    int nItems = 1;
    object oTmp = GetFirstItemInInventory(oBaseCont);
    while(GetIsObjectValid(oTmp))
    {
        // Store the item and its base type as local vars on
        // the container object itself.
        string sIndex = IntToString(nItems);
        string sVar = "ITEM" + sIndex;
        SetLocalObject(oBaseCont, sVar, oTmp);
        nItems++;
        oTmp = GetNextItemInInventory(oBaseCont);
    }
    SetLocalInt(oBaseCont, "ITEM_COUNT", nItems);
    return nItems;
}
object StockStoreFromInventory(object oStore, object oInv, int nCount)
{
    object oItem;
    int nItems = GetLocalInt(oInv, "ITEM_COUNT");
    if(!(nItems >= 1))
        nItems = InitContainer(oInv);

    for(nCount = nCount; nCount >= 1; nCount--)
    {
        oItem = CopyItem(GetLocalObject(oInv, "ITEM" + IntToString(Random(nItems)+1)), oStore);
    }
    return oItem;
}
void ResetArmorStand(object oStand)
{
    //Determine where our item stock is
    string sArmorStock = GetLocalString(oStand, "ARMOR_STOCK");
    string sWeaponStock = GetLocalString(oStand, "WEAPON_STOCK");
    object oArmorStock = GetObjectByTag(sArmorStock);
    object oWeaponStock = GetObjectByTag(sWeaponStock);

    //Destroy the Current Items on the stand
    DestroyObject(GetItemInSlot(INVENTORY_SLOT_CHEST, oStand));
    DestroyObject(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oStand));

    //Put new items on the armor stand
    object oArmor = StockStoreFromInventory(oStand, oArmorStock, 1);
    object oWeapon = StockStoreFromInventory(oStand, oWeaponStock, 1);
    AssignCommand(oStand, ActionEquipItem(oArmor, INVENTORY_SLOT_CHEST));
    AssignCommand(oStand, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
}
void ResetStore(object oStore)
{
    location lLoc = GetLocation(oStore);
    string sResRef = GetLocalString(oStore, "RESREF");
    string sStock = GetLocalString(oStore, "STOCK");
    int nCount = GetLocalInt(oStore, "ITEM_COUNT");

    //Check to make sure this is a valid random reset merchant
    if(nCount == 0) return;

    DestroyObject(oStore);
    object oStock = GetObjectByTag(sStock);
    object oNewStore = CreateObject(OBJECT_TYPE_STORE, sResRef, lLoc);
    object oItem = StockStoreFromInventory(oNewStore, oStock, nCount);

    if(CRP_DEBUG)
    {
        SendMessageToPC(GetFirstPC(), "resef = " + sResRef);
        SendMessageToPC(GetFirstPC(), "stock = " + sStock);
        SendMessageToPC(GetFirstPC(), "count = " + IntToString(nCount));
    }
}
int GetBaseAC(object oArmor)
{
    int nNetAC = GetItemACValue(oArmor);
    int nBonus = IPGetWeaponEnhancementBonus(oArmor, ITEM_PROPERTY_AC_BONUS);
    return nNetAC - nBonus;
}
int GetBusy(object oObject)
{
    return GetLocalInt(oObject, "BUSY");
}
void SetBusy(object oObject, int nState)
{   //nState = TRUE/FALSE
    SetLocalInt(oObject, "BUSY", nState);
}
void AdjustAlignmentSinglePlayer(object oPC, int iAlignment, int iShift)
{
    object oPartyLeader = GetFirstFactionMember(oPC, TRUE);
    if(oPartyLeader == oPC)
    {
        oPartyLeader = GetNextFactionMember(oPC, TRUE);
        if(!GetIsObjectValid(oPartyLeader))
        {
            AdjustAlignment(oPC, iAlignment, iShift);
            return;
        }
    }
    RemoveFromParty(oPC);
    AdjustAlignment(oPC, iAlignment, iShift);
    AddToParty(oPC, oPartyLeader);
}
void CreateMerchant(string sResRef, location lLoc)
{
    object oMerch = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
    SetLocalInt(oMerch, "RANDOM", 1);
}
void crp_CreateNPCTreasure()
{
    if(d10() == 1)
    {
        GiveCoinsTo(OBJECT_SELF, d2(), COIN_GOLD);
    }
    if(d3() == 1)
    {
        GiveCoinsTo(OBJECT_SELF, d4(), COIN_SILVER);
    }
    GiveCoinsTo(OBJECT_SELF, d6(), COIN_COPPER);
}
int crp_ShowMerchantItem(int iSub)
{
    int iPage = GetLocalInt(oMerch, "PAGE");
    int iAdd = iPage * 6;
    string sSfx = IntToString(iSub + iAdd);

    string sItemName = GetLocalString(oMerch, "ITEM"+sSfx);
    string sItemRef = GetLocalString(OBJECT_SELF, "ITEMREF"+sSfx);
    string sCoinType = GetLocalString(OBJECT_SELF, "ITEMCOIN"+sSfx);
    int nCoinCost = GetLocalInt(OBJECT_SELF, "ITEMCOINNUM"+sSfx);

    if(sItemName != "")
    {
        string sAbrev = GetCoinFriendlyName(sCoinType);
        SetCustomToken(5000 + iSub, sItemName+" :  ");
        SetCustomToken(5010 + iSub, IntToString(nCoinCost)+" "+sAbrev);
        return TRUE;
    }
    else {
        SetLocalInt(oMerch, "SHOW_NO_MORE_ITEMS", TRUE);
        return FALSE; }
}
void crp_MakeMenuSelection(int iSub)
{
    object oPC = GetPCSpeaker();
    int iPage = GetLocalInt(oMerch, "PAGE");
    iSub = iSub + (iPage * 6);

    DeleteLocalInt(oPC, "MERCH_MENU_ITEM");
    DeleteLocalInt(oMerch, "SHOW_NO_MORE_ITEMS");

    string sSfx = IntToString(iSub);
    string sResRef = GetLocalString(oMerch, "ITEMREF"+sSfx);
    string sCoinType = GetLocalString(oMerch, "ITEMCOIN"+sSfx);
    int nCoinNum = GetLocalInt(oMerch, "ITEMCOINNUM"+sSfx);

    if(TakeCoinsMakeChange(oPC, nCoinNum, sCoinType))
        CreateItemOnObject(sResRef, oPC, 1);
    else
    {
        FloatingTextStringOnCreature("You don't have enough acceptable coin.", oPC, FALSE);
        return;
    }
}
void crp_ClearMerchMenuVars()
{
    object oPC = GetPCSpeaker();
    DeleteLocalInt(oPC, "MERCH_MENU_ITEM");
    DeleteLocalInt(oMerch, "SHOW_NO_MORE_ITEMS");
    DeleteLocalInt(oMerch, "PAGE");
}
void SetMerchantItem(int nListNum, string sItemName, string sItemResRef, int nCoinCost, string sCoinType)
{
    string sSfx = IntToString(nListNum);
    SetLocalString(OBJECT_SELF, "ITEM"+sSfx, sItemName);
    SetLocalString(OBJECT_SELF, "ITEMREF"+sSfx, sItemResRef);
    SetLocalString(OBJECT_SELF, "ITEMCOIN"+sSfx, sCoinType);
    SetLocalInt(OBJECT_SELF, "ITEMCOINNUM"+sSfx, nCoinCost);
}
