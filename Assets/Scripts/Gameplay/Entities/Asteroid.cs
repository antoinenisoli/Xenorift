using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour, IProjectile
{
    public int direction = 1;
    [SerializeField] Vector2 randomSpeedRange;
    float speed;
    Rigidbody rb;

    [SerializeField] Material tangibleMat, intangibleMat;
    Collider myCollider;
    MeshRenderer meshRenderer;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        meshRenderer = GetComponentInChildren<MeshRenderer>();
        myCollider = GetComponent<Collider>();
        Destroy(gameObject, 60f);
    }

    private void Start()
    {
        EventManager.Instance.onPlayerFlip.AddListener(UpdateState);
        speed = GameDevHelper.RandomInRange(randomSpeedRange);
        UpdateState();
    }

    private void OnDestroy()
    {
        WaveManager.Instance.RemoveProjectile(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        PlayerController player = other.GetComponent<PlayerController>();
        if (player)
        {
            player.TakeDamages(1);
            Death();
        }
    }

    public void Death()
    {
        VFXManager.Instance.PlayVFX("asteroid_tangible", transform.position);
        Destroy(gameObject);
    }

    private void UpdateState()
    {
        bool checkDirection = GameManager.Instance.PlayerDirection == direction;
        myCollider.enabled = checkDirection;
        Material[] newMaterials = meshRenderer.materials;
        newMaterials[0] = checkDirection ? tangibleMat : intangibleMat;
        meshRenderer.materials = newMaterials;

        string fxName = checkDirection ? "asteroid_tangible" : "asteroid_intangible";
        VFXManager.Instance.PlayVFX(fxName, transform.position);
    }

    private void FixedUpdate()
    {
        rb.velocity = Vector3.left * speed * direction;
    }
}
