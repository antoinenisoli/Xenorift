using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    [SerializeField] GameObject _howToPlayPage;
    [SerializeField] GameObject _creditPage;
    [SerializeField] GameObject _returnText;

    [Space]
    [SerializeField] GameObject _continueButton;

    [Header("Values")]
    [SerializeField] float _timeShowButton = 2;
    [SerializeField] KeyCode _continueKey = KeyCode.Return;
    [SerializeField] KeyCode _returnKey = KeyCode.Escape;

    private void Start()
    {
        Menu();
    }

    private void Update()
    {
        if (Input.GetKeyDown(_returnKey))
            Menu();
    }


    void Menu()
    {
        StopAllCoroutines();
        if (_howToPlayPage)
            _howToPlayPage.SetActive(false);
        if (_creditPage)
            _creditPage.SetActive(false);

        _continueButton.SetActive(false);
        _returnText.SetActive(false);
    }

    public void Play()
    {
        if (_creditPage)
        {
            ClickSound();
            _creditPage?.SetActive(false);
        }
        
        if(_howToPlayPage != null)
        {
            _returnText.SetActive(true);
            StartCoroutine(HowToPlay());
        }
        else
            SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    public void Credits()
    {
        if (_creditPage)
        {
            ClickSound();
            _returnText.SetActive(true);
            _creditPage?.SetActive(true);
            if (_howToPlayPage)
                _howToPlayPage?.SetActive(false);
        }
    }

    public void Quit()
    {
        ClickSound();
        #if UNITY_STANDALONE
        Application.Quit();
        #endif
    }

    void ClickSound() => SmallSoundManager.Instance.PlaySound(TypeOfSound.MenuClick);

    IEnumerator HowToPlay()
    {
        _howToPlayPage?.SetActive(true);
        yield return new WaitForSeconds(_timeShowButton);
        _continueButton.SetActive(true);

        bool keyPressed= false;

        while(!keyPressed)
        {
            if(Input.GetKeyDown(_continueKey))
                keyPressed = true;
            yield return null;
        }

        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
