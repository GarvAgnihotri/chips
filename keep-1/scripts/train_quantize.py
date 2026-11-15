"""Train the Keep-1 model, shrink the weights to 3 bits, and print the accuracy.
Needs: numpy, scikit-learn.   Run:  python scripts/train_quantize.py
"""
import numpy as np
from sklearn.datasets import load_digits
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

d = load_digits()
X = (d.data >= 8).astype(int)                 # pixels: 0..16 -> 0 or 1
y = d.target
Xtr, Xte, ytr, yte = train_test_split(
    X, y, test_size=0.3, random_state=1, stratify=y)

m = LogisticRegression(C=0.05, max_iter=5000).fit(Xtr, ytr)
W, b = m.coef_, m.intercept_
s  = 3 / np.abs(W).max()                      # 3-bit signed: -4..3
Wq = np.clip(np.round(W * s), -4, 3).astype(int)
bq = np.clip(np.round(b * s), -32, 31).astype(int)

print("float model accuracy:", round(m.score(Xte, yte), 4))
pred = (Xte @ Wq.T + bq).argmax(1)
print("3-bit model accuracy:", round((pred == yte).mean(), 4))
print("correct:", int((pred == yte).sum()), "of", len(yte))
