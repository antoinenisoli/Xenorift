using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ShootProfile
{
    public string name;
    public GameObject bullet;
    public float shootRate = 0.5f;
    [HideInInspector] public float shootTimer;

    public virtual bool Available() => true;
}
