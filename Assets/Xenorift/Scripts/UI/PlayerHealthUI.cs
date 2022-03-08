using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerHealthUI : MonoBehaviour
{
    [SerializeField] GameObject hpSlotPrefab;
    [SerializeField] Transform grid;
    Image[] hpSlots;
    [SerializeField] Sprite fullSprite, emptySprite;

    Health health => GameManager.Instance.PlayerLife;

    private void Awake()
    {
        hpSlots = new Image[0];
    }

    private void Start()
    {
        EventManager.Instance.onPlayerDamaged.AddListener(UpdateUI);
        EventManager.Instance.onPlayerHeal.AddListener(GenerateSlots);
        GenerateSlots();
    }

    void GenerateSlots()
    {
        foreach (var item in hpSlots)
            Destroy(item.gameObject);

        hpSlots = new Image[health.CurrentHealth - 1];
        for (int i = 0; i < hpSlots.Length; i++)
        {
            Image image = Instantiate(hpSlotPrefab, grid).GetComponent<Image>();
            hpSlots[i] = image;
        }

        UpdateUI();
    }

    public void UpdateUI()
    {
        print("omg");
        for (int i = 0; i < hpSlots.Length; i++)
        {
            hpSlots[i].sprite = health.CurrentHealth - 1 <= i ? emptySprite : fullSprite;
            hpSlots[i].enabled = health.CurrentHealth - 1 <= i ? false : true;
        }
    }
}
