using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletSniperTorpedo : BulletAccelerating
{
    [SerializeField] protected float rotationSpeed = 10f;
    ShipController ship;

    private void Awake()
    {
        ship = FindObjectOfType<ShipController>();
    }

    public override void Update()
    {
        targetRotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(ship.transform.position), rotationSpeed * Time.deltaTime);
        base.Update();
    }
}
