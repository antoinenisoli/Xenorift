using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class ShipController : Entity
{
    [Header(nameof(ShipController))]
    [SerializeField] float shootingSpeed = 10f;
    [SerializeField] PlayerShooting shooting;
    Vector3 inputs;
    Vector3 vel;
    bool isShooting;

    Vector3 futurePos => rb.velocity * GetSpeed() * Time.deltaTime;

    private void Start()
    {
        shooting.Init();
    }

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
        isShooting = Input.GetButton("Shoot");
        shooting.Update(isShooting);
    }

    float GetSpeed()
    {
        if (isShooting)
            return shootingSpeed;
        else
            return movingSpeed;
    }

    void ClampPosition()
    {
        if (!gameBounds.Contains(transform.position))
        {
            transform.position = GameDevHelper.ClampVector3(transform.position, gameBounds.size/2);
            //rb.velocity = Vector3.zero;
        }
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        GetInputs();
        vel = inputs * GetSpeed();
        vel.y = rb.velocity.y;

        ManageShooting();
        if (Input.GetButtonDown("FlipShip"))
        {
            EventManager.Instance.onPlayerFlip.Invoke();
            direction *= -1;
        }
    }

    void FixedUpdate()
    {
        Move();
        ClampPosition();
    }
}
