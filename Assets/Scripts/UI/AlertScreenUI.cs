using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.UI;

public class AlertScreenUI : MonoBehaviour
{
    [SerializeField] Image image;

    private void Start()
    {
        EventManager.Instance.onNewWave.AddListener(Animation);
        image.DOFade(0, 0);
    }

    public void Animation(float duration)
    {
        image.DOFade(0.3f, 0.4f).SetLoops(-1, LoopType.Yoyo);
        StartCoroutine(Loop(duration));
    }

    IEnumerator Loop(float duration)
    {
        yield return new WaitForSeconds(duration);
        image.DOKill();
        image.DOFade(0, 0);
    }
}
