using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyShooter : Enemy
{
    [Header(nameof(EnemyShooter))]
    [SerializeField] EnemyShooting shooting;
    bool close;

    public override void DoStart()
    {
        base.DoStart();
        shooting.Init();
    }

    public override void Attacking()
    {
        shooting.Update(DistanceToPlayer() < attackDistance);
    }
}
