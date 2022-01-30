using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyWaveManager : MonoBehaviour
{
    [SerializeField] Transform enemyParent;
    [SerializeField] Transform leftSpawn, rightSpawn;
    [SerializeField] EnemyWave[] waves;
    int index;

    private void Start()
    {
        Spawn();
    }

    void Spawn()
    {
        waves[index].Spawn(leftSpawn.position, rightSpawn.position, enemyParent);
    }

    IEnumerator StartNewWave()
    {
        yield return new WaitForSeconds(waves[index].delay);
        Spawn();
    }

    private void Update()
    {
        if (index < waves.Length)
        {
            if (waves[index].Done)
            {
                index++;
                if (index < waves.Length)
                    StartCoroutine(StartNewWave());
            }
        }
    }
}
