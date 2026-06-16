-- ============================================================
-- Project Stay | Nexora Group
-- People Analytics Investigation — Final SQL Script
-- Reconciled Against Final Power BI Dashboard
-- Analyst: People Analytics Specialist
-- Database: project_stay
-- ============================================================

USE project_stay;


-- ============================================================
-- Stage 1: Workforce Overview
-- Purpose: Establish the baseline before the investigation begins.
-- Covers the Executive Workforce Risk Overview dashboard (Page 1)
-- ============================================================

-- Total headcount -- the starting point for everything
SELECT COUNT(*) AS total_employees FROM employees;

-- Active vs resigned split with percentage breakdown
-- This feeds the attrition rate and retention rate KPI cards on Page 1
SELECT employment_status,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees), 1) AS percentage
FROM employees
GROUP BY employment_status;

-- Headcount by department showing active and resigned side by side
-- Feeds the "which departments are losing talent" chart on Page 1
SELECT department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN employment_status = 'resigned' THEN 1 ELSE 0 END) AS resigned,
    SUM(CASE WHEN employment_status = 'active' THEN 1 ELSE 0 END) AS active
FROM employees
GROUP BY department
ORDER BY total_employees DESC;


-- ============================================================
-- Stage 2: Attrition Analysis
-- Purpose: Identify where and among whom the talent collapse
-- is most severe. Covers Page 1 charts directly.
-- ============================================================

