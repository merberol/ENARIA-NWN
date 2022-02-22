//:://////////////////////////////////////////////////
//:: Originally X0_I0_WALKWAY
//:: aww_inc_walkway

/*
  Include library holding the code for aww_WalkWayPoints.
 */

//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/07/2002
//:://////////////////////////////////////////////////
//:: Updated On : 2003/09/03 - Georg Zoeller
//::                           * Added code to allow area transitions if global integer
//::                             X2_SWITCH_CROSSAREA_WALKWAYPOINTS set to 1 on the module
//::                           * Fixed Night waypoints not being run correcty
//::                           * XP2-Only: Fixed Stealth and detect modes spawnconditions
//::                             not working
//::                           * Added support for SleepAtNight SpawnCondition: if you put
//::                             a string on the module called X2_S_SLEEP_AT_NIGHT_SCRIPT,
//::                             pointing to a script, this script will fire if it is night
//::                             and your NPC has the spawncondition set
//::                           * Added the ability to make NPCs turn to the facing of
//::                             a waypoint when setting int X2_L_WAYPOINT_SETFACING to 1 on
//::                             the waypoint

//:: revised, reworked and rewritten by meaglyn 08/13/2012
//:: aww code copyright meaglyn 2012
//::


/* --------------------------------------------------------------------
  Advanced Walk Waypoints (AWW) README

  by Meaglyn.

  Release: version 1.0


Overview of features;

    Cleans up WP handling not to skip and not to react on every perception event.

    Allows linear, random and circular walk patterns.

    Allows WPs to have animations the NPC will perform at each, before moving on.

    Allows any custom script to be executed at WP arrival.

    Allows WP walking to be paused (picking up where left off when resumed)
             and disabled (re-initializing when re-enabled).

    Provides for Dusk/Dawn, Morning, Afternoon, Evening, Night and default waypoint sets
    to allow for more interesting schedules.

    Works with existing waypoint setups as is (uses WP_, WN_, POST_, NIGHT_ etc).

    Supports virtual tags on NPC, allowing an NPC to use a different set of waypoints for a while
    or under different conditions and then revert when needed.

    Provides a basic activity system where an NPC can be made to sleep, sit, putter or do something else,
    for a time or until the WP schedule changes.

    Has stuck walker detection.



Nothing is created in a vacuum however so thanks to :

Some concepts and ideas (and possibly a few remaining small code snippets) are from Axe Murderer's KWW system:
     http://nwvault.ign.com/View.php?view=Hakpaks.Detail&id=16716&id=7066

The activities system was inspired by Carcerian's Ultima activities:
    http://nwvault.ign.com/View.php?view=Scripts.Detail&id=3480

ts_putter support is by Tesramed, and is unmodified. You may download that from the vault and include
the ts_putter.nss file in your module. It's not included in the erf (but is in the test module):
    http://nwvault.ign.com/View.php?view=Scripts.Detail&id=1744

The concept of a vTag is from NPC Activities.
    http://nwvault.ign.com/View.php?view=Scripts.Detail&id=2483


 This is re-written walkway points mechanism that is much more powerful than the original.
 FIrst it fixes a few idosyncracies of the bioware version. Primarily it does not skip waypoints
 when interrupted or when called multiple times (like when entering a new area). The NPC will
 continue to it's current target WP when it restarts walking after a conversation for example.
 It also throttles calls to walkwaypoints triggered by the perception event. This keeps all
 the NPCs from getting messed up when a characted enters the area.

 The system is designed to work with existing placed waypoints. To use it you simply add the
 main scripts to your module. And change NPC HB,perception, and spawn in scripts to call
 aww_WalkWayPoints() everywhere WalkWayPoints() is called. Modified versions of the default
 Bioware AI files are included in the overwrite erf. Use anw_c2_default1 and anw_c2_default2
 for HB and Perception events. Use anw_c2_default9 (or make similar changes to your onspawn
 handler.)Be sure to #include "aww_inc_walkway" in each file modified. You may either change
 conversations to end with aww_walk_wp, or copy it to nw_walk_wp (included in the overwrite
 version), to call aww_WalkWayPoints(). Then rebuild your module. Things should function
 pretty much exaclty as before, with the main difference described above. The system respects
 X2_SWITCH_CROSSAREA_WALKWAYPOINTS and X2_L_WAYPOINT_SETFACING, and X2_S_SLEEP_AT_NIGHT_SCRIPT,
 although the latter is better implemented using the sleep activity.


 New features and benefits :

 Each NPC can have up to 6 sets of waypoints instead of the normal 2. This is NOT dependent on
 the spawn flag NW_FLAG_DAY_NIGHT_POSTING, unlike WN_ and NIGHT_. If you don't paint WPs
 other "WP" or "POST" you don't get other postings. NW_FLAG_DAY_NIGHT_POSTING causes some of
 the HB scripts to skip calling walkwaypoints when we'd really like it to be called.
 Aww_walkwaypoints can disable this setting so that things work better.

 There are now morning (WM_), afternoon (WA_),  evening (WE_) and dawn/dusk (WD_) waypoints
 along with the original WP_ and WN_ waypoints. POST_ and NIGHT_ behave as before.
 The definition of those time periods can be tuned below. Morning is defined to be
 from AWW_MORNING_START (inclusive) to AWW_AFTERNOON_START (exclusive)
 (e.g. morning is >= 6 and < 12, so 6 through 11). The effect of POST and NIGHT_ can be
 achieved for the other times of day by simply having only one valid WP in the set.
 If other times are not found the search falls back to basic WP_ just as it does with WN_.

 There is also a WD_ set which applies at both dawn and dusk (as defined by the module settings).
 This generally will be a post (i.e. single waypoint) which is placed at or near the place
 where the NPC will be sleeping at night. This allows the system to move the NPC to the right
 place before night kicks in and the NPC drops to sleep.

 NPCs can have a virtual tag set on them. This effects which waypoints they use.
 Changing the vritual tag causes the NPC to re-initialize WPs with the new tag and
 start walking new points. This can be a really powerful feature. You can now share
 waypoints. You can make people walk on the same path to get from one place to another.
 You can make any NPC who enters the area start marching around the room...

 Waypoint walking can be paused or disabled on a NPC. Both have the effect of stopping the NPC
 from walking points. When a Paused NPC is unpaused it will try to pick up where it left off.
 When a disabled walker is re-enabled it will re-initialize it's walking and start over (usually
 with the nearest way point in the current set).

 Waypoint walkers can go in a circular or random order along with the usual up and then back down.

 On reaching a waypoint an NPC can execute a WP defined script, play a WP defined animation, or just
 use a WP defined or argument defined pause and move on. The script can do anything it needs to. It may
 pause waypoints and have the NPC do who knows what before restarting his/her walk.

 waypoints can be indivually disabled/re-enabled. A disabled waypoint will not be selected as a walking target.
 an NPC which currently has the waypoint as a destination will continue to it. But deisabled waypoints do not
 do normal waypoint arrival processing, so he/she will just move on.

 The system should not be messed up by calls the regular WalkWayPoints although they will not do anything
 once aww_WalkWayPoints has been called for an NPC. However, it is cleaner to use modified spawn/perception
 and HB scripts, as well as conversation end/abort scripts, which call AWW directly. Basic versions of these
 are included in the demo module.

 AWW includes two mechanisms to ensure walkers don't get stuck. The first and simplest is to use force move
 for the walking. This can be done globally by making sure AWW_USE_FORCEMOVE is set to TRUE in aww_inc_walkway.
 The timeout is controlled by  AWW_FORCEMOVE_TIMEOUT and defaults to 30.0. You can also set the timeout on a
 per NPC basis using a float variable  X2_L_WALKWAY_FORCE_MOVE specifying the timeout. Setting this to > 0.0
 will cause that NPC to use force move with the given timeout even when AWW_USE_FORCEMOVE is FALSE.

 The other method, which is not needed if using force, is stuck detection. This is enabled globally only, with
 AWW_STUCK_DETECTION = TRUE in aww_inc_walkway. This will detect when a walker has not made progress an attempt
 to move around a bit and try again to reach the next WP. If this moving around fails the NPC is finally jumped
 to the WP. This may make things a little more realistic than using force move, but when really stuck there will
 still be jumps. Both force and stuck detection are not needed at the same time. The stuck detection usually
 prevents any forcemove timeouts (unless set really low).

 AWW also includes an activity driver script which is started by arrival at a waypoint by setting
 the waypoint's script to aww_start_act. This will pause the waypoint walking for either given time
 or until the NPCs waypoint set changes (e.g. morning becomes afternoon). While running the activity
 normal calls to aww_walkwaypoints will instead  execute an activity script.  There are a few
 activities like sleeping, sitting, playing mobile ambient animations etc. As well as support for
 ts_puttering by Tseramed. Other scripts like one of the Heartbeat base barmaid scripts would also work.

 This allows for a fairly simple way to have NPCs do interesting things.

 The system also is the framework for a larger movement system. The NPC can have a destination WP
 and destination WP script set on her. If the NPC ever arrives at that waypoint it will execute
 the destination WP script instead of normal arrival code. This would be used to have the NPC move
 from one place to another using waypoints (of some other tag like road1) down the middle of a road
 to get to the destination and then revert to reat tag and enter the temple or whatever. That system is
 under development, but the hooks to set the destination and react to it are in place in AWW.

HOWTO:

  WayPoint Variables :

   AWW_DISABLE    :  int (as boolean) When set the waypoint is skipped when selecting next waypoint and won't
                      execute any arrival script (if disabled while NPC already heading for it).
              Can use aww_SetWPDisabled(object oWay, int bSet = TRUE) to toggle this as well.
   AWW_WP_SCRIPT  :  string name of script to execute (as the creature) on arrival at this WP.
   AWW_PAUSE      :  float override the pause setting given given when the creature called aww_WalkWayPoints.



   AWW_WP_ANIMATION: int animation to play instead of just pausing - use only looping or fireforget
                     animations (1-31 or 101-117). If fPause is > 0.0 will pause, play animation, pause
             before moving to next WP.

   AWW_WP_ANIMATION_SPEED:     float speed to use with animation
   AWW_WP_ANIMATION_DURATION:   float duration to play animation


   NPC variables :

   AWW_WALK_TYPE : optional int on creature to define what walk type to use. Can be set to one of
              AWW_WALK_TYPE_NORMAL , AWW_WALK_TYPE_CIRCULAR or AWW_WALK_TYPE_RANDOM. Otherwise
          the NPC will use AWW_WALK_TYPE_NORMAL by default. This can also be set by using SetWalkCondition
          Whenever the NPC re-inits way points (which happens if the vTag is changed) this variable
          is used so any manual SetWalkCondition changes are overwritten.

   AWW_NOWP_SCRIPT : optional script to execute when the creature has no waypoint to move to.

   AWW_DEST_WP : object, a "final" destination WP. The system will execute AWW_DEST_SCRIPT
                 when this dest is reached instead of normal wp arrival processing.
         use  aww_SetWalkDestination to set this up on the NPC.
   AWW_DEST_SCRIPT: string scriptname

   AWW_LAX_POST: optional int on NPC. By default an NPC with a single waypoint in a set (i.e. a POST)
               will move to that post and stay right on it, moving back if he/she moved off of it.
           If this is set to non-zero, the NPC will move to his/her post the initial time, but then
           not move back to it when dragged away for something else. This is useful for NPCs who
               will be doing things at the waypoint area but are not running an activity or pausing aww.
           (i.e. they want to still use aww's mechanism to move among timebased waypoint sets but not
           to stand right on top of or keep moving back to the current "post").

   AWW_POST_DISTANCE : float, if AWW_LAX_POST is not set, this controls how far away the NPC can get from
              the current post before aww will move him/her back. Default is 2.0. Putting in a large number
          has the same effect as AWW_LAX_POST, but is a bit more CPU intensive.

           NOTE: a "post" is really just any waypoint set with only one currently enabled WP in it.

   X2_L_WALKWAY_FORCE_MOVE : float. if set to > 0.0 the NPC will use force move with this value as the timeout
          This will ensure the NPC gets to the destination.


   Activity Subsystem:
      On the WP:
             set AWW_WP_SCRIPT to aww_start_act.

      On the NPC or the waypoint - the NPC settings override the waypoint settings:
             AWW_CUSTOM_ACTIVITY_SCRIPT controls the script to run. If unset either
          ts_putter or aww_do_activity will be used depending on the value of AWW_CUSTOM_ACTIVITY.

             AWW_CUSTOM_ACTIVITY : int. Which activity to perform. If unset and the script is "" ts_putter is used instead
               Otherwise this should be one of the valid AWW_ACTIVITY_* constants.

             AWW_CUSTOM_ACTIVITY_DURATION: float, duration to use the script instead of walking waypoints. If unset
         the script is used until the NPCs waypoint set changes (e.g. morning becomes afternoon).


------------------------------------

Included are modified versions of default AI scripts which normally call walkwaypoints.
     nw_c2_default1.nss
     nw_c2_default2.nss
     nw_c2_patrol1.nss
     nw_walk_wp.nss

     anw_c2_default9.nss

*/
#include "x0_i0_spawncond"
#include "x0_i0_walkway"
#include "x0_i0_position"

