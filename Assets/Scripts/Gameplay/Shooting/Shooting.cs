using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public abstract class Shooting
{
    Entity myEntity;

    public virtual void Init(Entity entity) { myEntity = entity; }

    public virtual void Shoot(ShootProfile profile)
    {
        foreach (var item in profile.shootPositions)
        {
            if (!profile.Available())
                continue;

            GameObject bullet = Object.Instantiate(profile.bullet, item.position, Quaternion.identity);
            Bullet b = bullet.GetComponent<Bullet>();
            b.Shot(item.forward, myEntity);
        }
    }

    public virtual void Update(bool holding) { }
}
