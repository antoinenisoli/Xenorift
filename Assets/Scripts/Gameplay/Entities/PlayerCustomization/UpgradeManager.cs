using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
struct StatData
{
    public StatType stat;
    public Sprite statSprite;
    public RandomSelection[] randomQuality;
    public RandomSelection[] randomValue;
    public RandomSelection[] randomCost;
}

public class UpgradeManager : MonoBehaviour
{
    public static UpgradeManager Instance;
    public int Currency;
    [SerializeField] Color[] qualityColors;
    [SerializeField] int baseMoneyCost = 5;
    [SerializeField] StatData[] statData;
    Dictionary<StatType, StatData> storedStatData = new Dictionary<StatType, StatData>();

    [SerializeField] PlayerStat Health, Damage, Speed, BulletSpeed;
    Dictionary<StatType, PlayerStat> storedStats = new Dictionary<StatType, PlayerStat>();

    private void Awake()
    {
        if (!Instance)
        {
            Instance = this;
            foreach (var item in statData)
                storedStatData.Add(item.stat, item);

            DontDestroyOnLoad(this);
        }
        else
            Destroy(gameObject);
    }

    IEnumerator Start()
    {
        yield return new WaitForEndOfFrame();
        PlayerStat[] stats = new PlayerStat[] { Health, Damage, Speed, BulletSpeed };
        foreach (var item in stats)
            storedStats.Add(item.myType, item);

        RefreshShop();
    }

    public PlayerStat GetStat(StatType type)
    {
        return storedStats[type];
    }

    public void AddCurrency(int value)
    {
        Currency += value;
    }

    int ComputeMoney(int quality, int value)
    {
        int compute = baseMoneyCost * quality;
        float money = ((float)(value * 10)) / 100 * (float)compute;
        return Mathf.RoundToInt(money + compute);
    }

    public PlayerUpgrade RandomUpgrade()
    {
        System.Array array = System.Enum.GetValues(typeof(StatType));
        int random = Random.Range(0, array.Length);
        StatType randomStat = (StatType)array.GetValue(random);

        int randomQuality = GameDevHelper.GetRandomValue(
            new RandomSelection(0, 0, 0.7f),
            new RandomSelection(1, 2, 0.3f),
            new RandomSelection(2, 3, 0.15f),
            new RandomSelection(3, 4, 0.05f)
            );

        int randomValue = GameDevHelper.GetRandomValue(
            new RandomSelection(1, 2, 0.7f),
            new RandomSelection(2, 3, 0.15f),
            new RandomSelection(3, 4, 0.1f),
            new RandomSelection(4, 6, 0.05f)
            );

        int moneyCost = ComputeMoney(randomQuality + 1, randomValue);
        return new PlayerUpgrade(moneyCost, randomStat, randomValue * (randomQuality + 1), randomQuality);
    }

    public void BuyUpgrade(int cost, PlayerUpgrade newUpgrade)
    {
        Currency -= cost;
        GetStat(newUpgrade.statToUpgrade).NewUpgrade(newUpgrade);
        RefreshShop();
    }

    public Sprite StatSprite(StatType stat)
    {
        return storedStatData[stat].statSprite;
    }

    public Color QualityColor(int quality)
    {
        return qualityColors[quality];
    }

    public bool CanBuy(PlayerUpgrade upgrade)
    {
        return upgrade.moneyCost <= Currency;
    }

    public void RefreshShop()
    {
        UpgradeButton[] upgradeButtons = FindObjectsOfType<UpgradeButton>();
        foreach (var item in upgradeButtons)
        {
            Button uiButton = item.GetComponent<Button>();
            uiButton.interactable = CanBuy(item.myUpgrade);
        }
    }
}
