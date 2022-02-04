using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class PowerUp : MonoBehaviour
{
    PlayerController player;

    private void OnTriggerEnter(Collider other)
    {
        player = other.GetComponent<PlayerController>();
        if (player)
        {
            Effect();
            Destroy(gameObject);
        }
    }

    public abstract void Effect();
}
