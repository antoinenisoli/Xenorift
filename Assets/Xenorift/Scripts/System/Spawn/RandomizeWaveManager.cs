using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class RandomizeWaveManager : WaveManager
{
    public override void Start()
    {
        base.Start();
        waves = RandomWaves();
    }

    public Wave[] RandomWaves()
    {
        return null;
    }
}
