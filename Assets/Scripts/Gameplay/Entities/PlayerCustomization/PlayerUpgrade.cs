using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum StatType
{
    HP,
    Damage,
    Speed,
    BulletSpeed,
}

[System.Serializable]
public class PlayerUpgrade
{
    public int moneyCost = 15;
    public StatType statToUpgrade;
    public int upgradeValue;
    public int quality;

    public PlayerUpgrade(int moneyCost, StatType statToUpgrade, int upgradeValue, int quality)
    {
        this.moneyCost = moneyCost;
        this.statToUpgrade = statToUpgrade;
        this.upgradeValue = upgradeValue;
        this.quality = quality;
    }
}
