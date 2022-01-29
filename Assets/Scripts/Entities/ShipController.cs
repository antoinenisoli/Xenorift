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

    [SerializeField] Color gizmoColor = Color.white;
    [SerializeField] Vector2 moveArea;
    Vector3 basePosition;
    [HideInInspector] public Bounds moveBounds;
    bool isShooting;

    private void OnDrawGizmos()
    {
        if (!Application.isPlaying)
        {
            moveBounds.size = new Vector3(moveArea.x, 0, moveArea.y);
            moveBounds.center = transform.position;
        }

        Gizmos.color = gizmoColor;
        Gizmos.DrawCube(moveBounds.center, moveBounds.size);
    }

    private void Start()
    {
        shooting.Init();
        basePosition = transform.position;
        moveBounds.size = new Vector3(moveArea.x, 0, moveArea.y);
        moveBounds.center = basePosition;
    }

    Rect MoveRect()
    {
        if (Application.isPlaying)
            return new Rect(basePosition, moveArea);
        else
            return new Rect(transform.position, moveArea);
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

    private void Update()
    {
        GetInputs();
        vel = inputs * GetSpeed();
        vel.y = rb.velocity.y;

        ManageShooting();
        if (Input.GetButtonDown("FlipShip"))
        {
            EventManager.Instance.onPlayerFlip.Invoke();
            direction *= -1;
            transform.rotation = Quaternion.Euler(Vector3.up * 90 * direction);
        }
    }

    private void FixedUpdate()
    {
        Move();
        if (!moveBounds.Contains(transform.position))
        {
            print("out");
            rb.velocity = -rb.velocity.normalized * GetSpeed();
        }
    }
}
