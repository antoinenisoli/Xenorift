using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class AlertSequence : MonoBehaviour
{
    [SerializeField] Transform bigText;
    [SerializeField] float FadeTime, duration = 4f;
    [SerializeField] MeshRenderer[] textRenderers;

    private void Start()
    {
        //EventManager.Instance.onNewWave.AddListener(LaunchSequence);
        LaunchSequence(duration);
    }

    void LaunchSequence(float duration)
    {
        foreach (var item in textRenderers)
            StartCoroutine(Fade(item, 1));

        if (bigText)
        {
            Vector3 baseScale = transform.localScale;
            Sequence sequence = DOTween.Sequence();
            sequence.Append(bigText.transform.DOScale(baseScale * 1.3f, 0.6f));
            sequence.SetLoops(-1, LoopType.Yoyo);
        }

        StartCoroutine(StartSequence(duration));
    }

    IEnumerator StartSequence(float duration)
    {
        yield return new WaitForSeconds(duration);
        StopAllCoroutines();
        End();
    }

    IEnumerator Fade(MeshRenderer myMesh, int alpha)
    {
        Color color = myMesh.material.color;
        color.a = alpha;

        for (float t = 0f; t < FadeTime; t += Time.deltaTime)
        {
            float normalizedTime = t / FadeTime;
            myMesh.material.color = Color.Lerp(myMesh.material.color, color, normalizedTime);
            yield return null;
        }

        myMesh.material.color = color;
        myMesh.gameObject.SetActive(false);
}

    public void End()
    {
        foreach (var item in textRenderers)
            StartCoroutine(Fade(item, 0));
    }
}