-- Attrition rate per department
-- Technology and Operations stand out significantly here
SELECT department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN employment_status = 'resigned' THEN 1 ELSE 0 END) AS resigned_count,
    ROUND(SUM(CASE WHEN employment_status = 'resigned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_rate_pct
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- High performers who resigned by department
-- This is the core finding -- are we losing the best people?
SELECT e.department,
    COUNT(*) AS high_performer_exits
FROM employees e
JOIN performance p ON e.employee_id = p.employee_id
WHERE p.performance_rating = 'High' AND e.employment_status = 'resigned'
GROUP BY e.department
ORDER BY high_performer_exits DESC;

-- Attrition by job level -- feeds the "which job levels are walking out" chart on Page 1
SELECT job_level,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN employment_status = 'resigned' THEN 1 ELSE 0 END) AS resigned_count,
    ROUND(SUM(CASE WHEN employment_status = 'resigned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_rate_pct
FROM employees
GROUP BY job_level
ORDER BY attrition_rate_pct DESC;

-- Average tenure of resigned employees by performance rating
-- Testing the 6-18 month exit pattern from the brief
SELECT p.performance_rating,
    ROUND(AVG(e.years_at_company), 1) AS avg_tenure_years,
    COUNT(*) AS total_resigned
FROM employees e
JOIN performance p ON e.employee_id = p.employee_id
WHERE e.employment_status = 'resigned'
GROUP BY p.performance_rating
ORDER BY avg_tenure_years ASC;

-- Resignation trend by year
-- exit_date is stored as varchar so extracting year using substring
-- The rise from 2018 to 2023 then drop in 2024 tells the full collapse story
SELECT
    SUBSTRING(exit_date, 1, 4) AS resignation_year,
    COUNT(*) AS total_resignations,
    SUM(CASE WHEN department = 'technology' THEN 1 ELSE 0 END) AS technology,
    SUM(CASE WHEN department = 'operations' THEN 1 ELSE 0 END) AS operations,
    SUM(CASE WHEN department = 'sales' THEN 1 ELSE 0 END) AS sales,
    SUM(CASE WHEN department = 'finance' THEN 1 ELSE 0 END) AS finance,
    SUM(CASE WHEN department = 'human resources' THEN 1 ELSE 0 END) AS human_resources,
    SUM(CASE WHEN department = 'customer service' THEN 1 ELSE 0 END) AS customer_service
FROM employees
WHERE employment_status = 'resigned'
  AND exit_date IS NOT NULL AND exit_date != ''
GROUP BY resignation_year
ORDER BY resignation_year ASC;


-- ============================================================
-- Stage 3: Burnout Intelligence
-- Purpose: Prove that structural overload is psychologically
-- exhausting the workforce. Covers Page 2 charts.
-- ============================================================

-- Average burnout score alongside overtime and weekly hours by department
-- Technology at 7.4 and Operations at 7.2 confirm the structural exhaustion argument
SELECT e.department,
    ROUND(AVG(w.burnout_score), 1) AS avg_burnout_score,
    ROUND(AVG(w.overtime_hours), 1) AS avg_overtime_hours,
    ROUND(AVG(w.weekly_hours), 1) AS avg_weekly_hours
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
GROUP BY e.department
ORDER BY avg_burnout_score DESC;

-- Overtime vs burnout direct correlation by department
SELECT e.department,
    ROUND(AVG(w.overtime_hours), 1) AS avg_overtime,
    ROUND(AVG(w.burnout_score), 1) AS avg_burnout
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
GROUP BY e.department
ORDER BY avg_burnout DESC;

-- Burnout by job level -- added to Page 2 after dashboard review
-- Checking whether seniority increases burnout risk
SELECT e.job_level,
    ROUND(AVG(w.burnout_score), 1) AS avg_burnout,
    ROUND(AVG(w.overtime_hours), 1) AS avg_overtime,
    COUNT(*) AS employee_count
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
GROUP BY e.job_level
ORDER BY avg_burnout DESC;

-- High productivity vs high burnout by department
-- This is the hidden toxic high performance trap the brief describes
SELECT e.department,
    ROUND(AVG(a.productivity_score), 1) AS avg_productivity,
    ROUND(AVG(w.burnout_score), 1) AS avg_burnout
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
JOIN attendance_productivity a ON e.employee_id = a.employee_id
GROUP BY e.department
ORDER BY avg_burnout DESC;

-- Weekend work frequency by department
SELECT e.department, COUNT(*) AS employee_count
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
WHERE w.weekend_work_frequency IN ('Sometimes', 'Always')
GROUP BY e.department
ORDER BY employee_count DESC;

-- Meeting hours vs productivity score
-- Is excessive meeting culture undermining employee productivity?
SELECT e.department,
    ROUND(AVG(w.meeting_hours), 1) AS avg_meeting_hours,
    ROUND(AVG(a.productivity_score), 1) AS avg_productivity_score
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
JOIN attendance_productivity a ON e.employee_id = a.employee_id
GROUP BY e.department
ORDER BY avg_meeting_hours DESC;


-- ============================================================
-- Stage 4: Quiet Quitting Analysis
-- Purpose: Surface employees who are emotionally disengaging
-- before submitting resignation. Covers Page 4 charts.
-- ============================================================

-- Active employees who have already signaled intention to leave
-- Sorted by lowest satisfaction -- these are the most urgent cases
SELECT e.employee_id, e.full_name, e.department, e.manager_name,
    s.satisfaction_level, s.intention_to_leave, s.emotional_state, s.career_growth_score
FROM employees e
JOIN engagement_survey s ON e.employee_id = s.employee_id
WHERE s.intention_to_leave = 'Yes' AND e.employment_status = 'active'
ORDER BY s.satisfaction_level ASC;

-- Low satisfaction employees concentrated by department
SELECT e.department,
    COUNT(*) AS low_satisfaction_count,
    ROUND(AVG(s.satisfaction_level), 1) AS avg_satisfaction,
    ROUND(AVG(s.career_growth_score), 1) AS avg_career_growth,
    ROUND(AVG(s.recognition_score), 1) AS avg_recognition
FROM employees e
JOIN engagement_survey s ON e.employee_id = s.employee_id
WHERE s.satisfaction_level <= 4 AND e.employment_status = 'active'
GROUP BY e.department
ORDER BY low_satisfaction_count DESC;

-- Recognition score comparison between resigned and active employees
-- Resigned employees consistently score lower on recognition -- this is not coincidental
SELECT e.employment_status,
    ROUND(AVG(s.recognition_score), 1) AS avg_recognition_score,
    ROUND(AVG(s.satisfaction_level), 1) AS avg_satisfaction,
    COUNT(*) AS employee_count
FROM employees e
JOIN engagement_survey s ON e.employee_id = s.employee_id
GROUP BY e.employment_status
ORDER BY avg_recognition_score ASC;

-- Does limited career growth predict resignation intention?
SELECT s.intention_to_leave,
    ROUND(AVG(s.career_growth_score), 1) AS avg_career_growth,
    ROUND(AVG(s.satisfaction_level), 1) AS avg_satisfaction,
    COUNT(*) AS employee_count
FROM engagement_survey s
JOIN employees e ON s.employee_id = e.employee_id
WHERE e.employment_status = 'active'
GROUP BY s.intention_to_leave
ORDER BY avg_career_growth ASC;

-- Emotional state distribution across the company
-- Feeds the "what is the current emotional health of the workforce" donut chart on Page 4
SELECT emotional_state,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM engagement_survey), 1) AS percentage
FROM engagement_survey
GROUP BY emotional_state
ORDER BY employee_count DESC;

-- Disengagement levels broken down by department
SELECT e.department,
    SUM(CASE WHEN s.emotional_state = 'Burned Out' THEN 1 ELSE 0 END) AS burned_out,
    SUM(CASE WHEN s.emotional_state = 'Disengaged' THEN 1 ELSE 0 END) AS disengaged,
    SUM(CASE WHEN s.emotional_state = 'Engaged' THEN 1 ELSE 0 END) AS engaged
FROM employees e
JOIN engagement_survey s ON e.employee_id = s.employee_id
GROUP BY e.department
ORDER BY disengaged DESC;

-- Recognition score by department
-- Technology and Operations show lowest recognition -- directly connected to their high attrition
SELECT e.department,
    ROUND(AVG(s.recognition_score), 1) AS avg_recognition_score
FROM employees e
JOIN engagement_survey s ON e.employee_id = s.employee_id
GROUP BY e.department
ORDER BY avg_recognition_score ASC;


-- ============================================================
-- Stage 5: Leadership And Toxicity
-- Purpose: Name the managers driving the silent talent collapse
-- and quantify the damage of toxic leadership. Covers Page 3.
-- ============================================================

-- Managers with the most resignations under them
-- Amina Yusuf at 28 resignations is the standout finding here
SELECT e.manager_id, e.manager_name,
    COUNT(*) AS resignation_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE employment_status = 'resigned'), 1) AS pct_of_total_resignations
