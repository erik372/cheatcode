# Ändringslogg – PDF-anpassningar

Dokumenterar varje ändring av projektfiler. Syfte: möjliggöra återställning om
något går fel i HTML-boken.

---

## Nya filer (kan raderas utan konsekvens för boken)

| Fil | Syfte |
|-----|-------|
| `fix_one_chapter.R` | R-skript som processar ett kapitel i taget |
| `fix_exercises_for_pdf.R` | Tidigare version av skriptet (ej använt) |
| `pdf-changes-log.md` | Den här filen |

---

## Ändringar i befintliga filer

### `preamble.tex`
**Vad:** Lade till en rad:
```latex
\newcommand{\permil}{\text{‰}}
```
**Varför:** `\permil` (promilletecknet ‰) saknade definition och kraschade PDF-bygget.  
**Påverkar HTML:** Nej. `preamble.tex` inkluderas aldrig i HTML-bygget.  
**Återställ:** Ta bort den tillagda raden.

---

### `02-basics.Rmd`
**Vad:** Övningsblocket (tidigare rad 1587–1636) fick två tillägg:

1. Ett R-chunk *före* HTML-blocket:
```r
```{r 02_basics_ex_1_pdf, echo=FALSE, results='asis'}
if (knitr::is_latex_output()) {
  # ... övningsdata kopierad från JavaScript ...
}
```
```
Chunken körs bara i PDF-läge (`is_latex_output()`). I HTML-läge körs den men
producerar ingen output.

2. HTML-blocket inlindat med `{=html}`-wrapper:
```
```{=html}
<div id="ex-1" ...></div>
<script>...</script>
```
```
`{=html}`-block passeras igenom oförändrade av pandoc i HTML-läge.

**Påverkar HTML:** Potentiellt ja – om knitr eller pandoc hanterar `{=html}`-blocket
annorlunda än råa HTML-rader. I praktiken ska det vara identiskt, men det är
inte 100% garanterat utan test.  
**Visuellt kontrollerat:** Ja – HTML-boken kontrollerades lokalt och såg korrekt ut.  
**Återställ:** Ta bort R-chunken och `{=html}`/` ``` `-raderna (behåll det
ursprungliga HTML-blocket som det var).

---

### `06-polynomial-equations.Rmd`
**Vad:** I en markdown-tabell (Tabell: Derivation of the quadratic formula),
rad 392–403: bytte `\begin{align*}` / `\end{align*}` till
`\begin{aligned}` / `\end{aligned}` i två tabellceller.

**Varför:** `align*` inuti en markdown-tabellcell kraschade PDF-bygget med felet
"Forbidden control sequence found while scanning use of \align*".
`aligned` är en nästlad matematik-miljö som fungerar inuti `$$...$$` i tabellceller.

**Påverkar HTML:** Troligen inte – MathJax renderar `$$\begin{aligned}...\end{aligned}$$`
och `$$\begin{align*}...\end{align*}$$` visuellt identiskt i detta sammanhang.
MEN detta är ett antagande som inte är 100% verifierat.  
**Visuellt kontrollerat:** Nej – HTML-boken har inte kontrollerats efter denna
ändring ännu.  
**Återställ:** Byt tillbaka `aligned` → `align*` i de två tabellcellerna.

---

## Status

| Kapitel | Övningar klara | HTML ok | PDF ok |
|---------|---------------|---------|--------|
| 02-basics | ✅ | ✅ (manuellt) | ⏳ bygger |
| 03–33 | ❌ | – | – |

**Pre-existerande LaTeX-fel åtgärdade (blockerade PDF oavsett övningar):**
- `\permil` saknad definition → fixad i `preamble.tex`
- `align*` i tabellcell → fixad i `06-polynomial-equations.Rmd`
- Dubbel `\label` för `eq:pq-formeln` → fixad i `06-polynomial-equations.Rmd`

---

### `06-polynomial-equations.Rmd` (tredje ändringen – Tabell 6.1)
**Vad:** Tabell 6.1 (Derivation of the quadratic formula) omstrukturerades från
3 kolumner till 2 kolumner (8 rader inkl. rubrikrad). Rubrikraden fick fetstil
(`**In general**` | `**Our example**`). Alla 16 celler i den nya tabellen fylldes
med innehåll – den tomma cell nr 16 i den felaktiga tabellen (rad 6, kol 1) togs bort
och innehållet arrangerades om i logisk härledningsordning.

Gammal ordning (3 kol): raderna blandade allmän formel och specifikt exempel.  
Ny ordning (2 kol): vänster kolumn = allmänt, höger kolumn = specifikt exempel,
rad för rad genom hela härledningen.

**Påverkar HTML:** Ja – tabellstrukturen ändras. Bör ge ett bättre och korrektare
resultat även i HTML. Ej visuellt kontrollerat ännu.  
**Visuellt kontrollerat:** Nej – ännu inte.  
**Återställ:** Se git diff för `06-polynomial-equations.Rmd` runt rad 388–406.

---

### `12-theories-cake-monopoly.Rmd`
**Vad:** Ekvationsetiketten `(\#eq:monopol-efterfragekurvan)` låg på en egen rad
inuti ett `align`-block. Bookdown satte då `\label` på flera rader → LaTeX-fel
"Multiple \label's". Etiketten flyttades till slutet av första ekvationsraden.

Före:
```
\text{Demand: }Q & =20-\frac{P}{5}\\
\Rightarrow P & =100-2Q\nonumber 
 (\#eq:monopol-efterfragekurvan)
```
Efter:
```
\text{Demand: }Q & =20-\frac{P}{5} (\#eq:monopol-efterfragekurvan)\\
\Rightarrow P & =100-2Q\nonumber
```

**Påverkar HTML:** Troligen inte – ekvationsnumreringen bör vara identisk.  
**Återställ:** Flytta etiketten tillbaka till egen rad.

---

### `06-polynomial-equations.Rmd` (andra ändringen)
**Vad:** Ekvationsetiketten `(\#eq:pq-formeln)` låg på en egen rad (rad 383)
inuti ett `align`-block. Bookdown satte då `\label` på flera rader → LaTeX-fel
"Multiple \label's". Etiketten flyttades till slutet av ekvationsrad 381.

Före:
```
x^{*} & =-\frac{p}{2}\pm\sqrt{...}\\
\text{where }p & =\frac{b}{a}...\nonumber
 (\#eq:pq-formeln)
```
Efter:
```
x^{*} & =-\frac{p}{2}\pm\sqrt{...} (\#eq:pq-formeln)\\
\text{where }p & =\frac{b}{a}...\nonumber
```

**Påverkar HTML:** Troligen inte – ekvationsnumreringen bör vara identisk.
Antagande, ej visuellt verifierat.  
**Återställ:** Flytta `(\#eq:pq-formeln)` tillbaka till egen rad efter `\nonumber`-raden.
