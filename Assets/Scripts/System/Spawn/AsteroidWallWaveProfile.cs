using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class AsteroidWallWaveProfile : AsteroidWaveProfile
{
    [Header(nameof(AsteroidWallWaveProfile))]
    [SerializeField] Vector2Int wallSize;
    [SerializeField] Vector2 distanceBetween = new Vector2(14f, 16f);

    public override void SpawnAsteroid(Vector3 leftPos, Vector3 rightPos, Transform parent = null)
    {
        count--;
        Vector3 startPosition;
        Vector3 newPos;
        int dir = GameManager.Instance.RandomDirection();
        float randomSpeed = GameDevHelper.RandomInRange(randomSpeedRange);

        if (dir < 0)
            startPosition = leftPos;
        else
            startPosition = rightPos;

        startPosition += GameManager.Instance.RandomPosAroundGameArea();
        Vector2Int converted = Clamp(wallSize);
        MonoBehaviour.print(converted);
        for (int x = -converted.x; x < converted.x + 1; x++)
        {            
            for (int y = -converted.y; y < converted.y + 1; y++)
            {
                GameObject newAsteroid = Object.Instantiate(prefab, parent);
                Asteroid asteroid = newAsteroid.GetComponent<Asteroid>();
                asteroid.SetRandomSpeed(randomSpeed);
                asteroid.direction = dir;
                float distance = GameDevHelper.RandomInRange(distanceBetween);

                newPos = new Vector3(x * distance, 0, y * distance);
                newAsteroid.transform.position = startPosition + newPos;
            }
        }
    }

    Vector2Int Clamp(Vector2Int vector)
    {
        float y = (float)vector.y / 2;
        int integerY = Mathf.FloorToInt(y);

        float x = (float)vector.x / 2;
        int integerX = Mathf.FloorToInt(x);
        return new Vector2Int(integerX, integerY);
    }
}
