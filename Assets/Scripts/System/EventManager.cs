using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EventManager : MonoBehaviour
{
    public static EventManager Instance;
    public class FloatEvent : UnityEvent<float> { }

    public UnityEvent onPlayerFlip = new UnityEvent();
    public UnityEvent onPlayerDamaged = new UnityEvent();
    public UnityEvent onPlayerHeal = new UnityEvent();
    public UnityEvent onPlayerDeath = new UnityEvent();
    public UnityEvent onPlayerSpawn = new UnityEvent();
    public UnityEvent onGameOver = new UnityEvent();
    public UnityEvent onAreaCompleted = new UnityEvent();
    public FloatEvent onNewWave = new FloatEvent();

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
    }
}
