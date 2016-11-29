import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import datasets
from sklearn import svm
import pandas 
import sklearn.cross_validation as skcv
import sklearn.linear_model as sklm
import math
from sklearn import linear_model

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.api as sm


import numpy as np
import pandas
import matplotlib.pyplot as plt
import statsmodels.api as sm
import sklearn.linear_model as lm
from statsmodels.formula.api import ols
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import Ridge
import statsmodels.formula.api as smf

def forward_selected(data, response):
    """Linear model designed by forward selection.

    Parameters:
    -----------
    data : pandas DataFrame with all possible predictors and response

    response: string, name of response column in data

    Returns:
    --------
    model: an "optimal" fitted statsmodels linear model
           with an intercept
           selected by forward selection
           evaluated by adjusted R-squared
    """
    remaining = set(data.columns)
    remaining.remove(response)
    selected = []
    current_score, best_new_score = 0.0, 0.0
    while remaining and current_score == best_new_score:
        scores_with_candidates = []
        for candidate in remaining:
            formula = "{} ~ {} + 1".format(response,
                                           ' + '.join(selected + [candidate]))
            score = smf.ols(formula, data).fit().rsquared_adj
            scores_with_candidates.append((score, candidate))
        scores_with_candidates.sort()
        best_new_score, best_candidate = scores_with_candidates.pop()
        if current_score < best_new_score:
            remaining.remove(best_candidate)
            selected.append(best_candidate)
            current_score = best_new_score
    formula = "{} ~ {} + 1".format(response,
                                   ' + '.join(selected))
    model = smf.ols(formula, data).fit()
    #print(model.summary())
    return model



path = "data.csv"
df = pandas.read_csv(path)

y = pandas.core.frame.DataFrame(df['Exp_Val']).as_matrix()
X = pandas.core.frame.DataFrame(df.iloc[0:,2:]).as_matrix()

iterations = 5
solution = np.zeros(len(y), dtype = np.float32)
coef = 0
coef1 = 0
coef2 = 0
coef3 = 0


for x in range(0, iterations): 
  folds = list(skcv.KFold(y.shape[0],n_folds = 2, shuffle = True))
  for i in range(len(folds)):
    train = folds[i][0]
    test = folds[i][1]


    clf = linear_model.Lasso(alpha=0.1)
    clf1 = RandomForestRegressor(n_estimators=10, max_depth=None,min_samples_split=2, random_state=0)
    clf2 = Ridge(alpha=1.0)
    df2 = df.as_matrix()[train]
    df2 = pd.DataFrame(df2[:,1:],columns=df.columns[1:])
    clf3 = forward_selected(df.iloc()[:,1:],"Exp_Val")

    clf.fit(X[train], y[train])
    clf1.fit(X[train], y[train].ravel())
    clf2.fit(X[train], y[train])

    if x == 0:
      coef = abs(clf.coef_)
      coef1 = abs(clf1.feature_importances_)
      coef2 = abs(clf2.coef_)
      coef3 = abs(clf3.params)
    else:
      coef = coef + abs(clf.coef_)
      coef1 = coef1 + abs(clf1.feature_importances_)
      coef2 = coef2 + abs(clf2.coef_)
      coef3 = coef3 + abs(clf3.params)
    
coef2 = coef2[0]
coef3 = coef3[1:]
coef3 = coef3.values

max = coef.sum()
max1 = coef1.sum()
max2 = coef2.sum()
max3 = coef3.sum()
coef = (coef/max)*100.0
coef1 = (coef1/max1)*100.0
coef2 = (coef2/max2)*100.0
coef3 = (coef3/max3)*100.0

# print(coef)
# print(coef1)
# print(coef2)
# print(coef3)

# print(coef.sum())
# print(coef1.sum())
# print(coef2.sum())
# print(coef3.sum())
# exit()

max = 1.0
print("Lasso")
for name in range(2,len(df.columns[2:])):
  if (coef[name]/float(iterations) > max):
    print(df.columns[name],coef[name]/float(iterations),True)
  # else:
  #   print(df.columns[name],coef[name]/float(iterations),False)

print("Random Forest")
for name in range(2,len(df.columns[2:])):
  if (coef1[name]/float(iterations) > max):
    print(df.columns[name],coef1[name]/float(iterations),True)
  # else:
  #   print(df.columns[name],coef1[name]/float(iterations),False)

print("Ridge")
for name in range(2,len(df.columns[2:])):
  if (coef2[name]/float(iterations) > max):
    print(df.columns[name],coef2[name]/float(iterations),True)
  # else:
  #   print(df.columns[name],coef2[name]/float(iterations),False)

print("Stepwise")
print(clf3.summary())
# for name in df.columns[2:]:
#   if name in coef3.columns:
#     if (coef3[name]/float(iterations) > max):
#       print(df.columns[name],coef3[name]/float(iterations),True)
  # else:
  #   print(df.columns[name],coef3[name]/float(iterations),False)






