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

    public static Vector2Int ToVector2Int(Vector2 vector)
    {
        return new Vector2Int(Mathf.RoundToInt(vector.x), Mathf.RoundToInt(vector.y));
    }

    public static void DrawIcon(GameObject gameObject, int idx)
    {
        var largeIcons = GetTextures("sv_label_", string.Empty, 0, 8);
        var icon = largeIcons[idx];
        var egu = typeof(EditorGUIUtility);
        var flags = BindingFlags.InvokeMethod | BindingFlags.Static | BindingFlags.NonPublic;
        var args = new object[] { gameObject, icon.image };
        var setIcon = egu.GetMethod("SetIconForObject", flags, null, new System.Type[] { typeof(UnityEngine.Object), typeof(Texture2D) }, null);
        setIcon.Invoke(null, args);
    }

    public static GUIContent[] GetTextures(string baseName, string postFix, int startIndex, int count)
    {
        GUIContent[] array = new GUIContent[count];
        for (int i = 0; i < count; i++)
        {
            array[i] = EditorGUIUtility.IconContent(baseName + (startIndex + i) + postFix);
        }

        return array;
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

    public static void DrawRect(Rect rect)
    {
        Gizmos.DrawLine(rect.min, new Vector3(rect.min.x, rect.position.y, rect.max.y));
        Gizmos.DrawLine(new Vector3(rect.min.x, rect.position.y, rect.max.y), rect.max);
        Gizmos.DrawLine(rect.max, new Vector3(rect.max.x, rect.position.y, rect.min.y));
        Gizmos.DrawLine(rect.min, new Vector3(rect.max.x, rect.position.y, rect.min.y));
    }
}
