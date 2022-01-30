using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Shooting
{
    ShootProfile profile;

    public Dictionary<string, ShootProfile> savedProfiles = new Dictionary<string, ShootProfile>();
    public List<ShootProfile> profilesToUse = new List<ShootProfile>();

    public virtual void Init()
    {
        foreach (var item in profilesToUse)
        {
            savedProfiles.Add(item.name, item);
            item.shootTimer = item.shootRate;
        }
    }

    public void SetProfile(string profileName)
    {
        profile = savedProfiles[profileName];
    }

    public virtual void Shoot(ShootProfile profile)
    {
        foreach (var item in profile.shootPositions)
        {
            if (!profile.Available())
                continue;

            GameObject bullet = Object.Instantiate(profile.bullet, item.position, Quaternion.identity);
            Bullet b = bullet.GetComponent<Bullet>();
            b.Shot(item.forward);
        }
    }

    public void Update(bool holding)
    {
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
