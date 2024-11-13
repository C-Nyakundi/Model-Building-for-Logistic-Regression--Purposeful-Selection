# Model Building for Logistic Regression: Purposeful Selection

## Project Overview
This project develops a logistic regression model to identify factors associated with timely complementary feeding, utilizing data from the Performance Monitoring for Action (PMA) project. The dataset includes demographic, socioeconomic, and nutrition-related characteristics for mothers and children. Data cleaning was initially conducted in Stata, and R was used for the analysis and model building.

## Dataset
- **Data Source**: PMA Project data, `CF_timely.dta`
- **Observations**: 3,466 initially (3,154 after removing missing data)
- **Variables**: 17

### Key Variables
- **Outcome Variable**: `timely_CF` (binary), where 0 = timely and 1 = untimely.
- **Independent Variables**: Maternal age, marital status, education, employment status, parity, wealth quintile, residency type, county of residence, minimum dietary diversity (MDD) score, food insecurity, and nutritional status.

## Analysis Workflow
The analysis uses **purposeful selection** to identify variables associated with timely complementary feeding, proceeding through univariable analysis, multivariable comparisons, interaction testing, and model fit assessments.

### Steps

1. **Load Libraries**
   - **Primary**: `haven` for data import, `lmtest` for likelihood ratio testing, `ResourceSelection` for logistic model goodness-of-fit testing.
   - **Additional**: `dplyr` for data manipulation, `lattice` for plotting.

2. **Data Import**
   - Import the cleaned dataset (`CF_timely.dta`) from Stata.

3. **Data Cleaning**
   - Conduct complete-case analysis, removing missing observations to stabilize model results. Final dataset includes 3,154 observations.

4. **Univariable Analysis**
   - Conduct logistic regression for each independent variable with `timely_CF` as the outcome. Variables with a p-value < 0.25 are selected for multivariable analysis.

5. **Multivariable Model Comparison**
   - Three models are built and compared:
     - **Model 1**: Includes variables identified through univariable analysis.
     - **Model 2**: Contains all potential predictors.
     - **Model 3**: Retains only significant variables from Model 1 for a more parsimonious model.
   - **Comparison**: The difference in coefficients between models is examined, and an ANOVA test compares model fit.

6. **Linearity Assumption Check**
   - As there are no continuous variables, linearity testing is skipped.

7. **Interaction Testing**
   - Interaction between `mddscores` and `food_insecurity` is assessed based on clinical relevance to understand if dietary diversity impacts feeding practices differently under varying levels of food insecurity. The likelihood ratio test (`lrtest()`) indicates no significant interaction.

8. **Model Fit Assessment**
   - The Hosmer-Lemeshow Goodness-of-Fit (GoF) test assesses model fit. A p-value > 0.05 suggests an adequate fit between observed and predicted values.
   - A jitter plot of predicted probabilities is created to visualize model predictions against observed outcomes.

9. **Odds Ratios Calculation**
   - Calculated for model coefficients using `exp(coef())`, providing interpretability for each predictor’s association with timely feeding.

### Code Usage

- **Setting Seed**: Ensures reproducibility.
- **Logistic Regression**: `glm()` function is used for model building, with `summary()` for diagnostics.
- **Odds Ratios**: Calculated using `exp(coef())`.

### Key Code Snippets
```r
# Import Data
CF <- read_dta("CF_timely.dta")

# Univariable Analysis Example
model_education <- glm(CF$timely_CF ~ CF$education, family = binomial)
summary(model_education)

# Odds Ratios for Model 1
odds_ratios <- exp(coef(model1))
print(odds_ratios)
```

### Visualizations
- **Jitter Plot**: Shows predicted probabilities against actual outcomes, using `jitter()` to make binary outcomes visible.
- **ROC Curve**: Displays the ROC curve, with AUC calculated using the `pROC` package to assess the model's predictive ability.

### Model Diagnostics
- **Hosmer-Lemeshow Test**: Evaluates the fit of the final model.
- **Likelihood Ratio Test**: Used for checking interaction significance.

## Dependencies
Ensure the following R packages are installed:
- `haven`
- `lmtest`
- `ResourceSelection`
- `dplyr`
- `lattice`
- `pROC`

## Conclusion
The model identifies key predictors of timely complementary feeding, shedding light on socioeconomic and demographic influences. Results from this analysis may support targeted interventions for timely feeding practices within the population studied.