using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class ShipController : Entity
{
    [Header(nameof(ShipController))]
    [SerializeField] Shooting shooting;
    Vector3 inputs;
    Vector3 vel;

    void GetInputs()
    {
        float xInput = Input.GetAxis("Horizontal");
        float yInput = Input.GetAxis("Vertical");
        inputs = new Vector3(xInput, 0, yInput).normalized;
    }

    void Move()
    {
        if (inputs.sqrMagnitude <= 0)
            Decelerate();
        else
            Accelerate(vel);
    }

    void ManageShooting()
    {
        if (Input.GetButton("Shoot"))
            shooting.Update(true);
        else
            shooting.Update(false);
    }

    private void Update()
    {
        GetInputs();
        vel = inputs * speed;
        vel.y = rb.velocity.y;

        ManageShooting();
        if (Input.GetButtonDown("FlipShip"))
            transform.Rotate(Vector3.up * 180);
    }

    private void FixedUpdate()
    {
        Move();
    }
}
