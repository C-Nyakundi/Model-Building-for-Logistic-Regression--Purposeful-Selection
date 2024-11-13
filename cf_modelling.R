## Model Building for logistic regression: Purposeful selection

#- Using data from PMA, we are going to build a model to determine factors associated with timely complementary feeding
#- Data cleaning has already been done in STATA
#- Outcome variable (binary) timely_CF [0- timely, 1-Untimely]
#- Independent variables - age, sex, parity, MDD, Nutrition status, employment status, education level....

#- Loading important libraries
library(haven)
library(lmtest) # Used to perform likelihood ratio tests, often to compare two nested models to see if adding variables significantly improves the fit
library(ResourceSelection) # Used to evaluate the fit of logistic regression models, specifically implementing Hosmer-lemeshow GoF test
library(dplyr)
set.seed(794) # Setting random seed to ensure reliability & reproducibility of the results 


##- Step one- Importing the dta data set in our working directory 

CF <- read_dta("CF_timely.dta")

names(CF)
#- (3,466 observations, 17 Variables)
#- Indpendent variables - "maternalage", "marstat", "education", "employstat", "births", "wealth_quintile", "resident", 
#-                        "countyofresidence_nairobi" "mddscores" ,"food_insecurity","ebf",  "nutrition_status"         

summary(CF)

## Removing missing observations from the data frame to ensure stability of the model
CF = na.omit(CF)
count(CF)
## Complete case analysis of 3,154 observations (312 observations dropped)


##- Step two-  Uni variable Analysis (to explore the un-adjusted association between variables and outcome)
#           - We aim to select variables with p-value < 0.25 for the next model
#- Maternal age
univariable.maternal_age <- glm(CF$timely_CF~CF$maternalage, family = binomial)
summary(univariable.maternal_age)
#  p-value 0.589 | co-eff = -0.043

#- Marital Status 
univariable.marital_status <- glm(CF$timely_CF~CF$marstat, family = binomial)
summary(univariable.marital_status)
# p-value = 0.581 | co-eff = -0.048

#- Education level
univariable.education_level <- glm(CF$timely_CF~CF$education, family = binomial)
summary(univariable.education_level)
# p-value < 0.001 | co-eff = -0.249 (for every unit increase in education, the odds of CF decrease by 0.249)
# Null deviance: 4588.3- This is the deviance (a measure of goodness-of-fit) of a model with no predictors (just the intercept).
# Residual deviance: 4553.3- This is the deviance after including CF$education in the model. The smaller the residual deviance, the better the model fits the data compared to the null model.

# Employment status 
univariable.employment_status <- glm(CF$timely_CF~CF$employstat, family = binomial)
summary(univariable.employment_status)
# p-value = 0.797 | co-eff = -0.021

# Parity
univariable.parity <- glm(CF$timely_CF~CF$births, family = binomial)
summary(univariable.parity)
# p-value < 0.001 | co-eff = -0.298

# Wealth quintile
univariable.wealth_quintile <- glm(CF$timely_CF~CF$wealth_quintile, family = binomial)
summary(univariable.wealth_quintile)
# p-value < 0.001 | co-eff = 0.273

# Residency 
univariable.residency <- glm(CF$timely_CF~CF$resident, family = binomial)
summary(univariable.residency)
# p-value <0.001 | co-eff = -0.479

# County 
univariable.county <- glm(CF$timely_CF~CF$countyofresidence_nairobi, family = binomial)
summary(univariable.county)
# p-value < 0.001 | co-eff = -0.044

#Mdd score
univariable.mdd_score <- glm(CF$timely_CF~CF$mddscores, family = binomial)
summary(univariable.mdd_score)
# p-value <0.01 | co-eff = -0.444

#Food Insecurity 
univariable.food_insecure <- glm(CF$timely_CF~CF$food_insecurity, family = binomial)
summary(univariable.food_insecure)
# p-value <0.001 | co-eff =0.274



# The above code can be optimized into;
# Define the variables to include in the univariable analysis
variables <- c("maternalage", "marstat", "education", "employstat", 
               "births", "wealth_quintile", "resident", 
               "countyofresidence_nairobi", "mddscores", "food_insecurity")

# Loop through each variable to perform univariable logistic regression and output the summary
for (var in variables) {
  formula <- as.formula(paste("CF$timely_CF ~ CF$", var, sep = "")) #This concatenates "CF$timely_CF ~ CF$" with the variable name to build a formula string like "CF$timely_CF ~ CF$maternalage".
                                                                    #as.formula(): Converts this string into an actual formula object that can be used in the regression model.
  model <- glm(formula, family = binomial)
  print(summary(model))
}


## Step 3- Multivariable Model Comparisons
# Variable of a P value of smaller than 0.25 and other variables of known clinical relevance can be included for further multivariable analysis
model1 <- glm(CF$timely_CF~CF$education+CF$births+CF$wealth_quintile+CF$resident+CF$countyofresidence_nairobi+CF$mddscores+CF$food_insecurity, family = binomial)
summary(model1)

# Model-2 All variables 
model2 <- glm(CF$timely_CF~CF$maternalage+CF$marstat+CF$education+CF$employstat+CF$births+CF$wealth_quintile+CF$resident+CF$countyofresidence_nairobi+CF$mddscores+CF$food_insecurity, family = binomial)
summary(model2)

