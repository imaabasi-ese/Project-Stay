# Project Stay: People Analytics Intelligence Report
### Nexora Group | Confidential Workforce Investigation


## The Problem Nobody Was Talking About

Nexora Group had every reason to feel confident.

Salaries were competitive. Recruitment numbers were strong. Training budgets grew every year. On paper, the company was doing everything right.

But underneath the surface, something was quietly breaking.

The best employees kept leaving. Not loudly. Not in groups. One by one, usually right after a training cycle or a promotion window, they submitted their resignations and walked out the door.

Weaker employees stayed. Productivity declined. Managers became overwhelmed. Projects slowed. Recruitment costs exploded.

Leadership had theories. Gen Z attitudes. Competitors poaching talent. Remote work culture. Salary expectations. Every explanation pointed outward.

None of them looked inward.

An internal investigation eventually uncovered what the data had been trying to say all along. **The company's own structure was psychologically exhausting its highest performers.** The people Nexora Group was investing in the most were the ones it was losing the fastest.

The CEO launched an emergency initiative called **Project Stay.**

I was brought in as the People Analytics Specialist to investigate, diagnose, and present findings to leadership.


## The Hidden Problems

Before any data was touched, the investigation brief identified the structural issues suspected to be driving the collapse. Top performers were receiving more workload without additional support. Toxic managers were retaining power because of strong business results. Burnout was being disguised as high commitment. Employees were trapped in repetitive roles after completing training cycles. Promotion favoritism was undermining trust. Poor recognition systems were making high performers feel invisible. Excessive meeting hours were reducing time for meaningful work. And HR remained focused on hiring metrics rather than retention intelligence.

The investigation was designed to test each of these claims with data.


## Tools and Approach

| Tool | Role In The Investigation |
|---|---|
| MySQL | Data storage, cleaning and all SQL analysis |
| Power BI | Dashboard design and executive reporting |
| Power Query | Data transformation and date handling |
| DAX | Calculated measures and predictive scoring |

The dataset covered 500 employees across 6 departments and 5 branches in Nigeria, spanning 7 related tables: Employees, Performance, Workload, Engagement Survey, Manager Feedback, Attendance Productivity, and Recruitment Cost.

The investigation ran across 8 analytical stages covering workforce overview, attrition analysis, burnout intelligence, quiet quitting patterns, leadership toxicity, financial impact, correlation segmentation, and predictive risk scoring.


## Key Findings

**Finding 1: The Talent Collapse Is Real and Structural**

Overall attrition stood at **36.6%**, already alarming on its own. But the high performer attrition rate told a more disturbing story at **72.3%**. For every 10 high performers Nexora Group hired, 7 had already resigned. This was not random turnover. The best people were leaving at twice the rate of everyone else. The company was not just shrinking. It was selecting for mediocrity.

**Finding 2: Technology and Operations Were in Collapse**

Attrition in Technology reached **59%**. Operations followed at **49%**. These two departments were responsible for the bulk of resignations, the highest burnout scores, and the greatest financial damage. Both showed a pattern that became central to the investigation. High productivity was sitting alongside critical burnout. They looked successful from the outside while quietly destroying their people from the inside.

**Finding 3: Overwork Was the Structural Mechanism**

Technology employees averaged **17.1 overtime hours** per week alongside a burnout score of **7.4 out of 10**. Finance, by contrast, averaged **4.1 overtime hours** and a burnout score of **2.7**. The relationship was consistent across every department. Where overtime went up, burnout followed. This was not a coincidence. It was a structural pattern built into how these departments operated.

**Finding 4: Four Managers Were Driving the Exits**

Amina Yusuf had **28 resignations** under her management, the highest of any manager in the company. The top four managers by resignation count were all operating under a Toxic leadership style, characterised by low psychological safety scores, high conflict incidents, and near-zero recognition frequency. Toxic managers averaged a burnout score of **7.3** across their teams compared to **2.9** under Supportive managers. Certain managers were systematically destroying the people working under them while their business results kept them protected.

**Finding 5: Emotional Disengagement Preceded Every Resignation**

**37.39%** of active employees expressed intention to leave in their most recent engagement survey. **16.51%** were already classified as Disengaged and **3.44%** as Burned Out. Employees in these states showed satisfaction scores below 4, career growth scores below 4, and recognition scores among the lowest in the company. Their emotional departure was measurably complete long before their formal resignation.

**Finding 6: The Financial Damage Was ₦10.94 Million and Growing**

