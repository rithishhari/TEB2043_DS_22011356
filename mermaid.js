stateDiagram-v2
    direction LR
    
    [*] --> DAY : Transition condition:\nStartup

    DAY: State: DAY (State 0)
    DAY: Entry action:
    DAY: • Daylight is detected (photoresistor read)
    DAY: • Streetlight LED remains OFF.

    NIGHT_DIM: State: NIGHT_DIM (State 1)
    NIGHT_DIM: Entry action:
    NIGHT_DIM: • Darkness is detected
    NIGHT_DIM: • Streetlight LED at dim brightness (PWM output).

    NIGHT_BRIGHT: State: NIGHT_BRIGHT (State 2)
    NIGHT_BRIGHT: Entry action:
    NIGHT_BRIGHT: • Motion is detected
    NIGHT_BRIGHT: • Streetlight LED at max brightness.

    DAY --> NIGHT_DIM : Transition condition:\nDarkness (photoresistor ≥ 400)
    NIGHT_DIM --> DAY : Transition condition:\nDaylight (photoresistor < 400)
    
    NIGHT_DIM --> NIGHT_BRIGHT : Transition condition:\nMotion detected (by PIR sensor)
    NIGHT_BRIGHT --> NIGHT_DIM : Transition condition:\nNo motion detected (by PIR sensor)
