void main()
{
   object self = OBJECT_SELF;
   string userID = GetPCPublicCDKey(GetLastUsedBy(),TRUE);
   int used = GetLocalInt(self, "in_use");
   if(used && userID == GetLocalString(self, "userID"))
   {
       SpeakString("open");
       return;
   }
   SpeakString("closed");
}
