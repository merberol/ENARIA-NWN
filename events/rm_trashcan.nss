void main()
{
    object self = OBJECT_SELF;
    object item = GetFirstItemInInventory(self);
    while(GetIsObjectValid(item))
    {
        DestroyObject(item);
    }
}