The total estimated organizational loss from attrition reached **₦10.94 million**, driven primarily by Technology at ₦2.47M and Operations at ₦2.15M. The financial cost escalated consistently from 2018 through 2023, peaking at ₦0.88M in annual losses. Every resignation carried a cost of recruitment, training, and productivity loss. When those costs were multiplied across 183 resigned employees, the financial argument for retention investment became impossible to ignore.

**Finding 7: 31 Employees Were About to Resign**

The most powerful output of the investigation was the Silent Flight Risk Watchlist, a scoring system that assigned each active employee a Flight Risk Score based on six weighted variables: burnout level, intention to leave, satisfaction level, overtime hours, career growth score, and recognition score. **31 employees scored in the Critical band (76-100 points)**, meaning every major risk signal had been triggered simultaneously. **92 employees were classified At Risk.** The estimated financial exposure if Critical employees resigned was **₦1.85 million.** Amina Yusuf appeared again, this time as the manager responsible for the most at-risk employees. The investigation had found not just where the problem was, but who owned it.


## Recommendations

The investigation did not end with findings. It ended with a clear action plan for leadership.

HR should initiate one-on-one retention conversations with every employee scoring 76 or above on the Flight Risk Score within 30 days. The watchlist provides names, departments, and managers. The work of identification has already been done.

Amina Yusuf, Chukwuemeka Obi, Ngozi Eze, and Tunde Adeyemi collectively account for a disproportionate share of resignations and at-risk employees. Their continued unchecked authority represents the single greatest structural risk to workforce stability. Leadership development, performance improvement plans, or reassignment should be considered immediately.

Overtime hours in Technology and Operations are not a temporary spike. They are an embedded operational pattern. Sustainable workload distribution, additional headcount, or reduced project scope should be evaluated. The current model is producing strong output at the cost of the people delivering it.

Technology and Operations reported the lowest recognition scores in the company. Structured recognition frameworks, not informal appreciation, should be implemented in Q1. Recognition has a direct measurable relationship with retention in this dataset.

Promotion rates varied significantly across departments and performance levels. High performers in certain departments were being promoted at a lower rate than average performers in others. A transparent, criteria-based promotion framework would directly address the trust deficit identified in the engagement surveys.


## Dashboard Overview

The Project Stay dashboard was built in Power BI across 6 pages, each designed to answer a specific executive question.

| Page | Title | Question |
|---|---|---|
| 1 | Executive Workforce Risk Overview | How bad is the talent collapse? |
| 2 | Burnout and Workload Intelligence | Is the company overworking its people to the point of collapse? |
| 3 | Manager Impact Analysis | Which managers are driving the exits? |
| 4 | Employee Emotional Engagement | How long have employees been disengaging before resigning? |
| 5 | Financial Impact and Workforce Cost Intelligence | How much money has this crisis cost the organization? |
| 6 | Predictive Workforce Risk Centre | Who is about to resign next? |


## Project Files

| File | Description |
|---|---|
| `ProjectStay_SQL_Scripts_Cleaned.sql` | Complete SQL investigation across 8 stages, reconciled against the final dashboard |
| `ProjectStay_HR_Dataset.xlsx` | Source dataset with 7 tables and 4986 rows, synthetically generated with intentional correlations |


## Technical Notes

The data model follows a star schema with Employees as the central fact table connected to 6 dimension tables via Employee_ID and Department keys.

The Flight Risk Score is a rule-based scoring system using six weighted variables: Burnout Score (25pts), Intention To Leave (25pts), Satisfaction Level (20pts), Overtime Hours (10pts), Career Growth Score (10pts), and Recognition Score (10pts). Maximum score is 100. Risk bands are Stable (0-30), Monitor (31-55), At Risk (56-75), and Critical (76-100).

The dataset was synthetically generated for portfolio purposes using Python, with intentional correlations built in to reflect the Project Stay brief. All company names, employee names, and financial figures are fictional.


## About This Project

Project Stay was built as part of a three-project data analytics portfolio targeting international and remote People Analytics roles. It demonstrates SQL investigation across 8 analytical stages, Power BI dashboard design across 6 executive pages, DAX measure engineering, star schema data modeling, and the ability to translate a complex human problem into a structured data-driven investigation.

The goal was never to build a dashboard. The goal was to diagnose an organizational collapse and present findings in a way that drives executive action.


*Nexora Group is a fictional company created for portfolio purposes.*
*Project Stay | People Analytics Intelligence Report | 2024*
