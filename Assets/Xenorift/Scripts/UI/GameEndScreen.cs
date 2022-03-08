using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class GameEndScreen : MonoBehaviour
{
    [SerializeField] CanvasGroup screen;
    [SerializeField] Text text;
    bool gameOver;
    bool gameCompleted;

    private void Start()
    {
        screen.DOFade(0, 0);
        EventManager.Instance.onAreaCompleted.AddListener(GameCompleteFade);
        EventManager.Instance.onGameOver.AddListener(GameOverFade);
    }

    void GameCompleteFade()
    {
        text.text = "Area cleared !";
        screen.DOFade(1, 0.5f);
        StartCoroutine(Wait(true));
    }

    void GameOverFade()
    {
        text.text = "Game over !";
        screen.DOFade(1, 0.5f);
        StartCoroutine(Wait(false));
    }

    IEnumerator Wait(bool b)
    {
        yield return new WaitForSeconds(2f);
        if (b)
            gameCompleted = true;
        else
            gameOver = true;
    }

    private void Update()
    {
        if (Input.GetButtonDown("Submit"))
        {
            if (gameOver)
                SceneManager.LoadScene(1);
            else if (gameCompleted)
                SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        }
    }
}
