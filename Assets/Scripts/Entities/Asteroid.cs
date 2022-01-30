using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour
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
        PlayerController player = other.GetComponent<PlayerController>();
        if (player)
        {
            player.TakeDamages(1);
            Destroy(gameObject);
        }
    }

    private void UpdateState()
    {
        bool checkDirection = GameManager.Instance.PlayerDirection == direction;
        myCollider.enabled = checkDirection;
        Material[] newMaterials = meshRenderer.materials;
        for (int i = 0; i < newMaterials.Length; i++)
            newMaterials[i] = checkDirection ? tangibleMat : intangibleMat;

        meshRenderer.materials = newMaterials;
    }

    private void FixedUpdate()
    {
        rb.velocity = transform.right * speed * direction;
    }
}
