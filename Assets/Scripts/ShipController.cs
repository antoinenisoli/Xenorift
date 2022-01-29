using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShipController : MonoBehaviour
{
    [SerializeField] float speed = 10f;
    [SerializeField] float acceleration = 10f;
    [SerializeField] float friction = 10f;
    Rigidbody rb;
    Vector3 inputs;
    Vector3 vel;

    [SerializeField] Transform shootPos;
    [SerializeField] GameObject bulletPrefab;
    [SerializeField] float shootRate = 0.5f;
    float shootTimer;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    void GetInputs()
    {
        float xInput = Input.GetAxis("Horizontal");
        float yInput = Input.GetAxis("Vertical");
        inputs = new Vector3(xInput, 0, yInput).normalized;
    }

    void Move()
    {
        if (inputs.sqrMagnitude <= 0)
            rb.velocity = Vector3.Lerp(rb.velocity, Vector3.zero, friction * Time.deltaTime);
        else
            rb.velocity = Vector3.Lerp(rb.velocity, vel, acceleration * Time.deltaTime);
    }

    void ManageShooting()
    {
        if (Input.GetButton("Shoot"))
        {
            shootTimer += Time.deltaTime;
            if (shootTimer >= shootRate)
            {
                shootTimer = 0;
                GameObject bullet = Instantiate(bulletPrefab, shootPos.position, Quaternion.identity);
                Bullet b = bullet.GetComponent<Bullet>();
                b.Shot(shootPos.forward);
            }
        }
        else
            shootTimer = shootRate;
    }

    private void Update()
    {
        GetInputs();
        vel = inputs * speed;
        vel.y = rb.velocity.y;

        ManageShooting();
        if (Input.GetButtonDown("FlipShip"))
            transform.Rotate(Vector3.up * 180);
    }

    private void FixedUpdate()
    {
        Move();
    }
}
