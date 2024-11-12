# Model Building for Logistic Regression: Purposeful Selection
 
## Project Overview
This project aims to build a logistic regression model to determine the factors associated with timely complementary feeding, using data from the Performance Monitoring for Action (PMA) project. The dataset includes demographic and socioeconomic characteristics, feeding practices, and nutritional status indicators for mothers and children.

The data was cleaned using Stata before being imported into R for further analysis and model building.

## Dataset
- **Data Source**: PMA Project data, `CF_timely.dta`
- **Observations**: 3,466
- **Variables**: 17

### Key Variables
- **Outcome Variable**: `timely_CF` (binary), where 0 = timely, 1 = untimely.
- **Independent Variables**: Include maternal age, marital status, education, employment status, parity, wealth quintile, residency type, county of residence, minimum dietary diversity (MDD) score, food insecurity, and nutritional status.

## Analysis Workflow
The modeling process follows **purposeful selection** to identify variables associated with timely complementary feeding.

### Steps
1. **Load Libraries**
   - `haven`: For importing `.dta` files.
   - `lmtest`: For likelihood ratio tests.
   - `ResourceSelection`: For assessing logistic model fit with the Hosmer-Lemeshow test.

2. **Data Import**
   - Import the cleaned `.dta` dataset (`CF_timely.dta`) from Stata.

3. **Univariable Analysis**
   - Each variable is individually tested against `timely_CF` using logistic regression.
   - Variables with p-values < 0.25 are considered for inclusion in the multivariable model.

4. **Multivariable Model Comparison**
   - Multiple models are built and compared:
     - **Model 1**: Contains selected variables based on univariable analysis.
     - **Model 2**: Includes all variables.
     - **Model 3**: Significant variables from Model 1 are retained.

5. **Assess Linearity Assumption**
   - No continuous variables are included, so this step is skipped.

6. **Check Interactions Between Covariates**
   - Tests for potential interactions, specifically between `mddscores` and `food_insecurity`, based on clinical assumptions.

7. **Model Fit Assessment**
   - Hosmer-Lemeshow Goodness-of-Fit (GoF) test is used to evaluate model fit.
   - A jitter plot visualizes the predicted probabilities versus the observed outcomes.

8. **Odds Ratios Calculation**
   - The odds ratios for the model coefficients are calculated to interpret the association between independent variables and the likelihood of timely feeding.

## Code Usage
- **Set Seed**: `set.seed(794)` ensures reproducibility.
- **Run Models**: Use `glm()` function for logistic regression, followed by `summary()` for model diagnostics.
- **Odds Ratio Calculation**: `exp(coef(model1))` gives the odds ratios for each variable.

### Example Code Snippets
```r
# Importing Data
CF <- read_dta("CF_timely.dta")

# Univariable Analysis
model1 <- glm(CF$timely_CF ~ CF$education, family = binomial)
summary(model1)

# Calculate Odds Ratios for Model 1
odds_ratios <- exp(coef(model1))
print(odds_ratios)
```

### Visualizations
- **Jitter Plot**: Displays predicted probabilities against the observed outcomes.
- **ROC Plot**: Plots the ROC curve to assess the model's discriminative ability.

### Additional Notes
- The Hosmer-Lemeshow test is applied to check model fit.
- `lrtest()` function is used to test for significant interactions.

## Dependencies
Ensure the following R packages are installed:
- `haven`
- `lmtest`
- `ResourceSelection`
- `lattice`
- `Deducer`
- `ggplot2`

## Conclusion
The analysis identifies significant predictors of timely complementary feeding. The final model provides insights into socio-economic and demographic factors affecting feeding practices, supporting interventions for timely feeding practices in the studied population.