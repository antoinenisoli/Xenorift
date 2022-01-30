using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyShooter : Enemy
{
    [SerializeField] Shooting shooting;

    public override void Start()
    {
        base.Start();
        shooting.Init();
    }

    public override void Attacking()
    {
        shooting.Update(distanceToPlayer < attackDistance);
    }

    public override void Update()
    {
        base.Update();
        if (!target)
            shooting.Update(false);
    }
}
