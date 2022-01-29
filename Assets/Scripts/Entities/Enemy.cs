using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : Entity
{
    [Header(nameof(Enemy))]
    [SerializeField] Entity target;
    [SerializeField] float stopDistance = 3f;
    [SerializeField] float attackDistance = 5f;
    [SerializeField] Shooting shooting;
    float distanceToPlayer;

    private void Start()
    {
        if (!target)
            target = FindObjectOfType<ShipController>();
    }

    public override void Death()
    {
        base.Death();
        Feedbacks.ScreenShake(0.5f, 10, 90);
        Feedbacks.FreezeFrame(0.3f, 0.5f);
    }

    void Move()
    {
        if (distanceToPlayer > stopDistance)
            Accelerate(transform.forward * speed);
        else
            Decelerate();
    }

    void Attacking()
    {
        if (distanceToPlayer < attackDistance)
            shooting.Update(true);
        else
            shooting.Update(false);
    }

    private void Update()
    {
        if (target)
        {
            distanceToPlayer = transform.position.x - target.transform.position.x;
            Move();
            Attacking();
        }
        else
        {
            shooting.Update(false);
            Decelerate();
        }
    }
}
