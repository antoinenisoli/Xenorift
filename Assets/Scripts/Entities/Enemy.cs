using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public abstract class Enemy : Entity
{
    [Header(nameof(Enemy))]
    [SerializeField] protected PlayerController target;
    [SerializeField] protected float stopDistance = 3f;
    [SerializeField] protected float attackDistance = 5f;
    protected Vector3 velocity;
    protected bool up = true;
    EnemyWave myWave;

    public float dist;

    private void OnDrawGizmosSelected()
    {
        if (target && GameManager.Instance)
        {
            Vector3 v = transform.position;
            v.x = GameManager.Instance.moveBounds.max.x;
            Gizmos.DrawLine(transform.position, v - transform.forward * stopDistance);
        }
    }

    public void Init(EnemyWave wave, int direction)
    {
        myWave = wave;
        this.direction = direction;
        transform.rotation = Quaternion.Euler(Vector3.up * -90 * direction);
    }

    private void OnDestroy()
    {
        myWave.Remove(this);
    }

    public override void DoStart()
    {
        base.DoStart();
        EventManager.Instance.onPlayerSpawn.AddListener(GetPlayer);
        GetPlayer();
    }

    void GetPlayer()
    {
        if (!target)
            target = FindObjectOfType<PlayerController>();
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
        if (transform.position.z > gameBounds.size.z / 2 - offset)
        {
            rb.velocity = Vector3.zero;
            up = false;
        }

        if (transform.position.z < -gameBounds.size.z / 2 + offset)
        {
            rb.velocity = Vector3.zero;
            up = true;
        }

        if (up)
            vel = Vector3.forward;
        else
            vel = Vector3.back;

        return vel;
    }

    public virtual void Move()
    {
        Vector3 vel = VerticalMove();
        if (DistanceToPlayer() > stopDistance)
            vel += transform.forward;

        Accelerate(vel.normalized * movingSpeed);
    }

    public float DistanceToPlayer()
    {
        float distance;
        if (direction < 0)
            distance = transform.position.x - GameManager.Instance.moveBounds.max.x;
        else
            distance = transform.position.x - GameManager.Instance.moveBounds.min.x;

        return Mathf.Abs(distance);
    }

    public abstract void Attacking();

    public override void DoUpdate()
    {
        base.DoUpdate();
        Move();
        dist = DistanceToPlayer();
        if (target)
            Attacking();
    }
}
