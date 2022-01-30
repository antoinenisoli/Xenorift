using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmallSoundManager : MonoBehaviour
{
    static SmallSoundManager _instance;
    public static SmallSoundManager Instance => _instance;

    public List<SoundList> SoundLists;
    public AudioSource AudioOneShot;
    public GameObject Audio3D;

    private void Awake()
    {
        _instance = this;
    }

    public void PlaySound(TypeOfSound sound)
    {
        if (AudioOneShot == null)
            return;

        List<AudioClip> clips = GetClips(sound);

        if (clips.Count == 0)
            return;

        AudioOneShot.PlayOneShot(clips[Random.Range(0, clips.Count)]);
    }

    public void PlaySound(TypeOfSound sound, Vector3 position)
    {
        if (Audio3D == null)
            return;

        List<AudioClip> clips = GetClips(sound);

        if (clips.Count == 0)
            return;

        AudioClip clip = clips[Random.Range(0, clips.Count)];
        GameObject instance = Instantiate(Audio3D, position, Quaternion.identity);

        AudioSource source = instance.GetComponent<AudioSource>();

        source.clip = clip;
        source.Play();
        Destroy(instance, clip.length);
    }

    private List<AudioClip> GetClips(TypeOfSound sound)
    {
        foreach (SoundList list in SoundLists)
        {
            if (list.SoundType == sound)
                return list.Clips;
        }

        return new List<AudioClip>();
    }
}

[System.Serializable]
public class SoundList
{
    public TypeOfSound SoundType = TypeOfSound.None;
    public List<AudioClip> Clips = new List<AudioClip>();
}

public enum TypeOfSound
{
    MenuClick,
    MenuMove,
    None
}