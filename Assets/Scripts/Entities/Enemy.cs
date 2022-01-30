using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class Enemy : Entity
{
    [Header(nameof(Enemy))]
    [SerializeField] ShipController target;
    [SerializeField] float stopDistance = 3f;
    [SerializeField] float attackDistance = 5f;
    [SerializeField] Shooting shooting;
    float distanceToPlayer;
    Vector3 velocity;
    bool up = true;

    private void OnDrawGizmosSelected()
    {
        if (target && GameManager.Instance)
        {
            Vector3 v = transform.position;
            v.x = GameManager.Instance.moveBounds.max.x;
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
        Vector3 vel;
        float offset = 10;
        if (transform.position.z > gameBounds.size.z/2 - offset && up)
        {
            rb.velocity = Vector3.zero;
            up = false;
        }
        else if (transform.position.z < -gameBounds.size.z/2 + offset && !up)
        {
            rb.velocity = Vector3.zero;
            up = true;
        }

        if (up)
            vel = transform.right;
        else 
            vel = -transform.right;

        if (distanceToPlayer > stopDistance)
            vel += transform.forward;

        Accelerate(vel.normalized * movingSpeed);
    }

    void Attacking()
    {
        shooting.Update(distanceToPlayer < attackDistance);
    }

    private void Update()
    {
        if (target)
        {
            distanceToPlayer = transform.position.x - GameManager.Instance.moveBounds.max.x;
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
