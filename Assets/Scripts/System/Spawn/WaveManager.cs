using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class WaveManager : MonoBehaviour
{
    public static WaveManager Instance;
    List<IProjectile> projectiles = new List<IProjectile>();

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

    private void Awake()
    {
        if (!Instance)
            Instance = this;
        else
            Destroy(gameObject);

        var list = FindObjectsOfType<MonoBehaviour>().OfType<IProjectile>();
        foreach (IProjectile s in list)
            s.Death();
    }

    private void Start()
    {
        generationDelay = GameDevHelper.RandomInRange(randomGenerationDelay);
        NextWave();
    }

    public Vector3 RandomPos()
    {
        Vector3 range = GameManager.Instance.moveBounds.extents;
        float randomZ = GameDevHelper.RandomInRange(new Vector2(-range.z + 5, range.z - 5));
        return Vector3.forward * randomZ;
    }

    void Spawn()
    {
        SoundManager.Instance.PlayAudio("new_wave");
        waves[index].Spawn(leftSpawn.position, rightSpawn.position, enemyParent);
        generateAsteroids = waves[index].enableAsteroids;
    }

    IEnumerator StartNewWave()
    {
        foreach (IProjectile s in projectiles)
            s.Death();

        yield return new WaitForEndOfFrame();
        SoundManager.Instance.PlayAudio("alarm");
        EventManager.Instance.onNewWave.Invoke(waves[index].delay - 1);
        yield return new WaitForSeconds(waves[index].delay);
        StartCoroutine(NewAsteroidWave());
        Spawn();
    }

    public void AddProjectile(IProjectile projectile)
    {
        projectiles.Add(projectile);
    }

    public void RemoveProjectile(IProjectile projectile)
    {
        projectiles.Remove(projectile);
    }

    void NextWave()
    {
        if (index < waves.Length)
        {
            StopAllCoroutines();
            StartCoroutine(StartNewWave());
        }
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

        AddProjectile(asteroid);
    }

    IEnumerator NewAsteroidWave()
    {
        while (true)
        {
            yield return null;
            timer += Time.deltaTime;
            if (timer > generationDelay && spawnedAsteroids.Count < maxGeneratedAsteroids)
            {
                timer = 0;
                SpawnAsteroid();
            }
        }
    }

    void ManageSpawn()
    {
        if (index < waves.Length)
        {
            if (waves[index].Done)
            {
                index++;
                NextWave();
            }
        }
    }

    private void Update()
    {
        ManageSpawn();
    }
}