//#include "tb_inc_util"
//#include "00_debug"

/**********************************************************************
 * CONSTANTS
 **********************************************************************/

const string AWW_STUCK_LOCATION = "aww_last_loc";
const string AWW_STUCK_COUNT    = "aww_stuck_count";

// This is a global setting. You can also make walkers use
// force move by setting a float X2_L_WALKWAY_FORCE_MOVE on the NPC to the desired timeout value
const int AWW_USE_FORCEMOVE    = FALSE;
const float AWW_FORCEMOVE_TIMEOUT = 30.0;

// This controls the use of the stuck detection logic. Using both force and stuck detection is
// not usually needed.
const int AWW_STUCK_DETECTION  = FALSE;


// These are defined in "x0_i0_walkway" since that is included by nw_i0_generic
// we can't keep other scripts from importing it so these are here for reference.


/*const string sWalkwayVarname = "NW_WALK_CONDITION";

// If set, the creature's waypoints have been initialized.
const int NW_WALK_FLAG_INITIALIZED                 = 0x00000001;

// If set, the creature will walk its waypoints constantly,
// moving on in each OnHeartbeat event. Otherwise,
// it will walk to the next only when triggered by an
// OnPerception event.
const int NW_WALK_FLAG_CONSTANT                    = 0x00000002;

// Set when the creature is walking day waypoints.
const int NW_WALK_FLAG_IS_DAY                      = 0x00000004;

// Set when the creature is walking back
const int NW_WALK_FLAG_BACKWARDS                   = 0x00000008;
  */
const int AWW_WALK_FLAG_INIT                       = 0x00000010;
const int AWW_WALK_FLAG_PAUSED                     = 0x00000020;
const int AWW_WALK_FLAG_DISABLED                   = 0x00000040;

const int AWW_WALK_FLAG_CIRCULAR                   = 0x00000100;
const int AWW_WALK_FLAG_RANDOM                     = 0x00000200;
const int AWW_WALK_FLAG_CIRCREV                    = 0x00000400;

const int AWW_WALK_TYPE_NORMAL                     = 1;
const int AWW_WALK_TYPE_CIRCULAR                   = 2;
const int AWW_WALK_TYPE_RANDOM                     = 3;
const int AWW_WALK_TYPE_CIRCREV                    = 4;

const int AWW_ACTIVITY_NONE                        = 0;
const int AWW_ACTIVITY_AVOIDPC                     = 1;
const int AWW_ACTIVITY_SLEEP                       = 2;
const int AWW_ACTIVITY_SIT                         = 3;
const int AWW_ACTIVITY_MOBILE                      = 4;
const int AWW_ACTIVITY_IMMOBILE                    = 5;
const int AWW_ACTIVITY_RANDOM                      = 6;

const int AWW_MORNING_START                        = 6;
const int AWW_AFTERNOON_START                      = 12;
const int AWW_EVENING_START                        = 18;
const int AWW_NIGHT_START                          = 23;

/**********************************************************************
 * FUNCTION PROTOTYPES
 **********************************************************************/

// Get whether the condition is set
/*int GetWalkCondition(int nCondition, object oCreature=OBJECT_SELF);

// Set a given condition
void SetWalkCondition(int nCondition, int bValid=TRUE, object oCreature=OBJECT_SELF);

// Get a waypoint number suffix, padded if necessary
string GetWaypointSuffix(int i);
  */

// Set or clear the paused condition on the creature's waypoint walking
// this is just a wrapper to SetWalkCondition
// Pausing keeps the walkers waypoint state in tact so that a resume picks up
// walking where it left off.
void aww_SetWalkPaused(int bValid=TRUE, object oCreature=OBJECT_SELF);

// Set or clear the disabled condition of the creature's waypoint walking
// Disabling is different from pause mostly in that it causes a re-init when
// re-enabled.
void aww_SetWalkDisabled(int bValid=TRUE, object oCreature=OBJECT_SELF);

// mark a waypoint disabled (or re-enable it).
// Disabled WPs do not execute commands on arrival
// and are, for the most part, skipped when selecting the next waypoint.
void aww_SetWPDisabled(object oWay, int bSet = TRUE);


// virtual tag support
//
// Get the given NPCs current tag. If there is no virtual tag set
// this is just normal GetTag
string aww_GetTag(object oNPC);

// Set the virtual tag on the give oNPC.
// Virtual tags are tags which supercede the
// objects real tag for us with waypoint walking.
// Using sTag = "" clears the virtual tag.
void aww_SetVTag(object oNPC, string sTag) ;


// Get the index of the current waypoint
int aww_GetIdxFromWP(object oWay);

// Get the correct way point set for this creature base
// on the current time and what WPs were found  for the NPC
string aww_GetWPSet();
// Set or clear the destination waypoint and script for this NPC
// Use INVALID_OBJECT for oDest to clear the settings.
// Upon arrival at the given way point the NPC will execute this script instead
// of any of the normal arrival code (like the script on the WP or the normal pause).
// It will then call back into aww_WalkWayPoints to keep the NPC moving.
// the executed script may well want to pause or disable WP walking.
void aww_SetWalkDestination(object oDest, string sScript = "", object oNPC = OBJECT_SELF);

