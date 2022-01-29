using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    public int PlayerDirection = 1;

    private void Awake()
    {
        if (!Instance)
            Instance = this;
    }

    private void Start()
    {
        EventManager.Instance.onPlayerFlip.AddListener(FlipPlayer);
    }

    public void FlipPlayer()
    {
        PlayerDirection *= -1;
    }
}
