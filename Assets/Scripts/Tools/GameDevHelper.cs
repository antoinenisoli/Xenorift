using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using DG.Tweening;
using UnityEditor;
using UnityEngine;
using Cinemachine;

public class GameDevHelper : MonoBehaviour
{
    public static Vector2 RandomVector(Vector2 range, Vector2 basePos = default)
    {
        Vector2 random;
        random.x = Random.Range(-range.x, range.x);
        random.y = Random.Range(-range.y, range.y);
        return basePos + random;
    }

    public static float RandomInRange(Vector2 range)
    {
        return Random.Range(range.x, range.y + 1);
    }

    public static Vector3 ClampVector3(Vector3 vector, Vector3 range)
    {
        Vector3 clampedPos = vector;
        clampedPos.x = Mathf.Clamp(clampedPos.x, -range.x, range.x);
        clampedPos.y = Mathf.Clamp(clampedPos.y, -range.y, range.y);
        clampedPos.z = Mathf.Clamp(clampedPos.z, -range.z, range.z);
        return clampedPos;
    }

    public static Vector2Int ToVector2Int(Vector2 vector)
    {
        return new Vector2Int(Mathf.RoundToInt(vector.x), Mathf.RoundToInt(vector.y));
    }

    public static Color RandomColor()
    {
        Color randomColor = new Color(
          Random.Range(0f, 1f),
          Random.Range(0f, 1f),
          Random.Range(0f, 1f)
            );

        return randomColor;
    }

    public static T RandomEnum<T>()
    {
        System.Array array = System.Enum.GetValues(typeof(T));
        T randomBiome = (T)array.GetValue(Random.Range(0, array.Length));
        return randomBiome;
    }
}
