using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] float followSpeed = 10f;
    Vector3 posOffset;

    private void Awake()
    {
        posOffset = transform.position - target.position;
    }

    private void LateUpdate()
    {
        if (target)
        {
            Vector3 targetPos = target.position + posOffset;
            targetPos.y = transform.position.y;
            transform.position = Vector3.Lerp(transform.position, targetPos, followSpeed * Time.deltaTime);
        }
    }
}
