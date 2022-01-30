using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour
{
    public int direction = 1;
    [SerializeField] Vector2 randomSpeedRange;
    float speed;
    [SerializeField] Material tangibleMat, intangibleMat;
    Collider myCollider;
    MeshRenderer meshRenderer;
    Rigidbody rb;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        meshRenderer = GetComponentInChildren<MeshRenderer>();
        myCollider = GetComponent<Collider>();
    }

    private void Start()
    {
        EventManager.Instance.onPlayerFlip.AddListener(UpdateState);
        speed = GameDevHelper.RandomInRange(randomSpeedRange);
        float random = Random.Range(0,2);
        if (random > 0.5f)
            direction = 1;
        else
            direction = -1;

        UpdateState();
    }

    private void OnTriggerEnter(Collider other)
    {
        ShipController player = other.GetComponent<ShipController>();
        if (player)
        {
            player.TakeDamages(1);
            Destroy(gameObject);
        }
    }

    private void UpdateState()
    {
        myCollider.enabled = GameManager.Instance.PlayerDirection == direction;
        for (int i = 0; i < meshRenderer.materials.Length; i++)
        {
            meshRenderer.materials[i] = myCollider.enabled ? tangibleMat : intangibleMat;
        }
    }

    private void FixedUpdate()
    {
        rb.velocity = transform.right * speed * direction;
    }
}
