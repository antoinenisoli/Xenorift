using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Wave
{
    public string name = "Wave";
    public WaveType waveType;
    public float delay = 5f;
    public float maxDuration = 500;
    public bool Started, Done;
    public AsteroidWaveProfile asteroidSpawnProfile;
    public AsteroidWallWaveProfile asteroidWallSpawnProfile;
    public WaveProfile[] enemySpawnProfiles;

    List<Enemy> enemies = new List<Enemy>();
    float timer;

    public void Spawn(Vector3 leftPos, Vector3 rightPos, Transform enemiesParent = null)
    {
        Started = true;
        asteroidSpawnProfile.Init();
        asteroidWallSpawnProfile.Init();
        SpawnEnemies(leftPos, rightPos, enemiesParent);
    }

    public bool CheckEnd()
    {
        switch (waveType)
        {
            case WaveType.Enemy:
                return enemies.Count <= 0;
            case WaveType.AsteroidOnly:
                return timer > maxDuration;
        }

        return false;
    }

    public List<Enemy> SpawnEnemies(Vector3 leftPos, Vector3 rightPos, Transform parent = null)
    {
        List<Enemy> list = new List<Enemy>();
        foreach (var item in enemySpawnProfiles)
        {
            if (item.generate)
            {
                for (int i = 0; i < item.count; i++)
                {
                    int direction = GameManager.Instance.RandomDirection();
                    GameObject spawnedEntity = Object.Instantiate(item.prefab, parent);
                    Enemy enemy = spawnedEntity.GetComponent<Enemy>();
                    if (enemy)
                    {
                        enemies.Add(enemy);
                        enemy.Init(this, direction);
                    }

                    Vector3 randomPos = GameManager.Instance.RandomPosAroundGameArea();
                    if (direction < 0)
                        spawnedEntity.transform.position = randomPos + leftPos;
                    else
                        spawnedEntity.transform.position = randomPos + rightPos;
                }
            }
        }

        return list;
    }

    public void Remove(Enemy enemy)
    {
        enemies.Remove(enemy);
        Done = CheckEnd();
    }

    public void UpdateWaves(Vector3 leftPos, Vector3 rightPos, Transform asteroidParent = null)
    {
        if (Started)
        {
            timer += Time.deltaTime;
            asteroidSpawnProfile.UpdateAsteroidWave(leftPos, rightPos, asteroidParent = null);
            asteroidWallSpawnProfile.UpdateAsteroidWave(leftPos, rightPos, asteroidParent = null);
        }
    }
}
