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
    [SerializeField] protected Transform enemyParent, asteroidParent;
    [SerializeField] protected Transform leftSpawn, rightSpawn;
    [SerializeField] protected Wave[] waves;

    int index;

    public Wave currentWave => waves[index];

    public void Awake()
    {
        if (!Instance)
            Instance = this;
        else
            Destroy(gameObject);
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

    public virtual void Start()
    {
        if (waves == null)
            waves = new Wave[0];

        NextWave();
    }

    void Spawn()
    {
        SoundManager.Instance.PlayAudio("new_wave");
        currentWave.Spawn(leftSpawn.position, rightSpawn.position, enemyParent);
    }

    IEnumerator StartNewWave()
    {
        yield return new WaitForEndOfFrame();
        SoundManager.Instance.PlayAudio("alarm");
        EventManager.Instance.onNewWave.Invoke(currentWave.delay - 1);
        yield return new WaitForSeconds(currentWave.delay);
        Spawn();
    }

    void NextWave()
    {
        GameManager.Instance.ClearProjectiles();

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
        if (currentWave.CheckEnd() && currentWave.Started)
        {
            index++;
            NextWave();
        }
    }

    private void Update()
    {
        if (waves != null && waves.Length > 0)
        {
            if (index < waves.Length)
            {
                ManageSpawn();
                currentWave.UpdateWaves(leftSpawn.position, rightSpawn.position, asteroidParent);
            }
        }
    }
}
