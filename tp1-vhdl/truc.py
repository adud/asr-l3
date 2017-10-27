import itertools

prototype = """
    testx   <= '{}';
    testy   <= '{}';
    testcin <= '{}';
    wait for 1 ns;
"""

for tx,ty,tc in itertools.product([0,1],repeat=3):
    print(prototype.format(tx,ty,tc))

