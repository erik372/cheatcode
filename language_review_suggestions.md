# Language Review — Major Suggestions (Not Applied)

These are errors that are uncertain or require changing more than ~3 words. They have NOT been applied to the files.

---

## Change #9 — 03-examples-applications.Rmd / Income index (line 340)

**Find:** `the 10 percent riches household each year`
**Replace:** `the 10 percent richest households each year`
**Reason:** 'riches' should be the superlative 'richest'; 'household' should be plural 'households' to match subject. Two word changes needed.

---

## Change #11 — 03-examples-applications.Rmd / Economic growth (line 426)

**Find:** `\text{GDP growt in year }` (inside display math block)
**Replace:** `\text{GDP growth in year }`
**Reason:** Typo 'growt' missing final 'h', but the error is inside a `$$...$$` display math block (`\text{}` label). Per rules, math block content must not be altered.

---

## Change #12 — 04-functions-graphs.Rmd / Linear equations (line 521)

**Find:** `\text{Condtion 2: }` (inside display math block)
**Replace:** `\text{Condition 2: }`
**Reason:** Typo 'Condtion' should be 'Condition', but the error is inside a `$$...$$` display math block. Per rules, math block content must not be altered.

---

## Change #16 — 05-logarithms.Rmd / Log GDP (line 528)

**Find:** `$e^{-0.7}\approx-0.486$`
**Replace:** `$e^{-0.7}\approx0.486$`
**Reason:** Mathematical error: $e^{-0.7} \approx 0.497$, which is positive, not negative. The minus sign before 0.486 is incorrect. This is inside inline math — classifying as major because it is a mathematical content correction, not a spelling or grammar issue.

---

## Change #19 — 07-systems-linear-equations.Rmd / Linear system (line 224)

**Find:** `Since the two equations is the same the has an infinite number of solutions.`
**Replace:** `Since the two equations are the same, the system has an infinite number of solutions.`
**Reason:** Multiple errors: subject-verb agreement ('is' should be 'are'), missing comma, and garbled text ('the has' should be 'the system has'). More than 3 words need to change.
