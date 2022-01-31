using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class EnemyWave : Wave
{
    List<Enemy> enemies = new List<Enemy>();

    public override List<GameObject> Spawn(Vector3 leftPos, Vector3 rightPos, Transform parent = null)
    {
        List<GameObject> list = base.Spawn(leftPos, rightPos, parent);
        for (int i = 0; i < list.Count; i++)
        {
            Enemy enemy = list[i].GetComponent<Enemy>();
            if (enemy)
            {
                enemies.Add(enemy);
                enemy.Init(this, directions[i]);
            }
        }

        return list;
    }

    public void Remove(Enemy enemy)
    {
        enemies.Remove(enemy);
        if (enemies.Count <= 0)
            Done = true;
    }
}
