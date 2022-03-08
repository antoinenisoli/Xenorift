using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class WaveProfile
{
    [Header(nameof(WaveProfile))]
    public bool generate = true;
    public int count = 10;
    public GameObject prefab;

    public virtual void OnValidate() { }
}
