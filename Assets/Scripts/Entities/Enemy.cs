using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : Entity
{
    [Header(nameof(Enemy))]
    [SerializeField] ShipController target;
    [SerializeField] float stopDistance = 3f;
    [SerializeField] float attackDistance = 5f;
    [SerializeField] Shooting shooting;
    float distanceToPlayer;

    private void OnDrawGizmosSelected()
    {
        if (target)
        {
            Vector3 v = transform.position;
            v.x = target.moveBounds.max.x;
            Gizmos.DrawLine(transform.position, v - transform.forward * stopDistance);
        }
    }

    private void Start()
    {
        shooting.Init();
        if (!target)
            target = FindObjectOfType<ShipController>();
    }

    public override void Death()
    {
        base.Death();
        Feedbacks.ScreenShake(0.3f, 3, 45);
        Feedbacks.FreezeFrame(0.3f, 0.2f);
    }

    void Move()
    {
        if (distanceToPlayer > stopDistance)
            Accelerate(transform.forward * movingSpeed);
        else
            Decelerate();
    }

    void Attacking()
    {
        shooting.Update(distanceToPlayer < attackDistance);
    }

    private void Update()
    {
        if (target)
        {
            distanceToPlayer = transform.position.x - target.moveBounds.max.x;
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
