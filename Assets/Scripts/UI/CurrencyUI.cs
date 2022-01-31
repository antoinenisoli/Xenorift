using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CurrencyUI : MonoBehaviour
{
    [SerializeField] Text currencyText;

    private void Update()
    {
        if (currencyText)
            currencyText.text = UpgradeManager.Instance.Currency + "";
    }
}
