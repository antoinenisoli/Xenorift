using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyShooter : Enemy
{
    [Header(nameof(EnemyShooter))]
    [SerializeField] Shooting shooting;

    public override void DoStart()
    {
        base.DoStart();
        shooting.Init();
    }

    public override void Attacking()
    {
        shooting.Update(DistanceToPlayer() < attackDistance);
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        if (!target)
            shooting.Update(false);
    }
}
