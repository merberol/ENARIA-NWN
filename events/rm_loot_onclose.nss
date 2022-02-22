void main()
{
object self = OBJECT_SELF;
object item = GetFirstItemInInventory(self);
if(!GetIsObjectValid(item)){DestroyObject(self, 5.0);}
}
