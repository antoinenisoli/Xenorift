using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Entity : MonoBehaviour
{
    public Health Health;
    public Team team;
    public int direction = 1;
    [SerializeField] protected Transform visual;
    [SerializeField] protected float movingSpeed = 15f;
    [SerializeField] protected float acceleration = 10f;
    [SerializeField] protected float friction = 10f;
    protected Rigidbody rb;
    protected Bounds gameBounds => GameManager.Instance.moveBounds;

    public void Awake()
    {
        rb = GetComponent<Rigidbody>();
        Health.Initialize();
    }

    public virtual void Death()
    {
        VFXManager.Instance.PlayVFX("Explosion", transform.position);
        Destroy(gameObject);
    }

    public void Decelerate()
    {
        rb.velocity = Vector3.Lerp(rb.velocity, Vector3.zero, friction * Time.deltaTime);
    }

    public void Accelerate(Vector3 targetVelocity)
    {
        rb.velocity = Vector3.Lerp(rb.velocity, targetVelocity, acceleration * Time.deltaTime);
    }

    public virtual void TakeDamages(int value)
    {
        Health.CurrentHealth -= value;
        if (Health.CurrentHealth <= 0)
            Death();

        if (visual)
        {
            visual.DOComplete();
            visual.DOShakePosition(0.2f, 2, 90);
        }
    }
}