// Return the currently set final destination WP or INVALID
object aww_GetWalkDestWP(object oNPC = OBJECT_SELF);

// Return the currently set final destination script or ""
string aww_GetWalkDestScript(object oNP = OBJECT_SELF);

// This reads an optional variable on the creature
// to configure how it should walk. If unset no
// changes are made to the walk settings.
void aww_ConfigureWalkType() ;

void aww_InitWalkWays(int bRun, float fPause);


// Get the creature's next waypoint.
// If it has just become day/night/morning/afternoon/evening, or if this is
// the first time we're getting a waypoint, we go
// to the nearest waypoint in our new set.
object aww_GetNextWalkWayPoint();

// Get object of the nearest of the creature's current
// set of waypoints. return OBJECT_INVALID if there are no WPs in the current set
// If there is no WP in the current area but there are others it will
// return the first one found, not necessarily the nearest.
object aww_GetNearestWalkWayPoint();

// check if there is an activity to do and do it instead of walking WPs.
int aww_DoActivity();

// Do the work at the waypoint.
void aww_WayPointArrive(object oWay) ;

// Make the caller walk through their waypoints or go to their post.
// This is the main entry point and should be called wherever code used to call WalkWayPoints()
void aww_WalkWayPoints(int nRun = FALSE, float fPause = 1.0);

// Check to make sure that the walker has at least one valid
// waypoint to walk to at some point.
int aww_CheckWayPoints(object oWalker = OBJECT_SELF);

// Check to see if the specified object is currently walking
// waypoints or standing at a post.
int aww_GetIsPostOrWalking(object oWalker = OBJECT_SELF);

void aww_DumpWayPoints(object oNPC);

/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/

// Get whether the specified WalkWayPoints condition is set
/* int GetWalkCondition(int nCondition, object oCreature=OBJECT_SELF)
{
    return (GetLocalInt(oCreature, sWalkwayVarname) & nCondition);
}

// Set a given WalkWayPoints condition
void SetWalkCondition(int nCondition, int bValid=TRUE, object oCreature=OBJECT_SELF)
{
    int nCurrentCond = GetLocalInt(oCreature, sWalkwayVarname);
    if (bValid) {
        SetLocalInt(oCreature, sWalkwayVarname, nCurrentCond | nCondition);
    } else {
        SetLocalInt(oCreature, sWalkwayVarname, nCurrentCond & ~nCondition);
    }
}
// Get a waypoint number suffix, padded if necessary
string GetWaypointSuffix(int i)
{
    if (i < 10) {
        return "0" + IntToString(i);
    }
    return IntToString(i);
}

*/
// Set DEBUG on the module to non-zero to get the
// debug output. It's fairly verbose.
// For real use you may want to comment out all the code
// in this function.
void aww_debug(string sMsg) {
    if (GetLocalInt(GetModule(), "DEBUG"))
        SendMessageToPC(GetFirstPC(), sMsg);
    //dblvl(DEBUGLEVEL_AWW |  DEBUG_COLOR_6, sMsg);
}

// You will want to adjust this function for multiplayer
void aww_error(string sMsg) {
    SendMessageToPC(GetFirstPC(), "ERROR: " + sMsg);
    //WriteTimestampedLogEntry("ERROR: " + sMsg);
}

// Set or clear the paused condition on the creature's waypoint walking
// this is just a wrapper to SetWalkCondition
// Pausing keeps the walkers waypoint state in tact so that a resume picks up
// walking where it left off.
void aww_SetWalkPaused(int bValid=TRUE, object oCreature=OBJECT_SELF) {

    SetWalkCondition(AWW_WALK_FLAG_PAUSED, bValid, oCreature);
}

// Set or clear the disabled condition of the creature's waypoint walking
// Disabling is different from pause mostly in that it causes a re-init when
// re-enabled.
void aww_SetWalkDisabled(int bValid=TRUE, object oCreature=OBJECT_SELF) {

    int bSet = GetWalkCondition(AWW_WALK_FLAG_DISABLED, oCreature);
    if (bSet && !bValid) {
        // it was disabled and we're enabling it - make sure we re-init
        SetWalkCondition(AWW_WALK_FLAG_INIT, FALSE, oCreature);
        SetWalkCondition(AWW_WALK_FLAG_PAUSED, FALSE, oCreature);
        // stop any activities too
        DeleteLocalString(OBJECT_SELF, "AWW_DO_ACTIVITY_SCRIPT");
    DeleteLocalObject(OBJECT_SELF, "aww_current_chair");
    }
    aww_debug("Setwalkdisabled for " + GetTag(oCreature) + " to " + IntToString(bValid));
    SetWalkCondition(AWW_WALK_FLAG_DISABLED, bValid, oCreature);
}


// mark a waypoint disabled (or re-enable it).
// Disabled WPs do not execute commands on arrival
// and are, for the most part, skipped when selecting the next waypoint.
void aww_SetWPDisabled(object oWay, int bSet = TRUE) {

    if (GetIsObjectValid(oWay)) {
        if (!bSet) {
            DeleteLocalInt(oWay, "AWW_DISABLE");
        } else {
            SetLocalInt(oWay, "AWW_DISABLE" , 1);
        }
    }
}


// virtual tag support
//
//
// Get the given NPCs current tag. If there is no virtual tag set
// this is just normal GetTag
string aww_GetTag(object oNPC) {
    if (!GetIsObjectValid(oNPC))
        return "";

    string sVtag = GetLocalString(oNPC, "VIRTUAL_TAG");
    if (sVtag != "")
        return sVtag;

    return GetTag(oNPC);
}

// Set the virtual tag on the give oNPC.
// Virtual tags are tags which supercede the
// objects real tag for us with waypoint walking.
// Using sTag = "" clears the virtual tag.
void aww_SetVTag(object oNPC, string sTag) {
    if (GetIsObjectValid(oNPC)) {
        if (sTag == "")
            DeleteLocalString(oNPC, "VIRTUAL_TAG");
        else
            SetLocalString(oNPC, "VIRTUAL_TAG", sTag);
    }
}

// Set or clear the destination waypoint and script for this NPC
// Use INVALID_OBJECT for oDest to clear the settings.
// Upon arrival at the given way point the NPC will execute this script instead
// of any of the normal arrival code (like the script on the WP or the normal pause).
// It will then call back into aww_WalkWayPoints to keep the NPC moving.
// the executed script may well want to pause or disable WP walking.
void aww_SetWalkDestination(object oDest, string sScript = "", object oNPC = OBJECT_SELF) {
    if (!GetIsObjectValid(oDest) || sScript == "") {
        DeleteLocalObject(oNPC, "AWW_DEST_WP");
        DeleteLocalString(oNPC, "AWW_DEST_SCRIPT");
        return;
    }

    SetLocalObject(oNPC, "AWW_DEST_WP", oDest);
    SetLocalString(oNPC, "AWW_DEST_SCRIPT" , sScript);

    aww_debug("aww_SetWalkDest : " + GetTag(oNPC) + " dest " + GetTag(oDest) + " execute " + sScript);
}

// Return the currently set final destination WP or INVALID
object aww_GetWalkDestWP(object oNPC = OBJECT_SELF) {
    return GetLocalObject(oNPC, "AWW_DEST_WP");
}

// Return the currently set final destination script or ""
string aww_GetWalkDestScript(object oNPC = OBJECT_SELF) {
    return GetLocalString(oNPC, "AWW_DEST_SCRIPT");
}



// Get the index of the current waypoint
int aww_GetIdxFromWP(object oWay) {

    if (!GetIsObjectValid(oWay))
        return -1;


    string sTmp = GetStringRight(GetTag(oWay), 2);
    int nIdx = StringToInt(sTmp);
    if (nIdx == 0) {
        if (GetStringLeft(GetTag(oWay), 6) == "NIGHT_")
                nIdx = 1;
        if (GetStringLeft(GetTag(oWay), 5) == "POST_")
            nIdx = 1;
    }

    //aww_debug("GetIdxfromWP " + GetTag(oWay) + " got " + sTmp + " = " + IntToString(nIdx));
    return nIdx;
}

// Get the correct way point set for this creature base
// on the current time and what WPs were found  for the NPC
string aww_GetWPSet() {
    int nHour = GetTimeHour();
    int nWP   = GetLocalInt(OBJECT_SELF, "AWW_WP_NUM");
    int nWX   = -1;
    string sDef = "WP_";
    if (nWP <= 0)
        sDef = "NONE_";

    int nWN = GetLocalInt(OBJECT_SELF, "AWW_WN_NUM");
    string sNdef = "WN_";
    if (nWN <= 0)
        sNdef = sDef;

        // Stopped respecting DAY_NIGHT_POSTING not being set...
   // aww_debug("getwpset, hour " + IntToString(nHour) + " WP = " + IntToString(nWP)
   //     + " WN= " + IntToString(nWN) + " sdef = " + sDef + " sNdef = " + sNdef);
    // no DAY/NIGHT posting so always day.
    //if( !GetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING)) {
    //    return sDef;
    // }

    // this is not exclusive - just use the WD one if it exists otherwise do the normal time based code
    if (GetIsDawn() || GetIsDusk()) {
        nWX = GetLocalInt(OBJECT_SELF, "AWW_WD_NUM");
        if (nWX > 0)
            return "WD_";
    }

    if (nHour >= AWW_MORNING_START && nHour < AWW_AFTERNOON_START) {
        nWX = GetLocalInt(OBJECT_SELF, "AWW_WM_NUM");
        if (nWX > 0)
            return "WM_";
        return sDef;

    } else if (nHour >= AWW_AFTERNOON_START && nHour < AWW_EVENING_START) {
        nWX = GetLocalInt(OBJECT_SELF, "AWW_WA_NUM");
        if (nWX > 0)
            return "WA_";
        return sDef;

    } else if (nHour >= AWW_EVENING_START && nHour < AWW_NIGHT_START) {
        nWX = GetLocalInt(OBJECT_SELF, "AWW_WE_NUM");
        if (nWX > 0)
            return "WE_";
        if (GetIsNight())
            return sNdef;
        else
            return sDef;

    } else if (nHour >= AWW_NIGHT_START || nHour < AWW_MORNING_START) {
        return sNdef;
    }
    return sDef;
}

