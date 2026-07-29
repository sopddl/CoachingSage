import pathlib
from generate_reliquat import FEMALE, FEMALE_OPEN_KNEES, GYM
from pilot_flux import replicate_run, b64

OUT = pathlib.Path('reliquat_final')

JOBS = [
    dict(
        slug='dead-bug',
        ctrl='dead-bug_v2_control.png',
        template=GYM,
        pose=('lying flat on his back on the floor doing a dead bug core exercise, '
              'both arms extended straight up and both knees bent at ninety degrees in the air, '
              'his right arm reaching down and back toward the floor above his head while at the same time '
              'his left leg extends straight down toward the floor, controlateral movement, '
              'his left arm and his right knee staying bent and raised in the starting position, '
              'core exercise performed flat on the ground, not on a bench, no equipment'),
    ),
    dict(
        slug='face-pull',
        ctrl='face-pull_v2_control.png',
        template=GYM,
        pose=('performing a face pull exercise at a cable machine, pulling a rope attachment toward his face at eye level, '
              'both elbows bent and pulled high and wide out to the sides at shoulder height, '
              'both hands separated on either side of his head near eye level, hands not touching each other, '
              'hands not joined together, hands not behind his head, shoulder blades squeezed together, '
              'facing the cable machine'),
    ),
    dict(
        slug='kurmasana',
        ctrl='kurmasana_v2_control.png',
        template=FEMALE_OPEN_KNEES,
        pose=('kurmasana tortoise yoga pose, lying face down on the mat with straight legs spread wide open to both sides, '
              'both arms threaded underneath her thighs from the inside, her shoulders and upper arms hidden beneath her legs, '
              'only her forearms and hands visible emerging on the outside of her calves and resting flat on the mat beyond her feet, '
              'palms facing down, chest and forehead resting low on the mat between her legs, '
              'bird\'s eye top-down view matching the reference image exactly'),
    ),
    dict(
        slug='karnapidasana',
        ctrl='karnapidasana_v2_control.png',
        template=FEMALE,
        pose=('karnapidasana yoga ear pressure pose, sitting curled forward with hips lifted high, '
              'knees bent deeply and brought down beside her head near her ears, '
              'feet resting on the mat behind her head, her hands reaching forward and clasping around her feet, '
              'forearms resting along her shins on the mat, side view'),
    ),
]

if __name__ == '__main__':
    for job in JOBS:
        ctrl = OUT / job['ctrl']
        dest = OUT / f"{job['slug']}.png"
        prompt = job['template'].format(pose=job['pose'])
        ok = replicate_run('black-forest-labs/flux-canny-pro',
            {'prompt': prompt, 'control_image': b64(ctrl),
             'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
             'safety_tolerance': 2}, dest)
        print(job['slug'], ok)
