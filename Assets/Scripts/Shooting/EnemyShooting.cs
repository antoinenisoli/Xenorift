using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class EnemyShooting : Shooting
{
    [SerializeField] ShootProfile profile;
    [SerializeField] Vector2 randomShootRateRange;
    float myShootRate;

    public override void Init(Entity entity)
    {
        base.Init(entity);
        myShootRate = GameDevHelper.RandomInRange(randomShootRateRange);
    }

    public override void Shoot(ShootProfile profile)
    {
        base.Shoot(profile);
        myShootRate = GameDevHelper.RandomInRange(randomShootRateRange);
    }

    public override void Update(bool holding)
    {
        if (!profile.Available())
        {
            profile.shootTimer = myShootRate;
            return;
        }

        if (holding)
        {
            profile.shootTimer += Time.deltaTime;
            if (profile.shootTimer >= myShootRate)
            {
                profile.shootTimer = 0;
                Shoot(profile);
            }
        }
        else
            profile.shootTimer = myShootRate;
    }
}
