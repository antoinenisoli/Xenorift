using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AngleToleranceGizmo
{
    public static void Show(Transform transform, Vector3 basePosition, float minAngle, float distance, Color color, float rotationOffset = 0f)
    {
        Matrix4x4 oldGizmosMatrix = Gizmos.matrix;
        Matrix4x4 cubeTransform = Matrix4x4.TRS(transform.position, transform.rotation * Quaternion.Euler(Vector3.up * rotationOffset), transform.lossyScale);
        Gizmos.matrix *= cubeTransform;

        Vector3 pos = basePosition - transform.position;
        float angle = 360 * (Mathf.PI / 180);
        Vector3 newPos1 = new Vector3(Mathf.Cos(angle * (1 - minAngle / 2)), 0, Mathf.Sin(angle * (1 - minAngle / 2)));
        Vector3 newPos2 = new Vector3(Mathf.Cos(angle * minAngle / 2), 0, Mathf.Sin(angle * minAngle / 2));
        Gizmos.color = color;
        Gizmos.DrawLine(pos, pos + newPos1 * distance);
        Gizmos.DrawLine(pos, pos + newPos2 * distance);
        Gizmos.matrix = oldGizmosMatrix;
    }
}
