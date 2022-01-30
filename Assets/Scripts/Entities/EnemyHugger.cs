using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class EnemyHugger : Enemy
{
    [SerializeField] float chargeDuration = 0.4f;
    [SerializeField] float attackRate;
    float attackTimer;
    bool ready;
    bool inCharge;

    public override void Start()
    {
        base.Start();
        attackTimer = attackRate;
    }

    public override void Move()
    {
        if (ready)
            return;

        if (distanceToPlayer > stopDistance)
            Accelerate((transform.forward * direction).normalized * movingSpeed);
        else if (!ready)
            ready = true;
    }

    public override void Attacking()
    {
        attackTimer += Time.deltaTime;
        Vector3 dir = target.transform.position - transform.position;
        transform.rotation = Quaternion.LookRotation(dir.normalized);

        if (inCharge)
        {
            if (attackTimer > chargeDuration)
            {
                inCharge = false;
                direction *= -1;
                visual.DOComplete();
                visual.DOShakePosition(attackRate, 1, 90).SetEase(Ease.InElastic);
            }
        }
        else if (attackTimer >= attackRate && ready)
        {
            attackTimer = 0;
            rb.velocity = Vector3.zero;
            inCharge = true;
        }
    }

    private void FixedUpdate()
    {
        if (inCharge)
            rb.AddForce(Vector3.right * acceleration * direction, ForceMode.Acceleration);
        else if (ready)
            Decelerate();
    }
}
