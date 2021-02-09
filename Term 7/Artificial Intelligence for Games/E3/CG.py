import random

# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

# INPUT:

    # action_id: the unique ID of this spell or recipe
    # action_type: in the first league: BREW; later: CAST, OPPONENT_CAST, LEARN, BREW
    # delta_0: tier-0 ingredient change
    # delta_1: tier-1 ingredient change
    # delta_2: tier-2 ingredient change
    # delta_3: tier-3 ingredient change
    # price: the price in rupees if this is a potion
    # tome_index: in the first two leagues: always 0; later: the index in the tome if this is a tome spell, equal to the read-ahead tax; For brews, this is the value of the current urgency bonus
    # tax_count: in the first two leagues: always 0; later: the amount of taxed tier-0 ingredients you gain from learning this spell; For brews, this is how many times you can still gain an urgency bonus
    # castable: in the first league: always 0; later: 1 if this is a castable player spell
    # repeatable: for the first two leagues: always 0; later: 1 if this is a repeatable player spell

# OUTPUT:
    # Write an action using print
    # To debug: print("Debug messages...", file=sys.stderr, flush=True)
    # in the first league: BREW <id> | WAIT; later: BREW <id> | CAST <id> [<times>] | LEARN <id> | REST | WAIT




K = 300

TURNS_FOR_LEARNING = 7
MAX_TURNS_FOR_LEARNING = 10-TURNS_FOR_LEARNING

SEARCH_DIST = 1

def make_action(action):
    if action[1] == 'CAST' and not action[2]:
        print('REST')
    else:
        print(action[1], action[0])

def add_deltas(d1,d2):
    return [d1[i]+d2[i] for i in range(4)]

def ingredients_bonus(d):
    if min(0,min(d)) < 0:
        return 0
    return sum(d[1:])

def sort_options(l):
    l.sort(key=lambda e: [min(0,min(e[0][1])), e[1][1][2] + ingredients_bonus(e[0][1])], reverse=True)

while True:

    # --------------- input phaze ---------------------

    BREW_OPTIONS = [] # (id, 'BREW', reward, (dletas))
    CAST_OPTIONS = [] # (id, 'CAST', castable, (deltas))
    LEARN_OPTIONS = [[] for _ in range(42)]

    action_count = int(input())
    for i in range(action_count):
        input_data = input().split()
        action_id, action_type = int(input_data[0]), input_data[1]
        deltas= list(map(int, input_data[2:6]))
        price, tome_index, tax_count, castable, repeatable = map(int, input_data[6:])

        if action_type == 'BREW':
            BREW_OPTIONS.append((action_id, action_type, price, deltas))
        elif action_type == 'CAST':
            CAST_OPTIONS.append((action_id, action_type, castable, deltas))
        elif action_type == 'LEARN':
            LEARN_OPTIONS[tome_index] = (action_id, action_type, tax_count, deltas)

    MY_INV = [int(j) for j in input().split()]
    OP_INV = [int(j) for j in input().split()]


    # ---------------- game phaze ---------------------

    '''
    ACTION_OPTIONS_WITH_DELTA = [[
        [[deltas_after_spels],[deltas_after_all_actions]
        [[spels],brew], - CAST_OPTION*, BREW_OPTION
    ]]
    '''

    if TURNS_FOR_LEARNING > 0:
        make_action(LEARN_OPTIONS[0])
        TURNS_FOR_LEARNING -= 1
        continue
    elif MAX_TURNS_FOR_LEARNING > 0 and LEARN_OPTIONS[0][2] > 0:
        MAX_TURNS_FOR_LEARNING -= 1
        make_action(LEARN_OPTIONS[0])
        continue

    ACTION_OPTIONS_WITH_DELTA = [[[MY_INV[:4],add_deltas(MY_INV, option[3])], [[],option]] for option in BREW_OPTIONS]
    sort_options(ACTION_OPTIONS_WITH_DELTA)

    t0 = time.time()

    while min(ACTION_OPTIONS_WITH_DELTA[0][0][1]) < 0:
        if time.time() - t0 > 0.042:
            print('Time limit', file=sys.stderr, flush=True)
            break

        NEXT_ACTION_OPTIONS_WITH_DELTA = []
        for option in ACTION_OPTIONS_WITH_DELTA:
            deltas_after_spels,deltas_after_all_actions = option[0]
            spels, brew = option[1]
            for cast_option in CAST_OPTIONS:
                deltas_after_cast = add_deltas(deltas_after_spels,cast_option[3])
                if min(deltas_after_cast) >= 0:
                    deltas_after_brew = add_deltas(deltas_after_cast,brew[3])
                    NEXT_ACTION_OPTIONS_WITH_DELTA.append([[deltas_after_cast,deltas_after_brew],[spels+[cast_option],brew]])

        sort_options(NEXT_ACTION_OPTIONS_WITH_DELTA)
        if len(NEXT_ACTION_OPTIONS_WITH_DELTA) > K:
            NEXT_ACTION_OPTIONS_WITH_DELTA = NEXT_ACTION_OPTIONS_WITH_DELTA[:K]
        
        ACTION_OPTIONS_WITH_DELTA = NEXT_ACTION_OPTIONS_WITH_DELTA
        
    for i in range(SEARCH_DIST):
        if time.time() - t0 > 0.025:
            print('Time limit', file=sys.stderr, flush=True)
            break

        NEXT_ACTION_OPTIONS_WITH_DELTA = []
        for option in ACTION_OPTIONS_WITH_DELTA:
            deltas_after_spels,deltas_after_all_actions = option[0]
            spels, brew = option[1]
            for cast_option in CAST_OPTIONS:
                deltas_after_cast = add_deltas(deltas_after_spels,cast_option[3])
                if min(deltas_after_cast) >= 0:
                    deltas_after_brew = add_deltas(deltas_after_cast,brew[3])
                    NEXT_ACTION_OPTIONS_WITH_DELTA.append([[deltas_after_cast,deltas_after_brew],[spels+[cast_option],brew]])

        sort_options(NEXT_ACTION_OPTIONS_WITH_DELTA)
        if len(NEXT_ACTION_OPTIONS_WITH_DELTA) > K:
            NEXT_ACTION_OPTIONS_WITH_DELTA = NEXT_ACTION_OPTIONS_WITH_DELTA[:K]    

        ACTION_OPTIONS_WITH_DELTA = NEXT_ACTION_OPTIONS_WITH_DELTA

    

    # print(ACTION_OPTIONS_WITH_DELTA, file=sys.stderr, flush=True)
    if len(ACTION_OPTIONS_WITH_DELTA[0][1][0]) > 0:
        make_action(ACTION_OPTIONS_WITH_DELTA[0][1][0][0])
    else:
        make_action(ACTION_OPTIONS_WITH_DELTA[0][1][1])