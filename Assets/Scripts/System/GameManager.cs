using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.PostProcessing;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    public int PlayerDirection = 1;

    public PostProcessVolume volume;
    ColorGrading colorGrading;
    float startTemperature;

    [Header("Player spawn")]
    public Health PlayerLife;
    public GameObject playerPrefab;
    [SerializeField] float respawnDelay = 1f;

    [Header("Move area")]
    [SerializeField] Color gizmoColor = Color.white;
    public Bounds moveBounds;
    List<IProjectile> projectiles = new List<IProjectile>();

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
        if (!volume)
            volume = FindObjectOfType<PostProcessVolume>();

        if (volume.profile.TryGetSettings(out ColorGrading colorGrading))
        {
            this.colorGrading = colorGrading;
            startTemperature = colorGrading.temperature.value;
        }

        EventManager.Instance.onPlayerFlip.AddListener(FlipPlayer);
        EventManager.Instance.onPlayerDeath.AddListener(SpawnPlayer);
        EventManager.Instance.onPlayerFlip.AddListener(ColorEffect);
        ClearProjectiles();
    }

    void ColorEffect()
    {
        DOVirtual.Float(startTemperature, 100, 0.1f, Set).SetUpdate(true).SetLoops(2, LoopType.Yoyo);
    }

    void Set(float f)
    {
        colorGrading.temperature.value = f;
    }

    public void ClearProjectiles()
    {
        foreach (IProjectile s in projectiles)
            s.Death();
    }

    public void AddProjectile(IProjectile projectile)
    {
        projectiles.Add(projectile);
    }

    public void RemoveProjectile(IProjectile projectile)
    {
        projectiles.Remove(projectile);
    }

    public int RandomDirection()
    {
        float random = Random.Range(0, 2);
        if (random > 0.5f)
            return 1;
        else
            return -1;
    }

    public Vector3 RandomPosAroundGameArea()
    {
        Vector3 range = moveBounds.extents;
        float randomZ = GameDevHelper.RandomInRange(new Vector2(-range.z, range.z));
        return Vector3.forward * randomZ;
    }

    public void SpawnPlayer()
    {
        SoundManager.Instance.PlayAudio("player_dead");
        PlayerLife.CurrentHealth--;
        EventManager.Instance.onPlayerDamaged.Invoke();

        if (PlayerLife.CurrentHealth <= 0)
            EventManager.Instance.onGameOver.Invoke();
        else
            StartCoroutine(Respawn(respawnDelay));
    }

    public void NewLife(int value)
    {
        PlayerLife.MaxHealth += value;
        PlayerLife.CurrentHealth += value;
        EventManager.Instance.onPlayerHeal.Invoke();
    }

    IEnumerator Respawn(float duration)
    {
        yield return new WaitForSeconds(duration);
        SoundManager.Instance.PlayAudio("player_respawn");
        GameObject player = Instantiate(playerPrefab);
        EventManager.Instance.onPlayerSpawn.Invoke();
        VFXManager.Instance.PlayVFX("LaserSpawn", player.transform.position);
    }

    public void FlipPlayer()
    {
        PlayerDirection *= -1;
    }
}
