using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyShooter : Enemy
{
    [Header(nameof(EnemyShooter))]
    [SerializeField] EnemyShooting[] shooting;

    public override void DoStart()
    {
        base.DoStart();
        foreach (var item in shooting)
            item.Init(this);
    }

    public override void Attacking()
    {
        foreach (var item in shooting)
            item.Update(DistanceToPlayer() < attackDistance);
    }
}
