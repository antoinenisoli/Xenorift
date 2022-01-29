using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PlayerShooting : Shooting
{
    public List<PlayerShootProfile> PlayerProfiles = new List<PlayerShootProfile>();

    public override void Init()
    {
        base.Init();
        foreach (var item in PlayerProfiles)
            savedProfiles.Add(item.name, item);
    }
}
