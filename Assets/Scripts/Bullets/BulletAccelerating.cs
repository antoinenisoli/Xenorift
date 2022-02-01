using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletAccelerating : Bullet
{
    [Header(nameof(BulletAccelerating))]
    protected Vector3 targetVelocity;
    [SerializeField] protected float startSpeed = 3;
    [SerializeField] protected float acceleration;
    protected Quaternion targetRotation;

    public override void Shot(Vector3 direction, Entity origin)
    {
        base.Shot(direction, origin);
        targetVelocity = direction * speed;
        rb.velocity = direction * startSpeed;
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        transform.rotation = targetRotation;
    }

    public virtual void FixedUpdate()
    {
        rb.velocity = Vector3.Lerp(rb.velocity, targetVelocity, acceleration * Time.deltaTime);
        targetRotation = Quaternion.LookRotation(rb.velocity);
    }
}
