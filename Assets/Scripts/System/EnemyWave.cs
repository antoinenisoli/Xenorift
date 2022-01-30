using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct WaveProfile
{
    public int count;
    public GameObject enemyPrefab;
}

[System.Serializable]
public class EnemyWave
{
    public int order = 1;
    public float delay = 2f;
    public bool Done;
    public WaveProfile[] waveProfiles;
    List<Enemy> enemies = new List<Enemy>();

    Vector3 RandomPos()
    {
        Vector3 range = GameManager.Instance.moveBounds.extents;
        float randomZ = GameDevHelper.RandomInRange(new Vector2(-range.z, range.z));
        return Vector3.forward * randomZ;
    }

    public List<Enemy> Spawn(Vector3 leftPos, Vector3 rightPos, Transform parent = null)
    {
        foreach (var item in waveProfiles)
            for (int i = 0; i < item.count; i++)
            {
                int direction = GameManager.Instance.RandomDirection();
                Enemy enemy = Object.Instantiate(item.enemyPrefab, parent).GetComponent<Enemy>();
                if (direction < 0)
                    enemy.transform.position = RandomPos() + leftPos;
                else
                    enemy.transform.position = RandomPos() + rightPos;

                enemy.Init(this, direction);
                enemies.Add(enemy);
            }

        return enemies;
    }

    public void Remove(Enemy enemy)
    {
        enemies.Remove(enemy);
        if (enemies.Count <= 0)
            Done = true;
    }
}
