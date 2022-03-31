import pandas as pd
import tkinter as tk
import numpy as np
from tkinter import filedialog

#root = tk.Tk()
#root.withdraw()

#file_path = filedialog.askopenfilename()
# Read in data and display first 5 rows
features = pd.read_csv('C:\\Users\\Spark\\Downloads\\Results.csv')
#features = pd.get_dummies(features)
features = features.drop('Date', axis = 1)
#features = features.drop('Seq', axis = 1)
print(features.shape)
print(features.describe())
print(features.head(5))
print(features['Seq'])
labels = np.array(features['Seq'])
#print(labels)
features= features.drop('Seq', axis = 1)
feature_list = list(features.columns)
features = np.array(features)
#print(features)
# Using Skicit-learn to split data into training and testing sets
from sklearn.model_selection import train_test_split
train_features, test_features, train_labels, test_labels = train_test_split(features, labels, test_size = 0.25, random_state = 42)
print('Training Features Shape:', train_features.shape)
print('Training Labels Shape:', train_labels.shape)
print('Testing Features Shape:', test_features.shape)
print('Testing Labels Shape:', test_labels.shape)
from sklearn.ensemble import RandomForestRegressor
rf = RandomForestRegressor(n_estimators = 1000, random_state = 42)
rf.fit(train_features, train_labels);
#print(rf)
# Use the forest's predict method on the test data
#predictions = rf.predict(test_features)
# Calculate the absolute errors
#errors = abs(predictions - test_labels)
# Print out the mean absolute error (mae)
#print('Mean Absolute Error:', round(np.mean(errors), 2), 'degrees.')
