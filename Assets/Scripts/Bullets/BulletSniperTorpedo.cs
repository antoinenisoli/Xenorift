using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletSniperTorpedo : BulletAccelerating
{
    [SerializeField] protected float rotationSpeed = 10f;
    [SerializeField] protected float maxDistance = 20f;
    PlayerController ship;
    bool active = true;
    Vector3 direction;

    public override void OnStart()
    {
        base.OnStart();
        EventManager.Instance.onPlayerSpawn.AddListener(GetPlayer);
        GetPlayer();
        if (ship)
        {
            direction = ship.transform.position - transform.position;
            transform.rotation = Quaternion.LookRotation(direction.normalized);
        }
    }

    void GetPlayer()
    {
        if (!ship)
            ship = FindObjectOfType<PlayerController>();
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        if (ship)
        {
            direction = ship.transform.position - transform.position;
            float dist = transform.position.x - ship.transform.position.x;
            print(direction);
            if (dist < maxDistance)
                active = false;

            if (active)
                targetRotation = Quaternion.Slerp(targetRotation, Quaternion.LookRotation(direction.normalized), rotationSpeed * Time.deltaTime);
        }
        else if (myShooter)
        {
            Enemy myEnemy = myShooter as Enemy;
            if (myEnemy)
                transform.rotation = Quaternion.Euler(Vector3.up * -90 * myEnemy.direction);
        }
    }

    public override void FixedUpdate()
    {
        targetVelocity = transform.forward * speed;
        rb.velocity = Vector3.Lerp(rb.velocity, targetVelocity, acceleration * Time.deltaTime);
    }
}