FROM employees e
WHERE e.employment_status = 'resigned'
GROUP BY e.manager_id, e.manager_name
ORDER BY resignation_count DESC;

-- Leadership style breakdown with effectiveness, safety scores and turnover rates
SELECT m.leadership_style,
    COUNT(*) AS employee_count,
    ROUND(AVG(m.manager_effectiveness), 1) AS avg_effectiveness,
    ROUND(AVG(m.psychological_safety_score), 1) AS avg_psych_safety,
    ROUND(AVG(m.team_turnover_rate), 2) AS avg_turnover_rate
FROM manager_feedback m
GROUP BY m.leadership_style
ORDER BY avg_turnover_rate DESC;

-- Psychological safety scores by manager
-- Feeds the "which managers are creating unsafe environments" table on Page 3
SELECT e.manager_name,
    ROUND(AVG(m.psychological_safety_score), 1) AS avg_safety_score,
    ROUND(AVG(m.conflict_incidents), 1) AS avg_conflicts,
    ROUND(AVG(m.manager_effectiveness), 1) AS avg_effectiveness
FROM employees e
JOIN manager_feedback m ON e.employee_id = m.employee_id
GROUP BY e.manager_name
ORDER BY avg_safety_score ASC;

-- Manager effectiveness vs team turnover
-- Low effectiveness managers cluster toward high turnover
SELECT m.manager_effectiveness, COUNT(*) AS employee_count
FROM manager_feedback m
JOIN employees e ON m.employee_id = e.employee_id
WHERE e.employment_status = 'resigned'
GROUP BY m.manager_effectiveness
ORDER BY m.manager_effectiveness ASC;