# Model-3 Significant variables from the multivariable analysis
model3 <- glm(CF$timely_CF~CF$employstat+CF$births+CF$wealth_quintile+CF$mddscores, family = binomial)
summary(model3)

# All var in Model 3 are statistically significant. We will compare the change in coefficient for each variable remaining in model 3
#If a change of coefficients (Δβ) is more than 20%, then deleted variables have provided important adjustment of the effect of remaining variables. Such variables should be added back to the model.
# Extracting the coefficients from both models 
coef_model1 <- coef(model1)
coef_model2 <- coef(model2)
coef_model3 <- coef(model3)

# Getting the names of vars used in model3
model3_vars <- names(coef_model3)

#Filter coef_model2 to include only the variable present in model3 
filtered_coef_model2 <- coef_model2[model3_vars]


delta.coef <- abs((coef_model3-filtered_coef_model2)/filtered_coef_model2) # The fn coef() extracts estimated coefficients from fitted models
round(delta.coef,3)
#The result shows that the two models are not significantly different in their fits for data


## Alternative two- Using analysis of Variance (ANOVA) to explore the difference between models
anova(model1, model2, model3, test = "Chisq") 
## Check for more info in the Model evaluation file

## Step -3 : Assessing for linearity Assumption
# In this step we check for linearity assumption for continuous variables, however our data set doesn't include any continuous variables


## Step-4 : Interactions among covariates 
# We will be check for potential interactions between covariates (An interaction between two variable shows that the effect of one variable on response is dependent on another variable)
# Interactions pairs can be started from a clinical perspective, e.g. we assume there is interaction between mddscores & food_insecurity
# The effects of mdd_score on timely CF is somewhat dependent on food_insecurity 
model.interactions <- glm(CF$timely_CF~CF$maternalage+CF$marstat+CF$education+CF$employstat+CF$births+CF$wealth_quintile+CF$resident+CF$countyofresidence_nairobi+CF$mddscores+CF$food_insecurity+CF$mddscores:CF$food_insecurity, data = CF, family = binomial)
summary(model.interactions)
# Assessing for the interaction in the first model - (Model with significant variables from bivariate analysis)
model.interactions1 <- glm(CF$timely_CF~CF$education+CF$employstat+CF$births+CF$wealth_quintile+CF$resident+CF$countyofresidence_nairobi+CF$mddscores+CF$food_insecurity+CF$mddscores:CF$food_insecurity, data = CF, family = binomial)
summary(model.interactions1)

lrtest(model3, model.interactions1)
#The results show that the P value for interaction term is 0.52, which is far away from significance level.
#When the model with interaction term is compared to the preliminary main effects model, there is no difference.

## Step-5: Assessing fit of the model
#- There are two methods for checking model fit 1. Summary measures of GOF
#                                               2. Regression diagnostics 
# We will use summary of GOF, specifically Hosmer-Lemeshow test to measure the difference between observed & fitted values
###- HL test is used to assess whether a logistic regression model is appropriately fitting the data, especially in cases where binary outcomes are modeled (such as predicting presence/absence, success/failure, etc.).
###- A significant result from the test suggests that the model does not fit the data well, while a non-significant result suggests a good fit.
hoslem.test(model1$y, fitted(model1))
#The P value is 0.06, indicating that there is no significant difference between observed and predicted values. 


### Model fit can also be examined by graphics
## Jitter plot
Predprob <- predict(model1, type = "response") # Predict probabilities from the model

#Checking the predprob & CF$timely_CF are the same length 
length(Predprob)
length(CF$timely_CF)

# Extract the response variable from the model's original data
outcome_var <- model1$y
# Check that outcome_var and Predprob have the same length now
length(Predprob) == length(outcome_var) # This should return TRUE


# Plot with jitter applied to the consistent outcome variable
plot(
  Predprob, 
  jitter(as.numeric(outcome_var), 0.5), # Adding jitter to make binary values more visible
  cex = 0.5,                            # Setting point size
  ylab = "Jittered Timely CF Outcome"   # Setting y-axis label
)

## Histogram 
# Plot the histogram using lattice
library(lattice)
# Convert outcome_var to factor if it's binary
outcome_var <- factor(outcome_var)
histogram(~ Predprob|outcome_var, main = "Histogram of Predicted Probabilities by Outcome",
          xlab = "Predicted Probability")

histogram(~ Predprob | outcome_var, main = "Histogram of Predicted Probabilities by Outcome",
          xlab = "Predicted Probability", layout = c(1, 2))

## Receiver Operating Characteristics & Area under the curve 
# Load the package
library(pROC)

# Generate predicted probabilities from your model
Predprob <- predict(model1, type = "response")

# Create the ROC curve
roc_curve <- roc(model1$y, Predprob)

# Plot the ROC curve
plot(roc_curve, main = "ROC Curve for Model 1", col = "red")

# Obtain the AUC
auc_value <- auc(roc_curve)

# Print the AUC
print(auc_value)
## AUC - 0.62 has low predictive power

## Obtaining odds ratios from the model1
model1 <- glm(CF$timely_CF~CF$education+CF$employstat+CF$births+CF$wealth_quintile+CF$resident+CF$countyofresidence_nairobi+CF$mddscores+CF$food_insecurity, family = binomial)

# Getting the odds ration by exponentiating the coeffecients
odds_ratios <-exp(coef(model1))
print(odds_ratios)