// This reads an optional variable on the creature
// to configure how it should walk. If unset no
// changes are made to the walk settings.
void aww_ConfigureWalkType() {

    int nType = GetLocalInt(OBJECT_SELF, "AWW_WALK_TYPE");
    switch (nType) {
    case  AWW_WALK_TYPE_NORMAL:
        SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, FALSE);
        SetWalkCondition(AWW_WALK_FLAG_RANDOM, FALSE);
        SetWalkCondition(AWW_WALK_FLAG_CIRCREV, FALSE);
        break;
    case AWW_WALK_TYPE_CIRCULAR:
        SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, TRUE);
        SetWalkCondition(AWW_WALK_FLAG_RANDOM, FALSE);
        SetWalkCondition(AWW_WALK_FLAG_CIRCREV, FALSE);
        break;
    case AWW_WALK_TYPE_RANDOM:
        SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, FALSE);
        SetWalkCondition(AWW_WALK_FLAG_RANDOM, TRUE);
        SetWalkCondition(AWW_WALK_FLAG_CIRCREV, FALSE);
        break;
   case AWW_WALK_TYPE_CIRCREV:
        SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, FALSE);
        SetWalkCondition(AWW_WALK_FLAG_RANDOM, FALSE);
        SetWalkCondition(AWW_WALK_FLAG_CIRCREV, TRUE);
        break;
        case 0:
        return;
    default:
        aww_error("Bad walk type for " + GetTag(OBJECT_SELF) + " = " + IntToString(nType));
        return;
    }
}


// Initialize the creature for aww using it's current tag.
// Look up the caller's waypoints and store them on the creature.
// Waypoint variables:
// These are used by regular WalkWayPoints(), aww clears these so that
// extraneous calls to WalkWayPoints don't break aww walkers.
//        WP_NUM     : number of day waypoints
//        WN_NUM     : number of night waypoints
/*
   AWW uses these variables internally

   AWW_CURTAG  : tag the NCP is currently initialized with
   AWW_CURWP   ; the current wp
   AWW_LASTWP  : previously reached waypoint

   AWW_WP_NUM  : number of day or regular WPs
   AWW_WN_NUM  : number of night waypoint
   AWW_WM_NUM  : number of morning waypoints
   AWW_WA_NUM  : number of afternoon waypoints
   AWW_WE_NUM  : number of evening waypoints
   AWW_WD_NUM  : number of dawn/dusk waypoints

   AWW_W<X>_#    : the waypoint objects (X = P,M,A,E,N,D)

   AWW_CURSET  : string prefix of current waypoint set (e.g. WP_, WM_, etc)

   AWW_PAUSE   : float variable on WP or NPC used during non-script WP actions.
                 each WP can override the pause value. The value passed in to the initial call
         to walkways is stored on the PC at init.

   AWW_RUN     : used internally to control walk versus run.

*/
void aww_InitWalkWays(int bRun, float fPause) {
    // check if the module enables area transitions for walkwaypoints
    int bCrossAreas = (GetLocalInt(GetModule(),"X2_SWITCH_CROSSAREA_WALKWAYPOINTS") == TRUE);

    string sMyTag = aww_GetTag(OBJECT_SELF);
    string sTag = "WP_" + sMyTag + "_";

    int nNth=1;
    object oWay;

    aww_debug("aww_InitWalkWays:  " + sTag);

    aww_ConfigureWalkType();

    // Check if the creature has NW_FLAG_DAY_NIGHT_POSTING set and clear it by default
    if (GetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING)) {

        // Check module variable to disable this disabling...
        aww_debug("awwInit disabling DAY_NIGHT_POSTING for " + GetTag(OBJECT_SELF));
        SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING, FALSE);
    }

    // we don't check for disabled WPs here since we still have to count them
    if (!bCrossAreas) {
        oWay = GetNearestObjectByTag(sTag + GetWaypointSuffix(nNth));
    }
    else {
       oWay = GetObjectByTag(sTag + GetWaypointSuffix(nNth));
    }
    if (!GetIsObjectValid(oWay)) {
        if (!bCrossAreas) {
            oWay = GetNearestObjectByTag("POST_" + sMyTag);
        }
        else {
            oWay = GetObjectByTag("POST_" + sMyTag);
        }
        if (GetIsObjectValid(oWay)) {
            // no waypoints but a post
            SetLocalInt(OBJECT_SELF, "AWW_WP_NUM", 1);
            SetLocalObject(OBJECT_SELF, "AWW_WP_1", oWay);
        } else {
            // no waypoints or post
            SetLocalInt(OBJECT_SELF, "AWW_WP_NUM", -1);
        }
    } else {
        // look up and store all the waypoints
        while (GetIsObjectValid(oWay)) {
            SetLocalObject(OBJECT_SELF, "AWW_WP_" + IntToString(nNth), oWay);
            nNth++;
            if (!bCrossAreas) {
                oWay = GetNearestObjectByTag(sTag + GetWaypointSuffix(nNth));
            }
            else {
                oWay = GetObjectByTag(sTag + GetWaypointSuffix(nNth));
            }
        }
        nNth--;
        SetLocalInt(OBJECT_SELF, "AWW_WP_NUM", nNth);
    }


    //The block of code below deals with night and day
    // cycle for postings and walkway points.
    // clear the special-time waypoints
    SetLocalInt(OBJECT_SELF, "AWW_WN_NUM", -1);
    SetLocalInt(OBJECT_SELF, "AWW_WM_NUM", -1);
    SetLocalInt(OBJECT_SELF, "AWW_WA_NUM", -1);
    SetLocalInt(OBJECT_SELF, "AWW_WE_NUM", -1);
    SetLocalInt(OBJECT_SELF, "AWW_WD_NUM", -1);
    int x;
    for (x = 0; x < 5 ; x ++) {
            string sPre = "WN_";
            if (x == 1)
            sPre = "WM_";
            if (x == 2)
            sPre = "WA_";
            if (x == 3)
            sPre = "WE_";
            if (x == 4)
            sPre = "WD_";

            sTag = sPre + sMyTag + "_";
            nNth = 1;

            if (!bCrossAreas) {
                    oWay = GetNearestObjectByTag(sTag + GetWaypointSuffix(nNth));
            }
            else {
                    oWay = GetObjectByTag(sTag + GetWaypointSuffix(nNth));
            }
            if (!GetIsObjectValid(oWay)) {
            // Check for WN so we can find a NIGHT_ post if that exists
                if (sPre == "WN_") {
                    if (!bCrossAreas) {
                        oWay = GetNearestObjectByTag("NIGHT_" + sMyTag);
                    }
                    else {
                        oWay = GetObjectByTag("NIGHT_" + sMyTag);
                    }
                    if (GetIsObjectValid(oWay)) {
                        // no waypoints but a post
                     SetLocalInt(OBJECT_SELF, "AWW_WN_NUM", 1);
                     SetLocalObject(OBJECT_SELF, "AWW_WN_1", oWay);
                    } else {
                        // no waypoints or post
                        SetLocalInt(OBJECT_SELF, "AWW_WN_NUM", -1);
                    }
                } else {
                    SetLocalInt(OBJECT_SELF, "AWW_" + sPre + "NUM", -1);
                }
            } else {
            // look up and store all the waypoints
            while (GetIsObjectValid(oWay)) {
                SetLocalObject(OBJECT_SELF, "AWW_" + sPre + IntToString(nNth), oWay);
                nNth++;
                if (!bCrossAreas) {
                    oWay = GetNearestObjectByTag(sTag + GetWaypointSuffix(nNth));
                }
                else {
                    oWay = GetObjectByTag(sTag + GetWaypointSuffix(nNth));
                }
            }
            nNth--;
            SetLocalInt(OBJECT_SELF, "AWW_" + sPre + "NUM", nNth);
            }

    }

