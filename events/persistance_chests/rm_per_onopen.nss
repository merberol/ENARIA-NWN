////////////////////////////////////////////////////////////////////////////////
//:: rm_per_onopen.nss                                                      :://
//:: Created by Charlie Simonsson                                           :://
//:: 2022 feb 25                                                            :://
////////////////////////////////////////////////////////////////////////////////


#include "persistance_inc"

// created chest table of table does not exists
// reurns 1 if the table was created
// returns 0 if table allready exists.
int do_db_check(object self);

// checks weather or not this chest has been opened since last server restart
// and thus have been initialized allready.
// return 1 if it has.
// returns 0 if this was the first time.
int do_init_check(object self);


// this function loads items from the db and fills the chest.
void init_chest(object self);

// parses a location as string
// "name at: (x: x, y: y, z: z)"
string location_as_string(location loc);

void main()
{

    object pc = GetLastOpenedBy();
    object self = OBJECT_SELF ;

    string table_name = GetLocalString(self, "table_name");

    if(table_name != GetTag(self))
    {
        WriteTimestampedLogEntry("this chest"+GetTag(self)+" in location: " + location_as_string(GetLocation(self)) + "is not properly configured!, Exiting script!");
        return;
     }

    int db_result = do_db_check(self);
    if( db_result )
    {
        WriteTimestampedLogEntry("created new table: "+ GetTag(self));
        return;
    }
    // WriteTimestampedLogEntry("table allready exists checking init");
    int init_result = do_init_check(self);

    if(init_result == TRUE)
    {
        /*
        chest is allready initialised for this session and we ca exit out
        */
        return;
    }
    init_chest(self);




}

int do_db_check(object self)
{

    string tableName = GetTag(self);
    int is_in_db = GetCampaignInt(DB_CHESTS, tableName);
    int is_init = GetLocalInt(self, "INIT");

    if(!is_in_db)
    {
        string query = "create table " +tableName+ " (\n";
        query     += "uuid varchar not null,\n";
        query     += "object blob not null,\n";
        query     += "name varchar not null,\n";
        query     += "amount int not null,\n";
        query     += "unique(uuid));";
        sqlquery sqlQuery =  SqlPrepareQueryCampaign(DB_CHESTS, query);
        int result = SqlStep(sqlQuery);
        SetCampaignInt(DB_CHESTS, tableName, 1);
        return 1;
    }
    return 0;
}


int do_init_check(object self)
{
    return GetLocalInt(self, "INIT");
}


void init_chest(object self)
{
    // create sql statment
    string tableName = GetTag(self);
    string query = "select uuid, object, name, amount from "+tableName+";";
    sqlquery sqlQuery =  SqlPrepareQueryCampaign(DB_CHESTS, query);

    // execute statment
    // iterate thrugh the responses of the statment and add objects to chest
    while(SqlStep(sqlQuery))
    {
        string uuid = SqlGetString(sqlQuery, 0);
        object item = SqlGetObject(sqlQuery, 1, GetLocation(self), self, TRUE);
        string name = SqlGetString(sqlQuery, 2);
        int amount = SqlGetInt(sqlQuery, 3);
        if(GetObjectUUID(item) != uuid)
        {
            WriteTimestampedLogEntry("OBJECT UUID NOT MATCHING");
        }
        if(GetItemStackSize(item) != amount)
        {
            SetItemStackSize(item, amount);
            WriteTimestampedLogEntry("OBJECT STACK SIZE NOT MATCHING");
        }

    }
    // set local int "INIT" to 1
    SetLocalInt(self, "INIT", 1);
    return;

}

string location_as_string(location loc)
{
    string name = GetName(GetAreaFromLocation(loc));
    vector pos = GetPositionFromLocation(loc);
    string x = IntToString(FloatToInt(pos.x));
    string y = IntToString(FloatToInt(pos.y));
    string z = IntToString(FloatToInt(pos.z));

    return name + ": at (x: " +x+", y: " + y + ", z: " + z +")";
}
