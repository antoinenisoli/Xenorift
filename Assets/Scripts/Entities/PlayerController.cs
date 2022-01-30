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
    bool hit;

    Vector3 futurePos => rb.velocity * GetSpeed() * Time.deltaTime;

    public override void DoStart()
    {
        base.DoStart();
        shooting.Init();
        Hit();
    }

    void GetInputs()
    {
        float xInput = Input.GetAxis("Horizontal");
        float yInput = Input.GetAxis("Vertical");
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
            Accelerate(vel);
    }

    void ManageShooting()
    {
        isShooting = Input.GetButton("Shoot");
        shooting.Update(isShooting);
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
        vel = inputs * GetSpeed();
        vel.y = rb.velocity.y;

        ManageShooting();
        if (Input.GetButtonDown("FlipShip"))
        {
            EventManager.Instance.onPlayerFlip.Invoke();
            direction *= -1;
        }
    }

    void FixedUpdate()
    {
        Move();
        ClampPosition();
    }
}