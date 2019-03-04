import pandas as pd
import io
import ast
import sys

path = sys.argv[1]
index = int(sys.argv[2])-2
delta = float(sys.argv[3])

with open(path) as f:
    content = f.read()

arr = content.split('\n')
head = arr[0]
arr = arr[1:]
arr = arr[:-1]

sb = io.StringIO()
print(head, file=sb)
for i, a in enumerate(arr):
    if i >= index:
        t = (a.split(',')[0].strip('['))
        a = a.replace(t, str(round(float(t)-delta, 6)))
    print(a, file=sb)

with open('%s.new' % path, 'w') as f:
    f.write(sb.getvalue())
