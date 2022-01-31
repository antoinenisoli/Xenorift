using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveManager : MonoBehaviour
{
    [Header("Enemy waves")]
    [SerializeField] Transform enemyParent;
    [SerializeField] Transform leftSpawn, rightSpawn;
    [SerializeField] EnemyWave[] waves;
    int index;

    [Header("Asteroid waves")]
    public bool generateAsteroids;
    [SerializeField] Transform asteroidParent;
    [SerializeField] GameObject asteroidPrefab;
    [SerializeField] int maxGeneratedAsteroids = 50;
    [SerializeField] Vector2 randomGenerationDelay;

    private void Start()
    {
        Spawn();
    }

    void Spawn()
    {
        waves[index].Spawn(leftSpawn.position, rightSpawn.position, enemyParent);
        generateAsteroids = waves[index].enableAsteroids;
    }

    IEnumerator StartNewWave()
    {
        yield return new WaitForSeconds(waves[index].delay);
        Spawn();
    }

    void NextWave()
    {
        index++;
        if (index < waves.Length)
            StartCoroutine(StartNewWave());
        else
        {
            print("vicotry");
            EventManager.Instance.onAreaCompleted.Invoke();
        }
    }

    private void Update()
    {
        if (index < waves.Length)
        {
            if (waves[index].Done || Input.GetKeyDown(KeyCode.O))
                NextWave();
        }
    }
}
