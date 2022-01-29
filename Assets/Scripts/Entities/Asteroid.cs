using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : Entity
{
    Collider myCollider;

    private void Start()
    {
        direction = Random.Range(0, 2);
        myCollider = GetComponent<Collider>();
    }

    private void Update()
    {
        myCollider.enabled = GameManager.Instance.PlayerDirection == direction;
    }

    private void FixedUpdate()
    {
        Accelerate(transform.right * movingSpeed);
    }
}
