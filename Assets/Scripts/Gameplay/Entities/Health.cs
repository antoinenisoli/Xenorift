using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Health
{
    [SerializeField] int currentHealth;
    [SerializeField] int maxHealth = 50;
    public bool isDead => CurrentHealth <= 0;

    public int CurrentHealth
    {
        get => currentHealth;
        set
        {
            if (value < 0)
                value = 0;

            if (value > maxHealth)
                value = maxHealth;

            currentHealth = value;
        }
    }

    public int MaxHealth { get => maxHealth; set => maxHealth = value; }

    public void Initialize()
    {
        CurrentHealth = MaxHealth;
    }
}