// We've found any WPs now complete the initialization
    SetLocalString(OBJECT_SELF, "AWW_CURTAG", sMyTag);
    SetLocalString(OBJECT_SELF, "AWW_CURSET", aww_GetWPSet());
    SetLocalObject(OBJECT_SELF, "AWW_CURWP", OBJECT_INVALID);
    SetLocalObject(OBJECT_SELF, "AWW_LASTWP", OBJECT_INVALID);

    SetLocalFloat(OBJECT_SELF, "AWW_PAUSE", fPause);
    SetLocalInt(OBJECT_SELF, "AWW_RUN", bRun);

    SetWalkCondition(AWW_WALK_FLAG_INIT, TRUE);
    // TODO  make sure CIRCULAR or RANDOM are set if needed

    //aww_DumpWayPoints(OBJECT_SELF);

}

// Get the creature's next waypoint.
// If it has just become day/night/morning/afternoon/evening, or if this is
// the first time we're getting a waypoint, we go
// to the nearest waypoint in our new set.
object aww_GetNextWalkWayPoint() {
    object oWay = OBJECT_INVALID;
    string sMyTag =  aww_GetTag(OBJECT_SELF);

    // Check if a set change is needed - this does not handle changes in tag, just time
    // tag changes need a re-init
    string sSet = aww_GetWPSet();
    string sCurSet = GetLocalString(OBJECT_SELF, "AWW_CURSET");
    int bSetChanged = FALSE;
    aww_debug("aww_GetNextWalkWayPoint: " + aww_GetTag(OBJECT_SELF) + " current set = " + sCurSet);

    // time base set changes only happen if DAY/NIGHT posting enabled
//    if (GetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING)) {
    //      aww_debug("aww_GetNext: found day_night posting for " + sMyTag);
    if (sSet != sCurSet) {
            // switch sets and get nearest WP in new set
            aww_debug("aww_GetNext: Set switched from "+ sCurSet + " to " + sSet +  " for " + sMyTag);
            sCurSet = sSet;
            SetLocalString(OBJECT_SELF, "AWW_CURSET" , sCurSet);
            SetLocalObject(OBJECT_SELF, "AWW_CURWP", OBJECT_INVALID);
            SetLocalObject(OBJECT_SELF, "AWW_LASTWP", OBJECT_INVALID);
            bSetChanged = TRUE;
    }

    if (sCurSet == "NONE_" ) {
        SetLocalObject(OBJECT_SELF, "AWW_CURWP", OBJECT_INVALID);
        return OBJECT_INVALID;
    }

    // if we only have one post, just go there - after the first call or so if nothing
    // changed we should already be there but this keeps us moving back there if we move away
    int nPoints = GetLocalInt(OBJECT_SELF, "AWW_" + sCurSet + "NUM");
    //aww_debug("GetNext - got " + IntToString(nPoints) + " points for curset " + sCurSet);
    if (nPoints == 1) {
        oWay = GetLocalObject(OBJECT_SELF, "AWW_" + sCurSet + "1");
        SetLocalObject(OBJECT_SELF, "AWW_CURWP", oWay);
        if (bSetChanged) SetLocalInt(OBJECT_SELF, "X2_G_TRAN", 1); // probably should be an_am_inc::SetInTransition();
        return oWay;
    }

    // Move up to the next waypoint

    // Get the current waypoint
    object oCur = GetLocalObject(OBJECT_SELF, "AWW_CURWP");
    // Check to see if this is the first time
    if (!GetIsObjectValid(oCur) ) {
        // get nearest waypoint in current set
        // this just makes sure all the variables are at initial values for call to GetNearest
        SetLocalObject(OBJECT_SELF, "AWW_CURWP", OBJECT_INVALID);
        SetLocalObject(OBJECT_SELF, "AWW_LASTWP", OBJECT_INVALID);

        //aww_debug("aww_GetNext found UNINITIALIZED - getting nearest WP for " + sMyTag);
        oWay = aww_GetNearestWalkWayPoint();
        aww_debug("aww_GetNext found " + GetTag(oWay) + " idx = "
          + IntToString(aww_GetIdxFromWP(oWay)) + " for " + sMyTag);

        // make sure AWW_CURWP points to new one
        SetLocalObject(OBJECT_SELF, "AWW_CURWP", oWay);
       return oWay;
    }

    int nCurWay = aww_GetIdxFromWP(oCur);
    aww_debug("aww_GetNextWalkWayPoint: " + sMyTag + " old Cur = " + GetTag(oCur)
      + " old idx = " + IntToString(nCurWay));

    // Handle cicular walkers
    if (GetWalkCondition(AWW_WALK_FLAG_CIRCULAR)) {
        int n;
        for (n = 0; n < nPoints ; n++) {
            // go to next WP and wrap around
            nCurWay++;
            if (nCurWay >  nPoints)
                nCurWay = 1;
            oWay = GetLocalObject(OBJECT_SELF, "AWW_" + sCurSet + IntToString(nCurWay));
            if (GetIsObjectValid(oWay) && !GetLocalInt(oWay, "AWW_DISABLE")) {
                 break;
            } else {
              aww_debug("aww_GetNext " + sMyTag + " skipping disabled or invalid waypoint " + GetTag(oWay) );
            }
        // this makes sure we don't use the last one if it's disabled
            oWay = OBJECT_INVALID;
        }
    } else if (GetWalkCondition(AWW_WALK_FLAG_RANDOM)) {
        int n;

    // TODO - don't pick the same one?
        //int nTmp = nCurWay;

        for (n = 0; n < nPoints ; n++) {
            // get a random one
            nCurWay = Random(nPoints) + 1;
            oWay = GetLocalObject(OBJECT_SELF, "AWW_" + sCurSet + IntToString(nCurWay));
            if (GetIsObjectValid(oWay) && !GetLocalInt(oWay, "AWW_DISABLE")) {
                    break;
            } else {
            aww_debug("aww_GetNext " + sMyTag + " skipping disabled or invalid waypoint " + GetTag(oWay) );
        }
        // this makes sure we don't use the last one if it's disabled
        oWay = OBJECT_INVALID;
        }

    } else if (GetWalkCondition(AWW_WALK_FLAG_CIRCREV)) {
        int n;
        for (n = 0; n < nPoints ; n++) {
            // go to next WP and wrap around
            nCurWay--;
            if (nCurWay <=  0)
                nCurWay = nPoints;
            oWay = GetLocalObject(OBJECT_SELF, "AWW_" + sCurSet + IntToString(nCurWay));
            if (GetIsObjectValid(oWay) && !GetLocalInt(oWay, "AWW_DISABLE")) {
            break;
        } else {
            aww_debug("aww_GetNext " + sMyTag + " skipping disabled or invalid waypoint " + GetTag(oWay) );
        }
        // this makes sure we don't use the last one if it's disabled
        oWay = OBJECT_INVALID;
        }

    } else {
        // we're either walking forwards or backwards
        int n;
        int bGoingBackwards;
        for (n = 0; n < nPoints ; n++) {
            int bGoingBackwards = GetWalkCondition(NW_WALK_FLAG_BACKWARDS, OBJECT_SELF);
            if (bGoingBackwards) {
                nCurWay--;
                if (nCurWay == 0) {
                    nCurWay = 2;
                    SetWalkCondition(NW_WALK_FLAG_BACKWARDS, FALSE, OBJECT_SELF);
                }
            } else {
                nCurWay++;
                if (nCurWay > nPoints) {
                    nCurWay = nCurWay - 2;
                    SetWalkCondition(NW_WALK_FLAG_BACKWARDS, TRUE, OBJECT_SELF);
                }
            }
            oWay = GetLocalObject(OBJECT_SELF, "AWW_" + sCurSet + IntToString(nCurWay));
            if (GetIsObjectValid(oWay) && !GetLocalInt(oWay, "AWW_DISABLE")) {
                break;
            } else {
                aww_debug("aww_GetNext " + sMyTag + " skipping disabled or invalid waypoint " + GetTag(oWay) );
            }
        }
    }

    // Set our current point and return
    aww_debug("aww_GetNextWalkWayPoint: " + sMyTag + " new Cur = " + GetTag(oWay)
      + " new idx = " + IntToString(aww_GetIdxFromWP(oWay)));
    SetLocalObject(OBJECT_SELF, "AWW_CURWP", oWay);
    return oWay;
}


// Get object of the nearest of the creature's current
// set of waypoints. Return OBJECT_INVALID if there are no WPs in the current set
// If there is no WP in the current area but there are others it will
// return the first one found, not necessarily the nearest.
object aww_GetNearestWalkWayPoint() {
    string sCurSet = GetLocalString(OBJECT_SELF, "AWW_CURSET");
    string sMyTag = aww_GetTag(OBJECT_SELF);
    int nNumPoints = GetLocalInt(OBJECT_SELF, "AWW_" + sCurSet + "NUM");

    aww_debug("aww_GetNearestWalkWayPoint: " + sMyTag
        + " Curset = " + sCurSet + " numpoints = " + IntToString(nNumPoints));

    // we should never be here if this is the case.
    if (sCurSet == "NONE_") {
        return OBJECT_INVALID;
    }

    //we should not be here if numpoints == 1 either
    // just return the one waypoint in case
    if (nNumPoints == 1) {
        return GetLocalObject(OBJECT_SELF, "AWW_" + sCurSet + "1");
    }


    string sPrefix = "AWW_" + sCurSet;
    int i;
    int nNearest = -1;
    float fDist = 1000000.0;
    object oWay = OBJECT_INVALID;
    object oWayArea = OBJECT_INVALID;
    int nAreaIdx;

