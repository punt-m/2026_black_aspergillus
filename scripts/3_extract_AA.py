import sys
import subprocess
import collections
import re
from tqdm import tqdm

def run_extraction(vcf_path, gene_name, AA_adjust):
    aa_map = {'Ala':'A', 'Arg':'R', 'Asn':'N', 'Asp':'D', 'Cys':'C', 'Gln':'Q', 'Glu':'E', 
              'Gly':'G', 'His':'H', 'Ile':'I', 'Leu':'L', 'Lys':'K', 'Met':'M', 'Phe':'F', 
              'Pro':'P', 'Ser':'S', 'Thr':'T', 'Trp':'W', 'Tyr':'Y', 'Val':'V', 'Ter':'*'}

    def get_aa_pos(aa_str):
        """Helper to extract the numeric position for proper ascending sort."""
        match = re.search(r'\d+', aa_str)
        return int(match.group()) if match else 0

    def clean_aa(aa_str):
        clean = aa_str.replace('p.', '')
        for three, one in aa_map.items():
            clean = clean.replace(three, one)
        
        match = re.match(r"([A-Z*]+)(\d+)([A-Z*?]+)", clean)
        if match:
            prefix, pos_str, suffix = match.groups()
            new_pos = int(pos_str) - int(AA_adjust)
            if new_pos > 0:
                return f"{prefix}{new_pos}{suffix}"
        return None

    # 1. Get full sample list
    sample_list_cmd = f"bcftools query -l {vcf_path}"
    sample_proc = subprocess.run(sample_list_cmd, shell=True, capture_output=True, text=True)
    all_samples = sample_proc.stdout.strip().split('\n')
    data = {s: set() for s in all_samples}

    # 2. Extract variant data
    cmd = f"bcftools query -f '[%SAMPLE\t%GT\t%ALT\t%ANN\n]' {vcf_path} | grep {gene_name}"
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)
    
    for line in tqdm(proc.stdout, desc=f"Processing {gene_name}"):
        parts = line.strip().split('\t')
        if len(parts) < 4: continue
        sample, gt_str, alt_field, ann_field = parts[0], parts[1], parts[2], parts[3]

        if gt_str in ['0', '0/0', '0|0', '.', './.', '.|.']:
            continue

        try:
            gt_alleles = re.split(r'[/|]', gt_str)
            gt_idx = int(next(a for a in gt_alleles if a != '0' and a != '.'))
        except (StopIteration, ValueError):
            continue

        alts = alt_field.split(',')
        if gt_idx > len(alts): continue
        chosen_alt = alts[gt_idx - 1]

        for ann in ann_field.split(','):
            f = ann.split('|')
            if f[0] == chosen_alt and len(f) > 10 and f[4] == gene_name and "missense_variant" in f[1]:
                adjusted = clean_aa(f[10])
                if adjusted:
                    data[sample].add(adjusted)

   # 3. Grouping and Mapping Logic
    profile_groups = collections.defaultdict(list)
    for s in all_samples:
        sorted_muts = sorted(list(data[s]), key=get_aa_pos)
        profile_key = ','.join(sorted_muts) if sorted_muts else 'REFERENCE'
        profile_groups[profile_key].append(s)

    # Define the fixed mappings (your "known" variants)
    fixed_mapping = {
        'REFERENCE': 'WT',
        'A9V,L21F,T321A,I503V': 'v1',
        'M218I': 'v2',
        'L4F,A185G': 'v3',
        'V17A': 'v4',
        'G509E': 'v5',
        'E32K,T321A': 'v6',
        'None': 'v7'
    }

    final_results = []
    remaining_profiles = {}

    # Track which specific 'v' numbers we have already used
    used_v_numbers = set()

    for variants, strains in profile_groups.items():
        if variants in fixed_mapping:
            label = fixed_mapping[variants]
            final_results.append({
                'label': label,
                'count': len(strains),
                'variants': variants,
                'strains': ', '.join(strains)
            })
            # If the label is like 'v1', 'v2', extract the number
            if label.startswith('v'):
                used_v_numbers.add(int(label.replace('v', '')))
        else:
            remaining_profiles[variants] = strains

    # Determine the next available 'v' number
    # If used_v_numbers is empty, start at 1. Otherwise, start after the highest.
    next_v = max(used_v_numbers) + 1 if used_v_numbers else 1

    # Sort remaining by group size (descending)
    sorted_remaining = sorted(remaining_profiles.items(), key=lambda x: len(x[1]), reverse=True)
    
    for variants, strains in sorted_remaining:
        final_results.append({
            'label': f"v{next_v}",
            'count': len(strains),
            'variants': variants,
            'strains': ', '.join(strains)
        })
        next_v += 1

    # 4. Print Summary
    print("\n" + "="*80)
    print(f"{'Group':<10}\t{'Count':<8}\t{'AA Substitutions (Ascending)':<30}\t{'Strains'}")
    print("-" * 80)

    def sort_output_label(item):
        label = item['label']
        if label == 'WT': return 0
        return int(label.replace('v', ''))

    for row in sorted(final_results, key=sort_output_label):
        print(f"{row['label']:<10}\t{row['count']:<8}\t{row['variants']:<30}\t{row['strains']}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 extract_aa.py <vcf_path> <gene_name> <AA_adjust>")
    else:
        run_extraction(sys.argv[1], sys.argv[2], sys.argv[3])
