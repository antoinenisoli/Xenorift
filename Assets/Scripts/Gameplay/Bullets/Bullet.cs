using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Team
{
    Player,
    Enemy,
}

public class Bullet : MonoBehaviour, IProjectile
{
    protected Rigidbody rb;
    protected Entity myShooter;
    [SerializeField] protected Team team;
    [SerializeField] protected float speed = 10f;
    [SerializeField] protected int damage = 10;

    [Header("Feedbacks")]
    [SerializeField] protected string destroyVFXName;
    [SerializeField] protected string spawnSound, deathSound;

    public void Awake()
    {
        rb = GetComponent<Rigidbody>();
        Destroy(gameObject, 30f);
    }

    public void Start()
    {
        OnStart();
        WaveManager.Instance.AddProjectile(this);
    }

    public virtual void OnStart()
    {
        SoundManager.Instance.PlayAudio(spawnSound);
    }

    private void OnTriggerEnter(Collider other)
    {
        Entity entity = other.GetComponent<Entity>();
        if (entity && entity.team != team)
        {
            entity.TakeDamages(damage);
            Death();
        }

        Asteroid asteroid = other.GetComponent<Asteroid>();
        if (asteroid && team == Team.Player)
        {
            Death();
        }
    }

    private void OnDestroy()
    {
        WaveManager.Instance.RemoveProjectile(this);
    }

    public void Death()
    {
        if (!string.IsNullOrEmpty(deathSound))
            SoundManager.Instance.PlayAudio(deathSound);
        if (!string.IsNullOrEmpty(destroyVFXName))
            VFXManager.Instance.PlayVFX(destroyVFXName, transform.position);

        Destroy(gameObject);
    }

    public virtual void Shot(Vector3 direction, Entity origin)
    {
        rb = GetComponent<Rigidbody>();
        myShooter = origin;
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
