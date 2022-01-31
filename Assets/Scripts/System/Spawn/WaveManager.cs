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
    List<Asteroid> spawnedAsteroids = new List<Asteroid>();

    float generationDelay;
    float timer;

    private void Start()
    {
        generationDelay = GameDevHelper.RandomInRange(randomGenerationDelay);
        Spawn();
    }

    public Vector3 RandomPos()
    {
        Vector3 range = GameManager.Instance.moveBounds.extents;
        float randomZ = GameDevHelper.RandomInRange(new Vector2(-range.z + 5, range.z - 5));
        return Vector3.forward * randomZ;
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
            print("victory");
            EventManager.Instance.onAreaCompleted.Invoke();
        }
    }

    void SpawnAsteroid()
    {
        generationDelay = GameDevHelper.RandomInRange(randomGenerationDelay);
        GameObject newAsteroid = Instantiate(asteroidPrefab, asteroidParent);
        Asteroid asteroid = newAsteroid.GetComponent<Asteroid>();
        spawnedAsteroids.Add(asteroid);
        asteroid.direction = GameManager.Instance.RandomDirection();

        if (asteroid.direction < 0)
            newAsteroid.transform.position = RandomPos() + leftSpawn.position;
        else
            newAsteroid.transform.position = RandomPos() + rightSpawn.position;
    }

    void ManageSpawn()
    {
        if (index < waves.Length)
        {
            if (waves[index].Done)
                NextWave();
        }

        timer += Time.deltaTime;
        if (timer > generationDelay && spawnedAsteroids.Count < maxGeneratedAsteroids)
        {
            timer = 0;
            SpawnAsteroid();
        }
    }

    private void Update()
    {
        ManageSpawn();
    }
}
