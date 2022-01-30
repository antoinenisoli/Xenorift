using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    public int PlayerDirection = 1;

    [Header("player spawn")]
    public Health PlayerLife;
    public GameObject playerPrefab;
    [SerializeField] float respawnDelay = 1f;

    [Header("Move area")]
    [SerializeField] Color gizmoColor = Color.white;
    public Bounds moveBounds;

    private void OnDrawGizmos()
    {
        Gizmos.color = gizmoColor;
        Gizmos.DrawCube(moveBounds.center, moveBounds.size);
    }

    private void Awake()
    {
        PlayerLife.Initialize();
        if (!Instance)
            Instance = this;
    }

    private void Start()
    {
        EventManager.Instance.onPlayerFlip.AddListener(FlipPlayer);
        EventManager.Instance.onPlayerDeath.AddListener(SpawnPlayer);
    }

    public void SpawnPlayer()
    {
        PlayerLife.CurrentHealth--;
        EventManager.Instance.onPlayerDamaged.Invoke();

        if (PlayerLife.CurrentHealth <= 0)
            EventManager.Instance.onGameOver.Invoke();
        else
            StartCoroutine(Respawn(respawnDelay));
    }

    IEnumerator Respawn(float duration)
    {
        yield return new WaitForSeconds(duration);
        Instantiate(playerPrefab);
        EventManager.Instance.onPlayerSpawn.Invoke();
    }

    public void FlipPlayer()
    {
        PlayerDirection *= -1;
    }
}
