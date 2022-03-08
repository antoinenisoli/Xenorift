using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Heal : PowerUp
{
    public override void Effect()
    {
        GameManager.Instance.NewLife(1);
    }
}
