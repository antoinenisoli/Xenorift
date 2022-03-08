using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ButtonExtension : MonoBehaviour,IPointerEnterHandler,IPointerExitHandler 
{
    Image _image;

    [SerializeField] Sprite _idleButton;
    [SerializeField] Sprite _hoverButton;

    private void Awake()
    {
        _image = GetComponent<Image>();
        _image.sprite = _idleButton;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        _image.sprite = _hoverButton;

        SmallSoundManager.Instance.PlaySound(TypeOfSound.MenuMove);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        _image.sprite = _idleButton;
    }
}
