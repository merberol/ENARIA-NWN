////////////////////////////////////////////////////////////////////////////////
//:: rm_per_ondistrbd.nss                                                   :://
//:: Created by Charlie Simonsson                                           :://
//:: 2022 feb 25                                                            :://
////////////////////////////////////////////////////////////////////////////////

#include "persistance_inc"

void main()
{
    object chest = OBJECT_SELF;
    object item = GetInventoryDisturbItem();
    int type = GetInventoryDisturbType();
    object pc = GetLastDisturbed();
    string tableName = GetTag(chest);

    if( type == INVENTORY_DISTURB_TYPE_ADDED )
    {
        if (GetBaseItemType(item) == BASE_ITEM_GOLD)
        {
            SendMessageToPC(pc, "Do not place gold here it will divide by 0 and end the world...");
            int amount = GetItemStackSize(item);
            DestroyObject(item);
            GiveGoldToCreature(pc, amount);
            return;
        }

        if(tableName == "")
        {
            SendMessageToPC(pc, "Invalid tag");
            return;
        }
        string sQuery = "insert into "+tableName+" (uuid,object,name,amount)  values(@uuid, @object, @name, @amount);";
        sqlquery sqlQuery = SqlPrepareQueryCampaign(DB_CHESTS, sQuery);
        string uuid = GetObjectUUID(item);
        string name = GetName(item);
        int amount = GetItemStackSize(item);
        SetLocalString(item, "DB_UUID", uuid);
        SqlBindString(sqlQuery, "@uuid", uuid );
        SqlBindObject(sqlQuery, "@object", item, TRUE);
        SqlBindString(sqlQuery, "@name", name);
        SqlBindInt(sqlQuery, "@amount", amount);
        int result = SqlStep(sqlQuery);
        sqlquery n = SqlPrepareQueryCampaign(DB_CHESTS, "select object from "+tableName+" where uuid = @uuid;");
        SqlBindString(n, "@uuid", uuid );
        result = SqlStep(n);
        if(result)
        {



            SendMessageToPC(pc, "" + IntToString(GetItemStackSize(item)) + " of item: " + GetName(item)
                                 + " was just added to "
                                 + GetName(chest)
                                 + " by "
                                 + GetName(pc) + " with result " + IntToString(result) );
        }
    }
    if( type == INVENTORY_DISTURB_TYPE_REMOVED || type == INVENTORY_DISTURB_TYPE_STOLEN )
    {
         string db_uuid = GetLocalString(item, "DB_UUID");
        SendMessageToPC(pc, " removing item" + GetName(item) + " from db with db uuid: " + db_uuid);

        string sQuery = "delete from "+tableName+" where uuid = @uuid;";

        sqlquery sqlQuery = SqlPrepareQueryCampaign(DB_CHESTS, sQuery);
        string uuid = GetObjectUUID(item);



        SqlBindString(sqlQuery, "@uuid", db_uuid );

        int result = SqlStep(sqlQuery);

        if(result)
        {
            SendMessageToPC(pc, "" + IntToString(GetItemStackSize(item)) + " of item: " + GetName(item)
                                 + " was just removed from "
                                 + GetName(chest)
                                 + " by "
                                 + GetName(pc) );
       }
    }
    if( type == INVENTORY_DISTURB_TYPE_STOLEN )
    {
        SendMessageToPC(pc, "" + IntToString(GetItemStackSize(item)) + " of item: " + GetName(item)
                                 + " was just stolen from "
                                 + GetName(chest)
                                 + " by "
                                 + GetName(pc) );
    }

}
