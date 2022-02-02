using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PlayerShootProfile : ShootProfile
{
    public float shootRate = 0.5f;
    public int Direction = 1;

    public override bool Available()
    {
        return Direction == GameManager.Instance.PlayerDirection;
    }
}