    object oTmp;
    float fTmpDist;
    for (i = 1; i <= nNumPoints; i++) {
        oTmp = GetLocalObject(OBJECT_SELF, sPrefix + IntToString(i));
        // TODO respect WP disable
        // if (GetLocalInt(oTmp, "AWW_DISABLE")) continue;
        if (!GetIsObjectValid(oTmp)) {
            aww_debug("GETNEAREST invalid WP: " +  sPrefix + IntToString(i));
            continue;
        }
        if (GetArea(OBJECT_SELF) != GetArea(oTmp)) {
            if (oWayArea == OBJECT_INVALID) {
               oWayArea = oTmp;
               nAreaIdx = i;
            }
        } else {
            // same area - check distance
            fTmpDist = GetDistanceBetween(oTmp, OBJECT_SELF);
            if (fTmpDist >= 0.0 && fTmpDist < fDist) {
                nNearest = i;
                fDist = fTmpDist;
                oWay = oTmp;
            }
        }
    }

    // found one in this area
    if (GetIsObjectValid(oWay)) {
        return oWay;

    } else if (GetIsObjectValid(oWayArea)) {
        // use first one in a different area
         return oWayArea;
    }

    // no way point found
    aww_debug("aww_GetNearest found no " + sPrefix + " waypoint for " + sMyTag);
    return OBJECT_INVALID;
}

// do any registered activity
//
int aww_DoActivity() {

    // check for currently armed activity script
    string sScript = GetLocalString(OBJECT_SELF, "AWW_DO_ACTIVITY_SCRIPT");
    if (sScript == "") return FALSE;

    // check if we should disable this and restart walking WPs
    string sSet = aww_GetWPSet();
    string sCurSet = GetLocalString(OBJECT_SELF, "AWW_CURSET");
    if (sSet != sCurSet) {
        aww_debug("do_activity got set change to " + sSet);
        DeleteLocalString(OBJECT_SELF, "AWW_DO_ACTIVITY_SCRIPT");
        DeleteLocalObject(OBJECT_SELF, "aww_current_chair"); // clean up, just in case
        aww_SetWalkPaused(FALSE, OBJECT_SELF);
        return FALSE;
    }
    aww_debug("aww_DOActivity: " + GetTag(OBJECT_SELF) + " executes script " + sScript);
    // if not run the provided script
    ExecuteScript(sScript, OBJECT_SELF);
    return TRUE;
}

// Do the work at the waypoint.
void aww_WayPointArrive(object oWay) {

        // set last to cur to keep from doing this again at this WP
    object oCur = GetLocalObject(OBJECT_SELF, "AWW_CURWP");

    if (oWay != oCur) {
        aww_error("arrival at "+ GetTag(oWay) + " but current is " + GetTag(oCur));
        SetLocalObject(OBJECT_SELF, "AWW_CURWP", oWay);
    }
    SetLocalObject(OBJECT_SELF, "AWW_LASTWP", oWay);
    DeleteLocalInt(OBJECT_SELF, "X2_G_TRAN"); //probably should be an_am_inc::SetInTransition(FALSE);

    aww_debug("WayPointArrive:" + GetTag(OBJECT_SELF) + " wp = " + GetTag(oWay));

    // We've arrived - make sure we clear the stuck counter
    DeleteLocalInt(OBJECT_SELF, AWW_STUCK_COUNT);
    DeleteLocalLocation(OBJECT_SELF, AWW_STUCK_LOCATION);

    // check if this is a final destination
    object oDest = GetLocalObject(OBJECT_SELF, "AWW_DEST_WP");
    string sDestScript = GetLocalString(OBJECT_SELF, "AWW_DEST_SCRIPT");
    if (GetIsObjectValid(oDest) && oDest == oWay && sDestScript != "") {
        // We've reached a final destination WP. Execute the script
        ExecuteScript(sDestScript, OBJECT_SELF);
        ActionDoCommand(aww_WalkWayPoints(GetLocalInt(OBJECT_SELF, "AWW_RUN"), GetLocalFloat(OBJECT_SELF, "AWW_PAUSE")));
        return;
    }

        // check if WP itself has been disabled
    if (GetLocalInt(oWay, "AWW_DISABLE")) {
        aww_debug("arrival at " + GetTag(oWay) + " Waypoint disabled");
        ActionDoCommand(aww_WalkWayPoints(GetLocalInt(OBJECT_SELF, "AWW_RUN"), GetLocalFloat(OBJECT_SELF, "AWW_PAUSE")));
        return;
    }

    // respect SETFACING
    if(GetLocalInt(oWay,"X2_L_WAYPOINT_SETFACING") == 1) {
            ActionDoCommand(SetFacing(GetFacing(oWay)));
    }

    string sScript = GetLocalString(oWay, "AWW_WP_SCRIPT");
    if (sScript != "") {
        aww_debug("aww_arrive: found script :" + sScript);
        ExecuteScript(sScript, OBJECT_SELF);
    } else {
        int   iAnim         = GetLocalInt( oWay, "AWW_WP_ANIMATION");
        float fAnimSpeed    = GetLocalFloat( oWay, "AWW_WP_ANIMATION_SPEED");
        float fAnimDur = GetLocalFloat( oWay, "AWW_WP_ANIMATION_DURATION");
        iAnim      = ((((iAnim >= 0)   && (iAnim <= 30)) ||
                   ((iAnim >= 100) && (iAnim <= 116))  ) ? iAnim : -1);
        fAnimSpeed = ((fAnimSpeed <= 0.0) ? 1.0 : fAnimSpeed);
        fAnimDur   = ((fAnimDur <= 0.0) ? 0.0 : fAnimDur);

            // Check WP for a Pause setting
        float fPause = GetLocalFloat(oWay, "AWW_PAUSE");
        if (fPause == 0.0)
            fPause = GetLocalFloat(OBJECT_SELF, "AWW_PAUSE");

        ActionWait(fPause);
        // Animation code adapted from Axe Murdered KWW system.
        if (iAnim >- 0) {
            aww_debug("aww_arrive: " + GetTag(OBJECT_SELF) + " Playing animation " + IntToString(iAnim));
            ActionDoCommand( SetLocalInt( OBJECT_SELF, "AWW_PLAYING_ANIMATION", TRUE));
            ActionDoCommand( DelayCommand(fAnimDur + 0.05, DeleteLocalInt(OBJECT_SELF, "AWW_PLAYING_ANIMATION")));
            ActionPlayAnimation(iAnim, fAnimSpeed, fAnimDur);
            if(fPause > 0.0)
            ActionWait(fPause);
        }
    }

    // February 14 2003 added else route only happens once
    // That's not quite true here, but if this is not called the NPC waits until
    // the next HB to move. This makes it smoother.
    ActionDoCommand(aww_WalkWayPoints(GetLocalInt(OBJECT_SELF, "AWW_RUN"), GetLocalFloat(OBJECT_SELF, "AWW_PAUSE")));

    // GZ: 2003-09-03
    // Since this wasnt implemented and we we don't have time for this either, I
    // added this code to allow builders to react to NW_FLAG_SLEEPING_AT_NIGHT.
    if(GetIsNight()) {
        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT)) {
            string sScript = GetLocalString(GetModule(),"X2_S_SLEEP_AT_NIGHT_SCRIPT");
            if (sScript != "") {
                ExecuteScript(sScript,OBJECT_SELF);
            }
        }
    }

}


// This checks if the NPC has moved since the last call.
// It should be called only after checking that the NPC really should be moving
// Returns TRUE if the NPC is making progress. Returns FALSE and increments
// stuck counter if bCount = TRUE.
int awwCheckHasMoved(object oNPC, int bCount = FALSE) {

    if (!AWW_STUCK_DETECTION)
        return TRUE;

    aww_debug("Checking for walker progress" + GetTag(oNPC));

    location lCur = GetLocation(oNPC);
    location lOld = GetLocalLocation(oNPC, AWW_STUCK_LOCATION);
    int nCount = GetLocalInt(oNPC, AWW_STUCK_COUNT);

    // Initialize the location variable
    if (!GetIsObjectValid(GetAreaFromLocation(lOld))) {
        aww_debug("walker progress location not initialized:" + GetTag(oNPC));
        SetLocalLocation(oNPC, AWW_STUCK_LOCATION, lCur);
        DeleteLocalInt(oNPC, AWW_STUCK_COUNT);
        return TRUE;
    }

    aww_debug("Old loc = " + LocationToString(lOld));
    aww_debug("Cur loc = " + LocationToString(lCur));
    if (lCur == lOld)  {
        if (bCount) {
            nCount ++;
            SetLocalInt(oNPC, AWW_STUCK_COUNT, nCount);
        }
        return FALSE;
    }

    SetLocalLocation(oNPC, AWW_STUCK_LOCATION, lCur);
    return TRUE;
}

