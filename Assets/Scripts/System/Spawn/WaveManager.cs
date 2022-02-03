using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public enum WaveType
{
    Enemy,
    AsteroidOnly,
}

public class WaveManager : MonoBehaviour
{
    public static WaveManager Instance;
    [SerializeField] Transform enemyParent, asteroidParent;
    [SerializeField] Transform leftSpawn, rightSpawn;
    [SerializeField] Wave[] waves;

    List<IProjectile> projectiles = new List<IProjectile>();
    int index;

    public Wave currentWave => waves[index];

    public void Awake()
    {
        if (!Instance)
            Instance = this;
        else
            Destroy(gameObject);

        var list = FindObjectsOfType<MonoBehaviour>().OfType<IProjectile>();
        foreach (IProjectile s in list)
            s.Death();
    }

    private void OnValidate()
    {
        foreach (var profile in waves)
        {
            profile.asteroidSpawnProfile.OnValidate();
            profile.asteroidWallSpawnProfile.OnValidate();
            foreach (var enemyWave in profile.enemySpawnProfiles)
                enemyWave.OnValidate();
        }
    }

    public void Start()
    {
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
        currentWave.Spawn(leftSpawn.position, rightSpawn.position, enemyParent);
    }

    void ClearCurrentWave()
    {
        foreach (IProjectile s in projectiles)
            s.Death();
    }

    IEnumerator StartNewWave()
    {
        yield return new WaitForEndOfFrame();
        SoundManager.Instance.PlayAudio("alarm");
        EventManager.Instance.onNewWave.Invoke(currentWave.delay - 1);
        yield return new WaitForSeconds(currentWave.delay);
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
        ClearCurrentWave();

        if (index < waves.Length)
        {
            StopAllCoroutines();
            StartCoroutine(StartNewWave());
        }
        else
            EventManager.Instance.onAreaCompleted.Invoke();
    }

    void ManageSpawn()
    {
        if (index < waves.Length)
        {
            if (currentWave.CheckEnd() && currentWave.Started)
            {
                index++;
                NextWave();
            }
        }
    }

    private void Update()
    {
        ManageSpawn();
        if (index < waves.Length)
            currentWave.UpdateWaves(leftSpawn.position, rightSpawn.position, asteroidParent);
    }
}
