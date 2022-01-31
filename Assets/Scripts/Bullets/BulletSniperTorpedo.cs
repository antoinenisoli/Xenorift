using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletSniperTorpedo : BulletAccelerating
{
    [SerializeField] protected float rotationSpeed = 10f;
    [SerializeField] protected float maxDistance = 20f;
    PlayerController ship;
    bool active = true;

    private void Awake()
    {
        ship = FindObjectOfType<PlayerController>();
        Vector3 direction = ship.transform.position - transform.position;
        transform.rotation = Quaternion.LookRotation(direction.normalized);
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        if (!ship)
            return;

        Vector3 direction = ship.transform.position - transform.position;
        float dist = transform.position.x - ship.transform.position.x;
        if (dist < maxDistance)
            active = false;

        if (active)
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(direction.normalized), rotationSpeed * Time.deltaTime);
    }

    public override void FixedUpdate()
    {
        targetVelocity = transform.forward * speed;
        rb.velocity = Vector3.Lerp(rb.velocity, targetVelocity, acceleration * Time.deltaTime);
    }
}