// This is called when we are sure aww is initialized and the NPC should be walking.
// This returns TRUE if it takes a corrective action. In that case the calling code
// should not proceed.
int awwCheckStuckWalker(object oNPC, object oWay, int bRun = FALSE) {

    if (!AWW_STUCK_DETECTION)
        return FALSE;

    // We've already checked for in conversation and combat etc.
    aww_debug("Checking for stuck walker " + GetTag(oNPC));

    location lCur = GetLocation(oNPC);
    location lOld = GetLocalLocation(oNPC, AWW_STUCK_LOCATION);

    if (awwCheckHasMoved(oNPC, TRUE)) {
        return FALSE;
    }

    int nCount = GetLocalInt(oNPC, AWW_STUCK_COUNT);

    // Decide if we need to do anything
    if (nCount > 2) {
        SpeakString("I'm stuck: " + IntToString(nCount));

        if (nCount == 3) {
            int iOrgAI = GetAILevel();
            // Check for ai level default and increase if so
            // mark that we did this so we can undo it.
            ClearAllActions( TRUE);
            //ActionDoCommand( SetCommandable( TRUE));
            ActionDoCommand( DelayCommand( 4.0, SetAILevel(oNPC, iOrgAI)));
            ActionDoCommand( SetAILevel( oNPC, AI_LEVEL_HIGH));

        } else if (nCount > 3 && nCount < 7) {

            float fMod;

            // 2 - 5 we try to move half a square in one of the three non forward directions
            if( nCount == 4) {
                                // Make him move a little to the left.
                fMod = 90.0;
            }
            else if(nCount == 5) {
                                // Make him move a little backwards.
                fMod = 180.0;
            }
            else if(nCount == 6) {
                                // Make him move a little to the right.
                fMod = -90.0;
            }

            float  fAngle = GetFacing(oNPC) + fMod;
            while( fAngle >= 360.0)
                fAngle -= 360.0;
            while( fAngle <    0.0)
                fAngle += 360.0;
            vector vLeft  = GetPosition(oNPC);
            vector vUnit  = VectorNormalize(AngleToVector(fAngle));
            vUnit *= 5.0;   // this is the distance
            vLeft += vUnit;

            // Move to the new location then try to move to the wp and arrive
            ClearAllActions(TRUE);
            ActionMoveToLocation(Location(GetArea(oNPC), vLeft, GetFacing(oNPC)));
            float fTimeout = GetLocalFloat( OBJECT_SELF, "X2_L_WALKWAY_FORCE_MOVE");
            if (AWW_USE_FORCEMOVE || fTimeout > 0.0) {
                if (fTimeout != 0.0) {} else fTimeout = AWW_FORCEMOVE_TIMEOUT;
                ActionForceMoveToObject(oWay, bRun, 1.0, fTimeout);
            }
            else
                ActionMoveToObject(oWay, bRun);
            ActionDoCommand(aww_WayPointArrive(oWay));

        } else if (nCount > 6) {
            // Else we jump to location oWay.
            aww_debug("Stuck - jumping to wp : " + GetTag(oWay));

            ClearAllActions(TRUE);
            // Just jump directly to the way point and   call the arrival code
            ActionJumpToObject(oWay);
            ActionDoCommand(DelayCommand(0.5, aww_WayPointArrive(oWay)));

            // These are probably not needed - may be best to take them out and
            // let the arrival code clear them. Then we know we've arrived...
            DeleteLocalLocation(oNPC, AWW_STUCK_LOCATION);
            DeleteLocalInt(oNPC, AWW_STUCK_COUNT);

        }
        return TRUE;
    }

    return FALSE;
}


// Make the caller walk through their waypoints or go to their post.
void aww_WalkWayPoints(int nRun = FALSE, float fPause = 1.0) {
    // * don't interrupt current circuit
    object oNearestEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    int bIsEnemyValid = GetIsObjectValid(oNearestEnemy);
    string sMyTag = aww_GetTag(OBJECT_SELF);
    aww_debug("aww_WalkWayPoints: " + GetTag(OBJECT_SELF) + " vtag: " + sMyTag);

    // * if I can see an enemy I should not be trying to walk waypoints
    if (bIsEnemyValid) {
        if( GetObjectSeen(oNearestEnemy)) {
            return;
        }
    }

    if( GetCurrentAction( OBJECT_SELF) != ACTION_INVALID) DeleteLocalInt( OBJECT_SELF, "AWW_PLAYING_ANIMATION");

    // do nothing if disabled
    if (GetWalkCondition(AWW_WALK_FLAG_DISABLED)) {
        aww_debug("aww_walkways : disabled");
        return;
    }

    if (aww_DoActivity())
        return;

    if (GetWalkCondition(AWW_WALK_FLAG_PAUSED)) {
        aww_debug("aww_walkways : paused");
        return;
    }
     int bNeedReInit = FALSE;

    // Regular walk waypoint has been called.
    if (GetWalkCondition(NW_WALK_FLAG_INITIALIZED)
        && GetLocalInt(OBJECT_SELF, "WP_NUM") !=  -1) {
          ClearAllActions();
          SetLocalInt(OBJECT_SELF, "WP_NUM", -1);
          SetLocalInt(OBJECT_SELF, "WN_NUM", -1);
          bNeedReInit = TRUE;
          aww_debug("aww_walkwaypoints - found regular waypoints initialized - clearing");
    }

    int bIsFighting = GetIsFighting(OBJECT_SELF);
    int bIsInConversation = IsInConversation(OBJECT_SELF);
    int bMoving = GetCurrentAction(OBJECT_SELF) == ACTION_MOVETOPOINT;
    int bWaiting = GetCurrentAction(OBJECT_SELF) == ACTION_WAIT;

    aww_debug(sMyTag + ": incombat = " + IntToString(bIsFighting) + " inconvo = " + IntToString(bIsInConversation)
        + " moving = " + IntToString(bMoving) + " waiting = " + IntToString(bWaiting));
    if (bIsFighting == TRUE || bIsInConversation == TRUE || bWaiting == TRUE)
         return;

    // If we're stopped because we're stuck action will still be moving so check for being stuck before
    // getting out this way.
   if (bMoving) {
      if (awwCheckHasMoved(OBJECT_SELF))
        return;
   }

    // don't do anything if animating
    if (GetLocalInt(OBJECT_SELF, "AWW_PLAYING_ANIMATION"))
        return;

    // if we're marked as sleeping by an activity and we get here then we should wake up
    if (GetLocalInt(OBJECT_SELF, "SLEEPING")) {
        // do wakeup
        effect eEffect = GetFirstEffect(OBJECT_SELF);
        while(GetIsEffectValid(eEffect)) {
            if(GetEffectType(eEffect) == EFFECT_TYPE_SLEEP) {
                aww_debug("Removing effect from " + GetTag(OBJECT_SELF));
                RemoveEffect(OBJECT_SELF,eEffect);
            }
            eEffect = GetNextEffect(OBJECT_SELF);
        }
        ClearAllActions();
        DeleteLocalInt(OBJECT_SELF, "SLEEPING");
        return;
    }

    /* This code requires other code not included in AWW itself
       The above sleep code is roughly equivalent.
   if (tnp_is_sleeping()) {
       aww_error("AWW WalkWays waking up " + GetTag(OBJECT_SELF));
        tbWakeUp(OBJECT_SELF);
        return;
    }
    */

    // But if we're under the effects of sleep here maybe we should do nothing...
    if (GetHasEffect(EFFECT_TYPE_SLEEP)) {
        return;
    }

    if(!GetCommandable()) return; // Don't interfere with non-interruptable actions.

    // if regular walk ways not initialized, mark it so and
    // make sure it will not do anything if called by accident
    if (!GetWalkCondition(NW_WALK_FLAG_INITIALIZED)) {
        SetLocalInt(OBJECT_SELF, "WP_NUM", -1);
        SetLocalInt(OBJECT_SELF, "WN_NUM", -1);
        SetWalkCondition(NW_WALK_FLAG_INITIALIZED);
    }

    object oCurWP = GetLocalObject(OBJECT_SELF, "AWW_CURWP");
    int nCurWPIdx = aww_GetIdxFromWP(oCurWP);
    aww_debug("aww_WalkWayPoints: " + sMyTag + " curwp =  "
      + GetTag(oCurWP) + " curidx = " + IntToString(nCurWPIdx));


    if (!GetWalkCondition(AWW_WALK_FLAG_INIT)) {
        aww_debug("aww_Walkways calling init because walk condition not initialized");
        bNeedReInit = TRUE;
    }

    string curTag = GetLocalString(OBJECT_SELF, "AWW_CURTAG");
    if ( curTag != aww_GetTag(OBJECT_SELF)) {
        bNeedReInit = TRUE;
        aww_debug("aww_walkways : calling init because curtag " + curTag + " != mytag " + sMyTag);
    }

    // TODO - this may not be right. It will lead to a lot more calls to init if there are
    // no WPs for an NPC. But it can catch cases where all WPs were disabled and now are not...
    if (!GetIsObjectValid(oCurWP))   {
        aww_debug("aww_WalkWayPoints - calling re-init for " + sMyTag
              + " curwp = " + GetTag(oCurWP) + " idx = " + IntToString(nCurWPIdx));
            bNeedReInit = TRUE;
    }

    // Do AWW initializion if needed
    if (bNeedReInit) {
        aww_InitWalkWays(nRun, fPause);
        SetWalkCondition(AWW_WALK_FLAG_INIT);

        //TODO this will go off every time the creature re-initializes
        // Use appropriate skills, only once
        // * GZ: 2003-09-03 - ActionUseSkill never worked, added the new action mode stuff
        if(GetSpawnInCondition(NW_FLAG_STEALTH)) {
            SetActionMode(OBJECT_SELF,ACTION_MODE_STEALTH,TRUE);
        }

        // * GZ: 2003-09-03 - ActionUseSkill never worked, added the new action mode stuff
        if(GetSpawnInCondition(NW_FLAG_SEARCH)){
            SetActionMode(OBJECT_SELF,ACTION_MODE_DETECT,TRUE);
        }

        // update the local variables we're looking at below
        oCurWP = GetLocalObject(OBJECT_SELF, "AWW_CURWP");
        nCurWPIdx = aww_GetIdxFromWP(oCurWP);
    }

    // Move to the next waypoint
    object oLastWP = GetLocalObject(OBJECT_SELF, "AWW_LASTWP") ;
    object oWay;
    int bMove = TRUE;
    if (oCurWP == oLastWP) {
        aww_debug("awwWalkWays: " + GetTag(OBJECT_SELF) + " last == cur :"
              + GetTag(oCurWP) + ":, time to get next WP");
        oWay = aww_GetNextWalkWayPoint();

        // We got back the same waypoint we just arrived at - probably the only
        // one. Check if we are close enough and if so don't move
        if (GetIsObjectValid(oWay) && oWay == oCurWP) {
            //aww_debug("Got same waypoint as before : " + GetTag(oWay));
            if (GetLocalInt(OBJECT_SELF, "AWW_LAX_POST")) {
                //aww_debug("Got LAX_POST for " + GetTag(OBJECT_SELF));
                bMove = FALSE;
            } else {
                float fDist = GetLocalFloat(OBJECT_SELF, "AWW_POST_DISTANCE");
                if (fDist <= 0.0) fDist = 2.0;
                if (GetDistanceToObject(oWay) <= fDist)
                    bMove = FALSE;
            }
        }

    } else
        oWay = oCurWP;

    // Here we're moving to a waypoint.
    if (GetIsObjectValid(oWay) && bMove) {

        // Check for being stuck. If this returns true we are done
        if (awwCheckStuckWalker(OBJECT_SELF, oWay, nRun))
            return;

        SetWalkCondition(NW_WALK_FLAG_CONSTANT);
        // * Feb 7 2003: Moving this from 299 to 321, because I don't see the point
        // * in clearing actions unless I actually have waypoints to walk
        ClearActions(CLEAR_X0_I0_WALKWAY_WalkWayPoints);

        //DEBUG
        //SpeakString("Moving to waypoint: " + GetTag(oWay));

    float fTimeout = GetLocalFloat( OBJECT_SELF, "X2_L_WALKWAY_FORCE_MOVE");
    if (AWW_USE_FORCEMOVE || fTimeout > 0.0) {
        if (fTimeout != 0.0) {} else fTimeout = AWW_FORCEMOVE_TIMEOUT;
        ActionForceMoveToObject(oWay, nRun, 1.0, fTimeout);
    }
    else
        ActionMoveToObject(oWay, nRun);
        ActionDoCommand(aww_WayPointArrive(oWay));

    } else { // also do stuff if there are no waypoints set


        string sScript = GetLocalString(OBJECT_SELF, "AWW_NOWP_SCRIPT");
        if (sScript != "") {
            ExecuteScript(sScript, OBJECT_SELF);
            return;
        }
        // TODO
        // else we could do playambient or immobile animations?

        // GZ: 2003-09-03
        // Since this wasnt implemented and we we don't have time for this either, I
        // added this code to allow builders to react to NW_FLAG_SLEEPING_AT_NIGHT.
        if(GetIsNight()) {
            if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT)) {
                sScript = GetLocalString(GetModule(),"X2_S_SLEEP_AT_NIGHT_SCRIPT");
                if (sScript != "") {
                    ExecuteScript(sScript,OBJECT_SELF);
                }
            }
        }
    }
}


