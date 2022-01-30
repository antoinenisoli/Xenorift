using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class GetPrefabPreview : MonoBehaviour
{
    [SerializeField] GameObject prefab;
    [SerializeField] float maxLoadingTime = 75;
    [SerializeField] string path = "Assets/Sprites/Exports/";

    [ContextMenu("Export prefab preview")]
    public void CreateSpriteFromFile()
    {
        Texture2D prev = AssetPreview.GetAssetPreview(prefab);
        int counter = 0;
        while (!prev && counter < maxLoadingTime)
        {
            prev = AssetPreview.GetAssetPreview(prefab);
            counter++;
            System.Threading.Thread.Sleep(15);
        }

        if (prev)
        {
            string newPath = path + prefab.name + ".png";
            File.WriteAllBytes(newPath, prev.EncodeToPNG());
        }
        else
            Debug.LogError($"[{nameof(GetPrefabPreview)}] Failed to load preview of {prefab.name} after {counter} attempts.");

        AssetDatabase.Refresh();
    }
}
