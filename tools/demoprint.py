while True:
    i = int(input(), 16)
    length = i % 256
    i //= 256
    keys = []
    for weight, name in [
        (1, 'A_BUTTON'),
        (2, 'B_BUTTON'),
        (4, 'SELECT'),
        (8, 'START'),
        (16, 'D_RIGHT'),
        (32, 'D_LEFT'),
        (64, 'D_UP'),
        (128, 'D_DOWN')]:
        if i & weight: keys.append(name)

    keystring = ' + '.join(keys)
    if not keystring: keystring = '0'
    keystring += ','
    print('\tdb ' + keystring.ljust(19) + str(length).rjust(2))