-- Promotion fairness analysis by department and performance rating
-- Testing whether high performers are being promoted at a fair rate
SELECT e.department, p.performance_rating,
    SUM(CASE WHEN p.promotion_status = 'Yes' THEN 1 ELSE 0 END) AS promoted_count,
    COUNT(*) AS total_employees,
    ROUND(SUM(CASE WHEN p.promotion_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS promotion_rate_pct
FROM employees e
JOIN performance p ON e.employee_id = p.employee_id
GROUP BY e.department, p.performance_rating
ORDER BY e.department, promotion_rate_pct DESC;

-- Which managers never acknowledge their people?
SELECT e.manager_name,
    COUNT(*) AS employee_count,
    SUM(CASE WHEN m.recognition_frequency IN ('Never', 'Rarely') THEN 1 ELSE 0 END) AS low_recognition_count
FROM employees e
JOIN manager_feedback m ON e.employee_id = m.employee_id
GROUP BY e.manager_name
ORDER BY low_recognition_count DESC;


-- ============================================================
-- Stage 6: Financial Impact
-- Purpose: Translate the human crisis into financial language
-- for the CFO and Board. Covers Page 5 charts.
-- ============================================================

-- Turnover cost per department -- hiring, training and productivity loss breakdown
SELECT r.department, r.hiring_cost, r.training_cost, r.productivity_loss_cost,
    (r.hiring_cost + r.training_cost + r.productivity_loss_cost) AS total_cost_per_cycle,
    COUNT(e.employee_id) AS total_resignations,
    (r.hiring_cost + r.training_cost + r.productivity_loss_cost) * COUNT(e.employee_id) AS estimated_total_loss
FROM recruitment_cost r
LEFT JOIN employees e ON r.department = e.department AND e.employment_status = 'resigned'
GROUP BY r.department, r.hiring_cost, r.training_cost, r.productivity_loss_cost
ORDER BY estimated_total_loss DESC;

-- Average cost per hire and replacement time by department
SELECT department, hiring_cost, training_cost,
    replacement_time_days, vacancy_duration,
    ROUND((hiring_cost + training_cost) / 2, 0) AS avg_cost_per_hire
FROM recruitment_cost
ORDER BY avg_cost_per_hire DESC;

-- Total organizational financial loss -- the headline number for the CEO
-- 11M total loss is the single most important output of this investigation
SELECT
    SUM((r.hiring_cost + r.training_cost + r.productivity_loss_cost) * resigned_counts.total_resignations) AS total_organizational_loss,
    SUM(resigned_counts.total_resignations) AS total_resignations,
    ROUND(
        SUM((r.hiring_cost + r.training_cost + r.productivity_loss_cost) * resigned_counts.total_resignations)
        / SUM(resigned_counts.total_resignations), 0
    ) AS avg_cost_per_resignation
FROM recruitment_cost r
JOIN (
    SELECT department, COUNT(*) AS total_resignations
    FROM employees
    WHERE employment_status = 'resigned'
    GROUP BY department
) AS resigned_counts ON r.department = resigned_counts.department;

-- Are departments with more resignations spending more on recruitment reactively?
SELECT e.department, COUNT(*) AS total_resignations, r.hiring_cost
FROM employees e
JOIN recruitment_cost r ON e.department = r.department
WHERE e.employment_status = 'resigned'
GROUP BY e.department, r.hiring_cost
ORDER BY total_resignations DESC;

-- Financial cost of attrition trend by year
-- exit_date is stored as varchar so extracting year using substring
SELECT SUBSTRING(e.exit_date, 1, 4) AS exit_year,
    COUNT(*) AS total_resignations,
    ROUND(COUNT(*) * AVG(r.hiring_cost + r.training_cost + r.productivity_loss_cost), 0) AS estimated_annual_loss
FROM employees e
JOIN recruitment_cost r ON e.department = r.department
WHERE e.employment_status = 'resigned'
  AND e.exit_date IS NOT NULL AND e.exit_date != ''
GROUP BY exit_year
ORDER BY exit_year ASC;


-- ============================================================
-- Stage 7: Correlation Segmentation
-- Purpose: Go deeper than surface level analysis to find the
-- specific combinations driving the collapse
-- ============================================================

-- Burnout segmented by job level and department
SELECT e.department, e.job_level,
    ROUND(AVG(w.burnout_score), 1) AS avg_burnout,
    ROUND(AVG(w.overtime_hours), 1) AS avg_overtime,
    COUNT(*) AS employee_count
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
GROUP BY e.department, e.job_level
ORDER BY avg_burnout DESC;

-- Are high performers actually less satisfied than everyone else?
SELECT p.performance_rating,
    ROUND(AVG(s.satisfaction_level), 1) AS avg_satisfaction,
    ROUND(AVG(s.recognition_score), 1) AS avg_recognition,
    ROUND(AVG(s.career_growth_score), 1) AS avg_career_growth,
    ROUND(AVG(s.work_life_balance), 1) AS avg_work_life_balance,
    COUNT(*) AS employee_count
FROM performance p
JOIN engagement_survey s ON p.employee_id = s.employee_id
GROUP BY p.performance_rating
ORDER BY avg_satisfaction ASC;


-- ============================================================
-- Stage 8: Advanced Workforce Intelligence
-- Purpose: The most powerful output of the entire investigation.
-- Covers the Predictive Workforce Risk Centre on Page 6.
-- ============================================================

-- Silent flight risk watchlist
-- Active employees who have not resigned yet but show every signal of someone about to
-- This is the most actionable output of the entire Project Stay investigation
--
-- Flight Risk Score Methodology:
-- Burnout >= 7        = 25 points (strongest single predictor)
-- Intention to leave  = 25 points (direct resignation signal from the employee)
-- Satisfaction <= 4   = 20 points (emotional disengagement confirmed)
-- Overtime >= 15      = 10 points (overload amplifier)
-- Career growth <= 4  = 10 points (stagnation driver)
-- Recognition <= 4    = 10 points (invisibility trigger)
-- Maximum score       = 100 points
--
-- Risk Bands:
-- 0-30   Stable
-- 31-55  Monitor
-- 56-75  At Risk
-- 76-100 Critical -- Immediate Intervention Required

-- Using a CTE to calculate the flight risk score once and reuse it for the band label
-- Avoids repeating the full scoring logic twice inside the same query
WITH flight_risk_base AS (
    SELECT
        e.employee_id, e.full_name, e.department, e.job_level,
        e.manager_name, e.monthly_salary,
        w.burnout_score, w.overtime_hours,
        s.satisfaction_level, s.career_growth_score, s.recognition_score,
        s.intention_to_leave, s.emotional_state,
        a.productivity_score, a.absence_days,
        (
            CASE WHEN w.burnout_score >= 7 THEN 25 ELSE 0 END +
            CASE WHEN s.intention_to_leave = 'Yes' THEN 25 ELSE 0 END +
            CASE WHEN s.satisfaction_level <= 4 THEN 20 ELSE 0 END +
            CASE WHEN w.overtime_hours >= 15 THEN 10 ELSE 0 END +
            CASE WHEN s.career_growth_score <= 4 THEN 10 ELSE 0 END +
            CASE WHEN s.recognition_score <= 4 THEN 10 ELSE 0 END
        ) AS flight_risk_score
    FROM employees e
    JOIN workload w ON e.employee_id = w.employee_id
    JOIN engagement_survey s ON e.employee_id = s.employee_id
    JOIN attendance_productivity a ON e.employee_id = a.employee_id
    WHERE e.employment_status = 'active'
)
SELECT *,
    CASE
        WHEN flight_risk_score >= 76 THEN 'Critical'
        WHEN flight_risk_score >= 56 THEN 'At Risk'
        WHEN flight_risk_score >= 31 THEN 'Monitor'
        ELSE 'Stable'
    END AS risk_band
FROM flight_risk_base
ORDER BY flight_risk_score DESC;


-- ============================================================
-- End Of Project Stay SQL Investigation
-- Nexora Group | People Analytics Division
-- ============================================================

-- ============================================================
-- Additional Queries — Reconciled From Final Dashboard Review
-- These queries were identified as missing during the final
-- chart-by-chart comparison against all 6 dashboard pages
-- ============================================================

-- Page 1: How healthy is the Nexora Group workforce?
-- Clustered bar showing avg burnout level, attrition rate and avg satisfaction by department
SELECT e.department,
    ROUND(AVG(w.burnout_score), 1) AS avg_burnout_level,
    ROUND(SUM(CASE WHEN e.employment_status = 'resigned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_rate,
    ROUND(AVG(s.satisfaction_level), 1) AS workforce_satisfaction
FROM employees e
JOIN workload w ON e.employee_id = w.employee_id
JOIN engagement_survey s ON e.employee_id = s.employee_id
GROUP BY e.department
ORDER BY avg_burnout_level DESC;

-- Page 6: What is the financial exposure of our highest risk departments?
-- Calculates estimated loss if all critical risk employees in each department resign
-- Technology at 2.96M and Operations at 2.80M
SELECT e.department,
    COUNT(*) AS critical_risk_employees,
    ROUND(COUNT(*) * AVG(r.hiring_cost + r.training_cost + r.productivity_loss_cost) / 1000000, 2) AS estimated_exposure_millions
FROM employees e
JOIN recruitment_cost r ON e.department = r.department
JOIN workload w ON e.employee_id = w.employee_id
JOIN engagement_survey s ON e.employee_id = s.employee_id
WHERE e.employment_status = 'active'
  AND (
      CASE WHEN w.burnout_score >= 7 THEN 25 ELSE 0 END +
      CASE WHEN s.intention_to_leave = 'Yes' THEN 25 ELSE 0 END +
      CASE WHEN s.satisfaction_level <= 4 THEN 20 ELSE 0 END +
      CASE WHEN w.overtime_hours >= 15 THEN 10 ELSE 0 END +
      CASE WHEN s.career_growth_score <= 4 THEN 10 ELSE 0 END +
      CASE WHEN s.recognition_score <= 4 THEN 10 ELSE 0 END
  ) >= 76
GROUP BY e.department
ORDER BY estimated_exposure_millions DESC;

-- ============================================================
-- End Of Additional Queries
-- ============================================================
