using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class EnemyHugger : Enemy
{
    [Header(nameof(EnemyHugger))]
    [SerializeField] float chargeDuration = 0.4f;
    [SerializeField] float attackRate;
    [SerializeField] int damage = 1;
    float attackTimer;
    bool ready;
    bool inCharge;

    public override void DoStart()
    {
        base.DoStart();
        attackTimer = attackRate;
    }

    private void OnTriggerEnter(Collider other)
    {
        Entity entity = other.GetComponent<Entity>();
        if (entity && entity.team != team)
        {
            VFXManager.Instance.PlayVFX("Damaged", entity.ClosestPointOnCollider(transform.position));
            entity.TakeDamages(damage);
        }
    }

    public override void Move()
    {
        if (ready)
            return;

        if (DistanceToPlayer() > stopDistance)
            Accelerate((transform.forward * direction).normalized * movingSpeed);
        else if (!ready)
            ready = true;
    }

    void Charge()
    {
        attackTimer = 0;
        rb.velocity = Vector3.zero;
        inCharge = true;
        visual.DOComplete();
        transform.DOKill();
        transform.DORotateQuaternion(Quaternion.LookRotation(Vector3.right * direction), 0.25f);
        SoundManager.Instance.PlayAudio("HuggerAttack");
    }

    public override void Attacking()
    {
        attackTimer += Time.deltaTime;
        if (inCharge)
        {
            if (attackTimer > chargeDuration)
            {
                inCharge = false;
                direction *= -1;
                visual.DOComplete();
                visual.DOShakePosition(attackRate, 1, 90).SetEase(Ease.InBack).SetInverted();
            }
        }
        else if (attackTimer >= attackRate && ready)
            Charge();
    }

    public override void DoUpdate()
    {
        base.DoUpdate();
        if (ready && !inCharge)
            Decelerate();
    }

    public override void DoFixedUpdate()
    {
        base.DoFixedUpdate();
        if (inCharge)
            rb.AddForce(Vector3.right * acceleration * direction, ForceMode.Acceleration);
    }
}
