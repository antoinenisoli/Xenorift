using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class PlayerController : Entity
{
    [Header(nameof(PlayerController))]
    [SerializeField] float shootingSpeed = 10f;
    [SerializeField] Transform shipPivot;
    [SerializeField] PlayerShooting shooting;
    Vector3 inputs;
    Vector3 vel;
    bool isShooting;

    [Header("Rotation")]
    [SerializeField] Vector3 shipRotationLimits;
    [SerializeField] float rotateSpeed = 10f;

    [Header("Hit")]
    [SerializeField] protected float hitDuration = 0.5f;
    protected float hitTimer;

    Vector3 futurePos => rb.velocity * GetSpeed() * Time.deltaTime;

    public override void DoAwake()
    {
        base.DoAwake();
        Hit();
    }

    public override void DoStart()
    {
        base.DoStart();
        shooting.Init();
        shooting.Update(false);
    }

    void GetInputs()
    {
        float xInput = Input.GetAxisRaw("Horizontal");
        float yInput = Input.GetAxisRaw("Vertical");
        inputs = new Vector3(xInput, 0, yInput).normalized;
    }

    protected void RecoverHit()
    {
        hitTimer += Time.deltaTime;
        if (hitTimer > hitDuration)
            hit = false;
    }

    IEnumerator HitFlash()
    {
        while (hit)
        {
            yield return new WaitForSeconds(0.05f);
            visual.gameObject.SetActive(!visual.gameObject.activeSelf);
        }

        visual.gameObject.SetActive(true);
    }

    void Hit()
    {
        hitTimer = 0;
        hit = true;
        EventManager.Instance.onPlayerDamaged.Invoke();
        StartCoroutine(HitFlash());
    }

    public override void TakeDamages(int value)
    {
        if (!hit)
        {
            Health.CurrentHealth -= value;
            hit = true;
            Death();
        }
    }

    public override void Death()
    {
        Feedbacks.ScreenShake(0.3f, 6, 45);
        Feedbacks.FreezeFrame(0.3f, 1.3f);
        EventManager.Instance.onPlayerDeath.Invoke();
        base.Death();
    }

    void RotateShip()
    {
        Vector3 shipRotation = new Vector3();
        shipRotation.z = inputs.z * 90;
        shipRotation.x = inputs.x * 90;
        shipRotation = GameDevHelper.ClampVector3(shipRotation, shipRotationLimits);
        Quaternion rot = Quaternion.Euler(shipRotation);
        shipPivot.localRotation = Quaternion.Slerp(shipPivot.localRotation, rot, rotateSpeed * Time.deltaTime);
    }

    void Move()
    {
        if (inputs.sqrMagnitude <= 0)
            Decelerate();
        else
        {
            vel = inputs * GetSpeed();
            vel.y = rb.velocity.y;
            Accelerate(vel);
        }
    }

    void ManageShooting()
    {
        isShooting = Input.GetButton("Shoot");
        if (isShooting)
            shooting.Update(true);
    }

    float GetSpeed()
    {
        if (isShooting)
            return shootingSpeed;
        else
            return movingSpeed;
    }

    void ClampPosition()
    {
        if (!gameBounds.Contains(transform.position))
            transform.position = GameDevHelper.ClampVector3(transform.position, gameBounds.size/2);
    }

    void Flip()
    {
        shooting.Update(false);
        EventManager.Instance.onPlayerFlip.Invoke();
        BarrelRoll();
        direction *= -1;
    }

    void BarrelRoll()
    {
        transform.DOComplete();
        float duration = 0.7f;
        Sequence barelRoll = DOTween.Sequence();
        transform.rotation = Quaternion.Euler(Vector3.up * 90);
        barelRoll.Append(transform.DORotate(new Vector3(0, 90, -180), duration / 2));
        barelRoll.Join(transform.DORotate(new Vector3(0, 90, -360), duration / 2));
        barelRoll.SetEase(Ease.Linear);
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        RecoverHit();
        GetInputs();
        RotateShip();
        ManageShooting();

        if (Input.GetButtonDown("FlipShip"))
            Flip();
    }

    public override void DoFixedUpdate()
    {
        base.DoFixedUpdate();
        Move();
        ClampPosition();
    }
}
