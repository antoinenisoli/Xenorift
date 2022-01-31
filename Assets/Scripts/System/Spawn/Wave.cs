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
public class Wave
{
    public float delay = 2f;
    public bool enableAsteroids = true;
    public bool Done;
    public WaveProfile[] waveProfiles;
    protected List<int> directions = new List<int>();

    Vector3 RandomPos()
    {
        Vector3 range = GameManager.Instance.moveBounds.extents;
        float randomZ = GameDevHelper.RandomInRange(new Vector2(-range.z, range.z));
        return Vector3.forward * randomZ;
    }

    public virtual List<GameObject> Spawn(Vector3 leftPos, Vector3 rightPos, Transform parent = null)
    {
        List<GameObject> list = new List<GameObject>();
        foreach (var item in waveProfiles)
            for (int i = 0; i < item.count; i++)
            {
                int direction = GameManager.Instance.RandomDirection();
                directions.Add(direction);
                GameObject spawnedEntity = Object.Instantiate(item.enemyPrefab, parent);
                if (direction < 0)
                    spawnedEntity.transform.position = RandomPos() + leftPos;
                else
                    spawnedEntity.transform.position = RandomPos() + rightPos;

                list.Add(spawnedEntity);
            }

        return list;
    }
}
