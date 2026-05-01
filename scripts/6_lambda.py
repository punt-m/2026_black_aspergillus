import pandas as pd
import numpy as np
from scipy.stats import chi2
import glob
import os

# Find all gemma output files in current directory
files = glob.glob("*.assoc.txt")

if not files:
    print("No .assoc.txt files found in the current directory.")
else:
    # Header
    print(f"{'File Name':<35} | {'Lambda':<10} | {'Status'}")
    print("-" * 60)

    for file in sorted(files):
        try:
            # Read only p_wald to save memory
            df = pd.read_csv(file, sep='\t', usecols=['p_wald'])
            p_values = df['p_wald'].dropna()
            
            # Filter out p-values that are exactly 0 or 1 to avoid infinity in ppf
            p_values = p_values[(p_values > 0) & (p_values < 1)]
            
            # Calculate Chi-squared stats
            chisq = chi2.ppf(1 - p_values, df=1)
            
            # Calculate Lambda
            # Expected median for chi2 with 1 df is qchisq(0.5, 1) = 0.4549364
            lambda_val = np.median(chisq) / 0.4549364
            
            # Determine status
            if lambda_val < 0.9:
                status = "Deflated (Too Strict)"
            elif lambda_val > 1.1:
                status = "Inflated (Structure/Noise)"
            else:
                status = "Good"
            
            # The Fixed Format Specifier: {value:alignment_width.precision_f}
            print(f"{file:<35} | {lambda_val:<10.4f} | {status}")
            
        except Exception as e:
            print(f"Error processing {file}: {e}")