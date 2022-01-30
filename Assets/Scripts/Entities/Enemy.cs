using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public abstract class Enemy : Entity
{
    [Header(nameof(Enemy))]
    [SerializeField] protected ShipController target;
    [SerializeField] protected float stopDistance = 3f;
    [SerializeField] protected float attackDistance = 5f;
    protected float distanceToPlayer;
    protected Vector3 velocity;
    protected bool up = true;

    private void OnDrawGizmosSelected()
    {
        if (target && GameManager.Instance)
        {
            Vector3 v = transform.position;
            v.x = GameManager.Instance.moveBounds.max.x;
            Gizmos.DrawLine(transform.position, v - transform.forward * stopDistance);
        }
    }

    public override void DoStart()
    {
        base.DoStart();
        if (!target)
            target = FindObjectOfType<ShipController>();
    }

    public override void Death()
    {
        base.Death();
        Feedbacks.ScreenShake(0.3f, 3, 45);
        Feedbacks.FreezeFrame(0.3f, 0.2f);
    }

    Vector3 VerticalMove()
    {
        Vector3 vel;
        float offset = 10;
        if (transform.position.z > gameBounds.size.z / 2 - offset && up)
        {
            rb.velocity = Vector3.zero;
            up = false;
        }
        else if (transform.position.z < -gameBounds.size.z / 2 + offset && !up)
        {
            rb.velocity = Vector3.zero;
            up = true;
        }

        if (up)
            vel = transform.right;
        else
            vel = -transform.right;

        return vel;
    }

    public virtual void Move()
    {
        Vector3 vel = VerticalMove();
        if (distanceToPlayer > stopDistance)
            vel += transform.forward * direction;

        Accelerate(vel.normalized * movingSpeed);
    }

    public abstract void Attacking();

    public override void DoUpdate()
    {
        base.DoUpdate();
        if (target)
        {
            distanceToPlayer = transform.position.x - GameManager.Instance.moveBounds.max.x;
            Move();
            Attacking();
        }
        else
            Decelerate();
    }
}
