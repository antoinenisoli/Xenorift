using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PlayerShooting : Shooting
{
    public List<PlayerShootProfile> PlayerProfiles = new List<PlayerShootProfile>();
    public Dictionary<string, PlayerShootProfile> savedProfiles = new Dictionary<string, PlayerShootProfile>();

    public override void Init(Entity entity)
    {
        foreach (var item in PlayerProfiles)
        {
            savedProfiles.Add(item.name, item);
            item.shootTimer = item.shootRate;
        }
    }

    public override void Update(bool holding)
    {
        base.Update(holding);
        foreach (var item in savedProfiles.Values)
        {
            if (!item.Available())
            {
                item.shootTimer = item.shootRate;
                continue;
            }

            if (holding)
            {
                item.shootTimer += Time.deltaTime;
                if (item.shootTimer >= item.shootRate)
                {
                    item.shootTimer = 0;
                    Shoot(item);
                }
            }
            else
                item.shootTimer = item.shootRate;
        }
    }
}
