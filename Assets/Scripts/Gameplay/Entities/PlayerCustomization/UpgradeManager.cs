using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
struct StatData
{
    public PlayerStat stat;
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
    Dictionary<PlayerStat, StatData> data = new Dictionary<PlayerStat, StatData>();

    private void Awake()
    {
        if (!Instance)
        {
            Instance = this;
            foreach (var item in statData)
                data.Add(item.stat, item);

            DontDestroyOnLoad(this);
        }
        else
            Destroy(gameObject);
    }

    IEnumerator Start()
    {
        yield return new WaitForEndOfFrame();
        RefreshShop();
    }

    public void AddCurrency(int value)
    {
        Currency += value;
    }

    int ComputeMoney(int quality, int value)
    {
        int compute = baseMoneyCost * quality;
        float money = ((float)(value * 10)) / 100 * (float)compute;
        print(money);
        return Mathf.RoundToInt(money + compute);
    }

    public PlayerUpgrade RandomUpgrade()
    {
        System.Array array = System.Enum.GetValues(typeof(PlayerStat));
        int random = Random.Range(0, array.Length);
        PlayerStat randomStat = (PlayerStat)array.GetValue(random);

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

    public void BuyUpgrade(int cost)
    {
        Currency -= cost;
        RefreshShop();
    }

    public Sprite StatSprite(PlayerStat stat)
    {
        return data[stat].statSprite;
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
