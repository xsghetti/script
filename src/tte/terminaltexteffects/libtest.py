import terminaltexteffects as tte

for step in tte.easing.ease_over_sequence(
    easing_func=tte.easing.in_out_bounce,
    sequence=list(range(10)),
):
    print(step.added, step.removed, step.total)
