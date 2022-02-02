using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "StatLibrary")]
public class StatLibrary : ScriptableObject
{
    [SerializeField] Color[] qualityColors = new Color[] { Color.white };
    [SerializeField] StatData[] statData;
}
