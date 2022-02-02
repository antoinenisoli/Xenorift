using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewStatLibrary", menuName = "Player/Stats/StatLibrary")]
public class StatLibrary : ScriptableObject
{
    [SerializeField] Color[] qualityColors = new Color[] { Color.white };
    [SerializeField] StatData[] statData;

    [ContextMenu(nameof(CreateList))]
    private void CreateList()
    {
        System.Array array = System.Enum.GetValues(typeof(PlayerStat));
        statData = new StatData[array.Length];
        for (int i = 0; i < array.Length; i++)
        {
            PlayerStat type = (PlayerStat)array.GetValue(i);
            StatData data = new StatData();
            data.stat = type;
            statData[i] = data;
        }
    }
}
