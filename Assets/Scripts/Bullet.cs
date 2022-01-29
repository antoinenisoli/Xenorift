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
    Rigidbody rb;
    [SerializeField] Team team;
    [SerializeField] float speed = 10f;
    [SerializeField] int damage = 10;

    private void Awake()
    {
        Destroy(gameObject, 30f);
    }

    private void OnTriggerEnter(Collider other)
    {
        Entity entity = other.GetComponent<Entity>();
        if (entity && entity.team != team)
        {
            entity.TakeDamages(damage);
            Destroy(gameObject);
        }
    }

    public void Shot(Vector3 direction)
    {
        rb = GetComponent<Rigidbody>();
        rb.velocity = direction.normalized * speed;
    }
}
