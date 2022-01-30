using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Team
{
    Player,
    Enemy,
}

public class Bullet : MonoBehaviour
{
    protected Rigidbody rb;
    [SerializeField] protected Team team;
    [SerializeField] protected float speed = 10f;
    [SerializeField] protected int damage = 10;

    private void Awake()
    {
        Destroy(gameObject, 30f);
    }

    private void OnTriggerEnter(Collider other)
    {
        Entity entity = other.GetComponent<Entity>();
        if (entity && entity.team != team)
        {
            VFXManager.Instance.PlayVFX("Damaged", transform.position);
            entity.TakeDamages(damage);
            Destroy(gameObject);
        }
    }

    public virtual void Shot(Vector3 direction)
    {
        rb = GetComponent<Rigidbody>();
        rb.velocity = direction.normalized * speed;
    }
}
