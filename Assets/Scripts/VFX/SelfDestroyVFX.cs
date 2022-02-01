using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelfDestroyVFX : MonoBehaviour
{
    ParticleSystem fx => GetComponent<ParticleSystem>();

    public void Destroy(float customDelay)
    {
        StartCoroutine(SelfDestruction(customDelay));
    }

    IEnumerator SelfDestruction(float customDelay)
    {
        if (!fx)
            yield return new WaitForSeconds(customDelay);
        else
        {
            fx.Play();
            yield return new WaitForSeconds(fx.main.duration + fx.main.startLifetimeMultiplier);
        }
        
        Destroy(gameObject);
    }
}
