using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ShootProfile
{
    public string name = "Regular";
    public GameObject bullet;
    public Transform[] shootPositions;
    [HideInInspector] public float shootTimer;

    public virtual bool Available() => true;
}
