import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import datasets
from sklearn import svm
import pandas 
import sklearn.cross_validation as skcv
import sklearn.linear_model as sklm
import math

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.api as sm


import numpy as np
import pandas
import matplotlib.pyplot as plt
import statsmodels.api as sm
from statsmodels.formula.api import ols


path = "/Users/gosi552/Documents/Papers/bma-solvation/BMA_Xval_baselineModels_Preds.csv"
df = pandas.read_csv(path)
#df = df[1:]

y = pandas.core.frame.DataFrame(df['Exp_Val']).as_matrix()
X = pandas.core.frame.DataFrame(df.iloc[0:,2:4]).as_matrix()

iterations = 500
solution = np.zeros(len(y), dtype = np.float32)
coef = list()
coef.append(0)
coef.append(0)

# prestige_model = ols("Exp_Val ~ imp2 + alc3", data=df).fit()
# fig, ax = plt.subplots(figsize=(12,8))
# fig = sm.graphics.influence_plot(prestige_model, ax=ax)

# plt.show()
# exit()

for x in range(0, iterations): 
  classType = list()
  scoreVal = list()

  folds = list(skcv.KFold(y.shape[0],n_folds = 2, shuffle = True))
  for i in range(len(folds)):
    train = folds[0][0]
    test = folds[0][1]

    learner = sklm.LinearRegression()
    lrn = learner.fit(X[train], y[train])
    coef[0] = coef[0] + lrn.coef_[0][0]
    coef[1] = coef[1] + lrn.coef_[0][1]

    for values in test:
      classT =  y[values]
      scoreV = float(learner.predict(X[values:values+1,:]))
      solution[values] = solution[values] + float((classT-scoreV)*(classT-scoreV))
      #solution[values] = solution[values] + scoreV

print (coef[0]/float(iterations),coef[1]/float(iterations))

newDict = dict()
for x in range(0,len(y)):
  value = math.sqrt(solution[x]/float(iterations))
  #value = solution[x]/float(iterations)
  name  = str(df['type'].iloc[x])
  imp2 = abs(abs(y[x:x+1]) - abs(X[x:x+1,0:1]))#/abs(y[x:x+1])
  alc3 = abs(abs(y[x:x+1]) - abs(X[x:x+1,1:2]))#/abs(y[x:x+1])

  print (name,",",'{0:.2f}'.format(float(value)),",",'{0:.2f}'.format(float(imp2)),",",'{0:.2f}'.format(float(alc3)))
  

# newDF = pandas.DataFrame.from_dict(newDict,orient='index')


# labels = ['Measured', 'BMA', 'imp-2','alc-3','Molecule']
# newDF.columns = labels
# #newDF.set_index('Molecule',drop=True,inplace=True)

# # set appropriate font and dpi
# sns.set(font_scale=1.2)
# sns.set_style({"savefig.dpi": 100})
# # plot it out
# ax = sns.heatmap(newDF, cmap=plt.cm.Blues, linewidths=.1)
# # set the x-axis labels on the top
# ax.xaxis.tick_top()
# # rotate the x-axis labels
# #plt.xticks(rotation=90)
# plt.yticks(rotation=360)
# # get figure (usually obtained via "fig,ax=plt.subplots()" with matplotlib)
# fig = ax.get_figure()
# # specify dimensions and save
# fig.set_size_inches(15, 20)
# fig.savefig("nba.png")


# g = sns.PairGrid(newDF,x_vars=newDF.columns[0:4], y_vars=['Molecule'])
# # Draw a dot plot using the stripplot function
# g.map(sns.stripplot, size=10, orient="h",
#       palette="Reds_r", edgecolor="gray")

# # Use the same x axis limits on all columns and add better labels
# g.set(xlim=(0, 1), xlabel="Error", ylabel="")

# for ax, title in zip(g.axes.flat, labels):

#     # Set a different title for each axes
#     ax.set(title=title)

#     # Make the grid horizontal instead of vertical
#     ax.xaxis.grid(False)
#     ax.yaxis.grid(True)

# sns.despine(left=True, bottom=True)
# sns.plt.show()
