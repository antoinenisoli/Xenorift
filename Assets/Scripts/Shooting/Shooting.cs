using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public abstract class Shooting
{
    public virtual void Init() { }

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

    public virtual void Update(bool holding) { }
}
