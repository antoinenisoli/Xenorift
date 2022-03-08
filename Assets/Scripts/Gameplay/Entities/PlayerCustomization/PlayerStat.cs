using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PlayerStat
{
    public int currentValue, maxValue, baseValue;
    public StatType myType;
    public List<PlayerUpgrade> buyedUpgrades = new List<PlayerUpgrade>();

    public int ComputeValue()
    {
        int i = baseValue;
        foreach (var item in buyedUpgrades)
            i += item.upgradeValue;

        return i;
    }

    public void NewUpgrade(PlayerUpgrade upgrade)
    {
        buyedUpgrades.Add(upgrade);
    }
}
