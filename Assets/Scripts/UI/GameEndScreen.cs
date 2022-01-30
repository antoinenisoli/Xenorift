using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class GameEndScreen : MonoBehaviour
{
    [SerializeField] CanvasGroup screen;
    bool ready;

    private void Start()
    {
        screen.DOFade(0, 0);
        EventManager.Instance.onGameOver.AddListener(GameOverFade);
    }

    void GameOverFade()
    {
        screen.DOFade(1, 0.5f);
        ready = true;
    }

    private void Update()
    {
        if (Input.anyKeyDown && ready)
            SceneManager.LoadScene(1);
    }
}
