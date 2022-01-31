using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UpgradeButton : MonoBehaviour
{
    [SerializeField] Image image, border;
    [SerializeField] Text costText, effectText;
    public PlayerUpgrade myUpgrade;

    private void Start()
    {
        myUpgrade = UpgradeManager.Instance.RandomUpgrade();
        if (myUpgrade == null)
            return;

        Color c = UpgradeManager.Instance.QualityColor(myUpgrade.quality);
        image.sprite = UpgradeManager.Instance.StatSprite(myUpgrade.statToUpgrade);
        border.color = c;
        costText.text = myUpgrade.moneyCost + " G";
        effectText.text = "+ " + myUpgrade.upgradeValue + "";
        costText.color = c;
        effectText.color = c;
    }

    public void Buy()
    {
        UpgradeManager.Instance.BuyUpgrade(myUpgrade.moneyCost);
        Destroy(gameObject);
    }
}