// Check to make sure that the walker has at least one valid
// waypoint to walk to at some point.
int aww_CheckWayPoints(object oWalker = OBJECT_SELF) {
    if (!GetWalkCondition(NW_WALK_FLAG_INITIALIZED, oWalker)) {
        SetLocalInt(OBJECT_SELF, "WP_NUM", -1);
        SetLocalInt(OBJECT_SELF, "WN_NUM", -1);
        SetWalkCondition(NW_WALK_FLAG_INITIALIZED, TRUE, oWalker);
    }

     if (!GetWalkCondition(AWW_WALK_FLAG_INIT, oWalker)) {
         aww_debug("aww_checkwaypoint calls init due to no init flag");
         AssignCommand(oWalker, aww_InitWalkWays(FALSE, 1.0));
     }

     if (GetLocalInt(oWalker, "AWW_WP_NUM") > 0
     || GetLocalInt(oWalker, "AWW_WN_NUM") > 0
     || GetLocalInt(oWalker, "AWW_WM_NUM") > 0
     || GetLocalInt(oWalker, "AWW_WA_NUM") > 0
     || GetLocalInt(oWalker, "AWW_WE_NUM") > 0
     || GetLocalInt(oWalker, "AWW_WD_NUM") > 0)
         return TRUE;
     return FALSE;
}

// Check to see if the specified object is currently walking
// waypoints or standing at a post.
int aww_GetIsPostOrWalking(object oWalker = OBJECT_SELF) {
    if (!GetWalkCondition(NW_WALK_FLAG_INITIALIZED)) {
        SetLocalInt(OBJECT_SELF, "WP_NUM", -1);
        SetLocalInt(OBJECT_SELF, "WN_NUM", -1);
        SetWalkCondition(NW_WALK_FLAG_INITIALIZED);
    }

    if (!GetWalkCondition(AWW_WALK_FLAG_INIT, oWalker)) {
        aww_debug("aww_getispostorwalking calls init due to no init flag for" + aww_GetTag(oWalker));
        AssignCommand(oWalker, aww_InitWalkWays(FALSE, 1.0));
    }

    if (GetLocalInt(oWalker, "AWW_" + GetLocalString(oWalker, "AWW_CURSET") + "NUM") > 0)
        return TRUE;
    return FALSE;
}

// Dump the state of the given oNPCs Waypoints. This can print a lot of information.
void aww_DumpWayPoints(object oNPC) {
    object oPC = GetFirstPC();

    object oCur = GetLocalObject(oNPC, "AWW_CURWP");
    object oLast = GetLocalObject(oNPC, "AWW_CURWP");
    int cur = aww_GetIdxFromWP(oCur);
    string sTag = GetTag(oNPC);
    string sVtag = aww_GetTag(oNPC);

    SendMessageToPC(oPC, sTag + " vtag=" + sVtag + " curwp =" + GetTag(oCur)
            + " lastwp=" + GetTag(oLast) + " IDX = " + IntToString(cur));
    SendMessageToPC(oPC, "   AWW_RUN=" + IntToString(GetLocalInt(oNPC, "AWW_RUN"))
            + " AWW_PAUSE=" + FloatToString(GetLocalFloat(oNPC, "AWW_PAUSE")));
    SendMessageToPC(oPC, "INIT = " + IntToString(GetWalkCondition(AWW_WALK_FLAG_INIT, oNPC))
        + " CIRC = " +  IntToString(GetWalkCondition(AWW_WALK_FLAG_CIRCULAR, oNPC))
        + " RAND = " +  IntToString(GetWalkCondition(AWW_WALK_FLAG_RANDOM, oNPC))
         + " PAUSE = " +  IntToString(GetWalkCondition(AWW_WALK_FLAG_PAUSED, oNPC))
        + " DISABLE = " +  IntToString(GetWalkCondition(AWW_WALK_FLAG_DISABLED, oNPC)) );
    SendMessageToPC(oPC, "Walk condition = " + IntToHexString(GetLocalInt(oNPC,sWalkwayVarname)));
    int x;
    int n;
    for (x = 0 ; x < 6; x ++) {
        string sPre = "WP_";
        if (x == 1)
            sPre = "WN_";
        if (x == 2)
            sPre = "WM_";
        if (x == 3)
            sPre = "WA_";
        if (x == 4)
            sPre = "WE_";
        if (x == 5)
            sPre = "WD_";

        int nNum = GetLocalInt(oNPC, "AWW_" + sPre + "NUM");
        SendMessageToPC(oPC, " WP " + sPre + " count " + IntToString(nNum));
        if (nNum < 0) continue;
        for (n = 1 ; n <= nNum; n++) {
            object oWay = GetLocalObject(oNPC, "AWW_" + sPre + IntToString(n));
            if (!GetIsObjectValid(oWay)){
                SendMessageToPC(oPC, "       Waypoint " + IntToString(n) + " is invalid");

            } else {
            SendMessageToPC(oPC, "       Waypoint " + IntToString(n) + ":" + GetTag(oWay)
                    + " disabled=" + IntToString(GetLocalInt(oWay, "AWW_DISABLE"))
                    + " script="  + GetLocalString(oWay, "AWW_WP_SCRIPT")
                    + " pause=" + FloatToString(GetLocalFloat(oWay, "AWW_PAUSE")));
            }
        }
    }

}


//void main() {}
