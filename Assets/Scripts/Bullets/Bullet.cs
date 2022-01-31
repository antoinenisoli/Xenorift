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

    public virtual void DoUpdate()
    {
        Vector3 stageDimensions = Camera.main.ScreenToWorldPoint(new Vector3(Screen.width, Screen.height, 0));
        stageDimensions *= 1.5f;
        if (transform.position.x > stageDimensions.y/2 || transform.position.x < -stageDimensions.y/2)
            Destroy(gameObject);
    }

    public void Update()
    {
        DoUpdate();
    }
}
