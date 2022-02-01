using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AreaBoundFX : MonoBehaviour
{
    [SerializeField] float minDistance = 3f;
    ParticleSystem fx;
    PlayerController player;
    Vector3 playerPos;
    [SerializeField] bool inside;

    private void Start()
    {
        fx = GetComponent<ParticleSystem>();
        fx.Stop();
        EventManager.Instance.onPlayerSpawn.AddListener(GetPlayer);
        GetPlayer();
    }

    private void GetPlayer()
    {
        player = FindObjectOfType<PlayerController>();
    }

    private void Update()
    {
        if (player)
            playerPos = player.transform.position;

        float dist = Vector3.Distance(playerPos, transform.position);
        if (dist < minDistance)
        {
            if (!inside)
            {
                inside = true;
                fx.Play();
            }
        }
        else if (inside)
        {
            inside = false;
            fx.Stop();
        }
    }
}
