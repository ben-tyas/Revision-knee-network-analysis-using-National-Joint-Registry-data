# Revision Knee Network analysis

Stata code used to clean and analyse National Joint Registry (NJR) data for the Revision Knee Network report.

## Software

The analysis was developed for **Stata 19.0**. The supplied do-files use official Stata commands, including the `collect`, `table`, `export excel`, and `putexcel` frameworks; no user-written packages are required by the uploaded code.

## Repository structure

```text
.
├── 00_master.do
├── code/
│   ├── 01_clean_data.do
│   ├── 02_surgeon_volumes.do
│   ├── 03_overall_numbers.do
│   ├── 04_unit_volumes_2024_2025.do
│   ├── 05_procedure_types.do
│   ├── 06_procedure_types_septic_elective.do
│   ├── 07_indications.do
│   ├── 08_rkcc.do
│   ├── 09_complexity_by_network.do
│   ├── 10_mdt_discussion.do
│   ├── 11_low_volume_units.do
│   └── helpers/
│       ├── trust_labels.do
│       └── hospital_labels.do
├── data/
│   ├── raw/
│   └── derived/
├── output/
│   ├── tables/
│   └── logs/
└── archive/
```

## Data availability

The patient-level NJR data used for this analysis are **not included in this repository**. Access to NJR data is subject to the relevant data-access approvals and governance requirements. Users with authorised access should place the source dataset at:

```text
data/raw/Raw data.dta
```

No patient-level data should be committed to the public repository.

## Running the analysis

1. Clone or download the repository.
2. Place the authorised source dataset in `data/raw/Raw data.dta`.
3. Open Stata and set the working directory to the **repository root**.
4. Run:

```stata
do "00_master.do"
```

The master do-file defines portable project paths, creates the required output directories, and runs the analysis scripts in sequence.

## Analysis workflow

| File | Purpose |
|---|---|
| `01_clean_data.do` | Cleans the raw extract; derives hospital, trust, network, MRC, procedure, indication, RKCC, PIES and MDT variables; saves the analysis dataset. |
| `02_surgeon_volumes.do` | Calculates annual surgeon-volume metrics nationally and by network. |
| `03_overall_numbers.do` | Produces annual procedure counts by network, trust and hospital. |
| `04_unit_volumes_2024_2025.do` | Summarises unit activity for prespecified 2024–2025 case categories. |
| `05_procedure_types.do` | Summarises procedure types by MRC status and network. |
| `06_procedure_types_septic_elective.do` | Produces the corresponding procedure-type analysis for septic elective cases. |
| `07_indications.do` | Summarises indications for revision. |
| `08_rkcc.do` | Summarises RKCC grade. |
| `09_complexity_by_network.do` | Summarises case-complexity measures by network. |
| `10_mdt_discussion.do` | Summarises local and regional/infection MDT discussion. |
| `11_low_volume_units.do` | Identifies trusts and hospitals with fewer than 20 revisions in each of 2023, 2024 and 2025. |

## Disclosure control

The analytical code generates raw tabulations. Disclosure-control/small-number suppression should be applied to any outputs before public dissemination in accordance with the applicable NJR data-governance requirements. In the published report, cell counts of 1–4 are displayed as `<5`; where a single suppressed cell would otherwise be recoverable from a subtotal or total, the displayed subtotal/total is based only on visible counts and is marked with an asterisk.

## Notes

- Local machine-specific paths have been removed from the public version of the code.
- Superseded versions of scripts supplied during code preparation are retained in `archive/` for provenance but are not run by `00_master.do`.
- `hospital_labels.do` is retained as a reference/helper file. The current cleaning script generates hospital codes by encoding `HospitalName`; it directly calls only `trust_labels.do`.
