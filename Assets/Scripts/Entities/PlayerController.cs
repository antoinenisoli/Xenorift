using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class PlayerController : Entity
{
    [Header(nameof(PlayerController))]
    [SerializeField] float shootingSpeed = 10f;
    [SerializeField] PlayerShooting shooting;
    Vector3 inputs;
    Vector3 vel;
    bool isShooting;

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
        EventManager.Instance.onPlayerDeath.Invoke();
        base.Death();
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
        {
            transform.position = GameDevHelper.ClampVector3(transform.position, gameBounds.size/2);
            //rb.velocity = Vector3.zero;
        }
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        RecoverHit();
        GetInputs();
        ManageShooting();

        if (Input.GetButtonDown("FlipShip"))
        {
            shooting.Update(false);
            EventManager.Instance.onPlayerFlip.Invoke();
            direction *= -1;
        }
    }

    public override void DoFixedUpdate()
    {
        base.DoFixedUpdate();
        Move();
        ClampPosition();
    }
}
