using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class AsteroidWaveProfile : WaveProfile
{
    [Header(nameof(AsteroidWaveProfile))]
    [SerializeField] [Range(0, 100)] protected int probability = 100;
    [SerializeField] protected Vector2 randomGenerationDelay;
    [SerializeField] protected Vector2 randomSpeedRange;

    float asteroidTimer;
    float asteroidDelay;

    public void Init()
    {
        asteroidTimer = 0;
        asteroidDelay = GameDevHelper.RandomInRange(randomGenerationDelay);
    }

    public void UpdateAsteroidWave(Vector3 leftPos, Vector3 rightPos, Transform asteroidParent = null)
    {
        if (generate && count > 0)
        {
            asteroidTimer += Time.deltaTime;
            if (asteroidTimer >= asteroidDelay)
            {
                Init();
                if (CheckProbability())
                    SpawnAsteroid(leftPos, rightPos, asteroidParent);
            }
        }
    }

    public bool CheckProbability()
    {
        int random = Random.Range(0, 101);
        if (random > probability)
            return false;

        return true;
    }

    public virtual void SpawnAsteroid(Vector3 leftPos, Vector3 rightPos, Transform parent = null)
    {
        count--;
        GameObject newAsteroid = Object.Instantiate(prefab, parent);
        Asteroid asteroid = newAsteroid.GetComponent<Asteroid>();

        float randomSpeed = GameDevHelper.RandomInRange(randomSpeedRange);
        asteroid.SetRandomSpeed(randomSpeed);
        asteroid.direction = GameManager.Instance.RandomDirection();
        Vector3 randomPos = GameManager.Instance.RandomPosAroundGameArea();

        if (asteroid.direction < 0)
            newAsteroid.transform.position = randomPos + leftPos;
        else
            newAsteroid.transform.position = randomPos + rightPos;
    }
}
