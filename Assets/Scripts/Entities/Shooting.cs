using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Shooting
{
    public Transform shootPos;
    public GameObject bulletPrefab;
    public float shootRate = 0.5f;
    float shootTimer;

    void Shoot()
    {
        GameObject bullet = Object.Instantiate(bulletPrefab, shootPos.position, Quaternion.identity);
        Bullet b = bullet.GetComponent<Bullet>();
        b.Shot(shootPos.forward);
    }

    public void Update(bool holding)
    {
        if (holding)
        {
            shootTimer += Time.deltaTime;
            if (shootTimer >= shootRate)
            {
                shootTimer = 0;
                Shoot();
            }
        }
        else
            shootTimer = shootRate;
    }
}
