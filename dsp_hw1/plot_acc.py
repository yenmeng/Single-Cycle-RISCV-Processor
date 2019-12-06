import sys
import numpy as np
import matplotlib.pyplot as plt

iter = np.concatenate(([1],np.arange(0,1010,10)[1:]),axis=0)
acc = [line.rstrip() for line in open('./process.txt')]
acc = [float(i) for i in acc]
plt.figure()
plt.plot(iter,acc)
plt.grid(True)
plt.xlabel("iterations")
plt.ylabel("accuracy")
plt.savefig('./acc.png')
plt.show()

