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

    public override void Shot(Vector3 direction)
    {
        targetVelocity = direction * speed;
        rb = GetComponent<Rigidbody>();
        rb.velocity = direction * startSpeed;
    }

    public virtual void Update()
    {
        transform.rotation = targetRotation;
    }

    public virtual void FixedUpdate()
    {
        rb.velocity = Vector3.Lerp(rb.velocity, targetVelocity, acceleration * Time.deltaTime);
        targetRotation = Quaternion.LookRotation(rb.velocity);
    }
}
