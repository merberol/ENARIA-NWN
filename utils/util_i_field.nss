/*
oAnchor -- the anchor object against which the angle of departure will be measured
oFloater -- the object whose position will be analyzed in comparison to oAnchor
fFieldOfView -- arc size of field of view to search within.  This should be the
    full arc size; if the field of view is +/- 90 degress, use 180.0.
fFacingOffset -- degree offset from oAnchor facing to center search; positive values
    are clockwise, negative values are counter-clockwise
fMaxDistance -- max distance to search to (0.0 = no distance limit)
fMinDistance -- min distance to search to (0.0 = oAnchor postion)
    Using 0.0 for both fMaxDistance and fMinDistance will remove the distance
    requirement and only angular measurement will be used to determine location
*/

int GetIsInField(object oAnchor, object oFloater,
                 float fMaxDistance = 0.0, float fMinDistance = 0.0,
                 float fFieldOfView = 180.0, float fFacingOffset = 0.0)
{
    // Objects must be in the same area
    if (GetArea(oAnchor) != GetArea(oFloater))
        return FALSE;

    // Keep all facings between 0.0 and 360.0
    // Accept negative fFacingOffset values
    float fFacing = GetFacing(oAnchor);
    if (fFacingOffset > 0.0)
    {
        fFacing += fFacingOffset;
        fFacing -= 360.0 * (IntToFloat(FloatToInt(fFacing / 360.0))); 
    }
    else if (fFacingOffset < 0.0)
    {   
        fFacingOffset *= -1;
        fFacingOffset -= 360.0 * (IntToFloat(FloatToInt(fFacingOffset / 360.0)));
        fFacing += 360.0 - fFacingOffset;
        fFacing -= 360.0 * (IntToFloat(FloatToInt(fFacing / 360.0)));
    }

    // Calculate angle between oAnchor and oFloater
    vector vVertex = GetPosition(oAnchor);
    vector vAnchor = AngleToVector(fFacing);
    vector vFloater = GetPosition(oFloater);
    
    vector vRelative;
    vRelative.x = vFloater.x - vVertex.x;
    vRelative.y = vFloater.y - vVertex.y;

    // fNumerator is vAnchor * vRelative (dot product)
    // fDenominator is ||vAnchor|| ||vRelative|| (magnitude product)
    float fNumerator = (vAnchor.x * vRelative.x) + (vAnchor.y * vRelative.y);
    float fDenominator = sqrt(pow(vAnchor.x, 2.0) + pow(vAnchor.y, 2.0)) *
                         sqrt(pow(vRelative.x, 2.0) + pow(vRelative.y, 2.0));

    float fQuotient = fNumerator / fDenominator;
    float fAngle = acos(fQuotient);    

    // Ensure max and min distances are valid
    fMinDistance = fMinDistance > 0.0 ? fMinDistance : 0.0;
    fMaxDistance = fMaxDistance > 0.0 ? fMaxDistance : 0.0;

    // If no distance requirements, return early
    if (fMinDistance == 0.0 && fMaxDistance == 0.0)
        return fAngle <= (fFieldOfView / 2.0);

    // Ensure distance requirements are met
    float fDistance = GetDistanceBetween(oAnchor, oFloater);
    if (fMaxDistance > fMinDistance)
        return fAngle <= (fFieldOfView / 2.0) &&
               fDistance >= fMinDistance &&
               fDistance <= fMaxDistance;
    else
        return fAngle <= (fFieldOfView / 2.0) &&
               fDistance >= fMinDistance;
}

int GetIsAhead(object oAnchor, object oFloater, 
               float fMaxDistance = 0.0, float fFieldOfView = 180.0)
{
    return GetIsInField(oAnchor, oFloater, fMaxDistance, 0.0, fFieldOfView, 0.0);
}

int GetIsBehind(object oAnchor, object oFloater, 
               float fMaxDistance = 0.0, float fFieldOfView = 180.0)
{
    return GetIsInField(oAnchor, oFloater, fMaxDistance, 0.0, fFieldOfView, 180.0);
}

int GetIsRightFlank(object oAnchor, object oFloater, 
               float fMaxDistance = 0.0, float fFieldOfView = 90.0)
{
    return GetIsInField(oAnchor, oFloater, fMaxDistance, 0.0, fFieldOfView, 90.0);
}

int GetIsLeftFlank(object oAnchor, object oFloater, 
               float fMaxDistance = 0.0, float fFieldOfView = 90.0)
{
    return GetIsInField(oAnchor, oFloater, fMaxDistance, 0.0, fFieldOfView, -90.0);
}

int GetIsFlanking(object oAnchor, object oFloater, 
               float fMaxDistance = 0.0, float fFieldOfView = 90.0)
{
    return GetIsLeftFlank(oAnchor, oFloater, fMaxDistance, fFieldOfView) ||
           GetIsRightFlank(oAnchor, oFloater, fMaxDistance, fFieldOfView);
}

