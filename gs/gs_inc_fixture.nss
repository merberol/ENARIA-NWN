/* FIXTURE library by Gigaschatten */

#include "gs_inc_location"

//void main() {}

//load nLimit objects from database sID
void gsFXLoadFixture(string sID, int nLimit = 40);
//save oFixture to database sID containing a maximum of nLimit objects and return TRUE on success
int gsFXSaveFixture(string sID, object oFixture = OBJECT_SELF, int nLimit = 40);
//delete oFixture from database sID containing a maximum of nLimit objects
void gsFXDeleteFixture(string sID, object oFixture = OBJECT_SELF, int nLimit = 40);

void gsFXLoadFixture(string sID, int nLimit = 40)
{
    location lLocation;
    string sTemplate    = "";
    string sTag         = "";
    string sNth         = "";
    int nNth            = 0;
    object oPlace       = OBJECT_INVALID;
    string sDescription = "";
    string sName        = "";

    for (nNth = 1; nNth <= nLimit; nNth++)
    {
        sNth = IntToString(nNth);

        if (GetCampaignInt("GS_FX_" + sID, "SLOT_" + sNth))
        {
            sTemplate    = GetCampaignString("GS_FX_" + sID,"TEMPLATE_" + sNth);
            lLocation    = gsLOGetDBLocation("GS_FX_" + sID,"LOCATION_" + sNth);
            sDescription = GetCampaignString("GS_FX_" + sID,"DESCRIPT_" + sNth);
            sName        = GetCampaignString("GS_FX_" + sID,"NAME_"     + sNth);
            sTag         = GetCampaignString("GS_FX_" + sID,"TAG_"      + sNth);
            oPlace       = CreateObject(OBJECT_TYPE_PLACEABLE, sTemplate, lLocation,FALSE,sTag);
            SetLocalInt(oPlace,"nNth",nNth);
            SetName(oPlace,sName);
            SetDescription(oPlace,sDescription);
            WriteTimestampedLogEntry("Created Placeable called "+GetName(oPlace)+" in "+GetName(GetArea(oPlace)));
            //SendMessageToAllDMs("Created Placeable called "+GetName(oPlace)+" in "+GetName(GetArea(oPlace)));
        }
    }
}
//----------------------------------------------------------------
int gsFXSaveFixture(string sID, object oFixture = OBJECT_SELF, int nLimit = 40)
{
    string sNth = "";
    int nNth    = 0;

    for (nNth = 1; nNth <= nLimit; nNth++)
    {
        sNth = IntToString(nNth);

        if (! GetCampaignInt("GS_FX_" + sID, "SLOT_" + sNth))
        {
            SetCampaignInt(      "GS_FX_" + sID, "SLOT_"     + sNth, TRUE);
            SetCampaignString(   "GS_FX_" + sID, "TEMPLATE_" + sNth, GetResRef(oFixture));
            gsLOSetDBLocationOf( "GS_FX_" + sID, "LOCATION_" + sNth, oFixture);
            SetCampaignString(   "GS_FX_" + sID, "DESCRIPT_" + sNth, GetDescription(oFixture));
            SetCampaignString(   "GS_FX_" + sID, "NAME_"     + sNth, GetName(oFixture));
            SetCampaignString(   "GS_FX_" + sID, "TAG_"      + sNth, GetTag(oFixture));
            SetLocalInt(oFixture,"nNth",nNth);
            WriteTimestampedLogEntry("Saved Placeable called "+GetName(oFixture)+" in "+GetName(GetArea(oFixture)));
            //SendMessageToAllDMs("Saved Placeable called "+GetName(oFixture)+" in "+GetName(GetArea(oFixture)));
            return TRUE;
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
void gsFXDeleteFixture(string sID, object oFixture = OBJECT_SELF, int nLimit = 40)
{
    struct gsLOLocation gsLocation = gsLOGetLocationX(oFixture);
    int nNth                       = GetLocalInt(oFixture,"nNth");
    string sNth                    = IntToString(nNth);

    SetCampaignInt("GS_FX_" + sID, "SLOT_" + sNth, FALSE);
    WriteTimestampedLogEntry("Deleted Placeable called "+GetName(oFixture)+" in "+GetName(GetArea(oFixture)));
    //SendMessageToAllDMs("Deleted Placeable called "+GetName(oFixture)+" in "+GetName(GetArea(oFixture)));
}
