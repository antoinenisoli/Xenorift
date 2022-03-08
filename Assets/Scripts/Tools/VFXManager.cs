using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VFXManager : MonoBehaviour
{
    [System.Serializable]
    struct VFX
    {
        public GameObject prefab;
        public string name;

        public VFX(GameObject prefab, string name)
        {
            this.prefab = prefab;
            this.name = name;
        }
    }

    public static VFXManager Instance;
    [SerializeField] GameObject[] prefabs;
    [SerializeField] List<VFX> vfx = new List<VFX>();
    Dictionary<string, GameObject> allVFX = new Dictionary<string, GameObject>();

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
    }

    private void Start()
    {
        foreach (var item in vfx) //store the prefabs in the list according to their names
            if (!allVFX.ContainsKey(item.name))
                allVFX.Add(item.name, item.prefab);
    }

    [ContextMenu(nameof(Convert))]
    public void Convert()
    {
        foreach (var item in prefabs)
        {
            vfx.Add(new VFX(item, item.name));
        }
    }

    /// <summary>
    /// Spawn and play a stored VFX prefab at a given position by calling it by his name.
    /// </summary>
    public GameObject PlayVFX(string name = "ManaBurst", Vector3 pos = new Vector3(), bool destroy = true, Transform parent = null)
    {
        if (allVFX.TryGetValue(name, out GameObject prefab))
        {
            GameObject newVFX = Instantiate(prefab, pos, Quaternion.identity, parent);
            if (destroy)
            {
                SelfDestroyVFX selfDestroy = newVFX.GetComponentInChildren<SelfDestroyVFX>();
                if (!selfDestroy)
                    selfDestroy = newVFX.AddComponent<SelfDestroyVFX>();

                selfDestroy.Destroy(1.5f);
            }

            return newVFX;
        }
        else
        {
            print("No vfx found with this name : " + name);
            return null;
        }
    }
}
