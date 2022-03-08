using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using DG.Tweening;
using UnityEditor;
using UnityEngine;
using Cinemachine;

[System.Serializable]
public struct RandomSelection
{
    public int minValue;
    public int maxValue;
    public float probability;

    public RandomSelection(int minValue, int maxValue, float probability)
    {
        this.minValue = minValue;
        this.maxValue = maxValue;
        this.probability = probability;
    }

    public int GetValue() { return Random.Range(minValue, maxValue + 1); }
}

public class GameDevHelper : MonoBehaviour
{
    public static Vector2 RandomVector(Vector2 range, Vector2 basePos = default)
    {
        Vector2 random;
        random.x = Random.Range(-range.x, range.x);
        random.y = Random.Range(-range.y, range.y);
        return basePos + random;
    }

    public static int GetRandomValue(params RandomSelection[] selections)
    {
        float rand = Random.value;
        float currentProb = 0;
        foreach (var selection in selections)
        {
            currentProb += selection.probability;
            if (rand <= currentProb)
                return selection.GetValue();
        }

        //will happen if the input's probabilities sums to less than 1
        //throw error here if that's appropriate
        MonoBehaviour.print("wtf");
        return -1;
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
