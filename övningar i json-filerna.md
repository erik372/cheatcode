# Övningar i JSON-filerna

## Filstruktur

Varje avsnitt som har övningar har en tillhörande JSON-fil i mappen `exercises/`. Filnamnet matchar avsnittets ID, t.ex. `exercises/k2-2-3.json` för avsnitt `k2-2-3`.

Varje JSON-fil är en array av övningsobjekt:

```json
[
  { ...övning 1... },
  { ...övning 2... },
  ...
]
```

## Fält i varje övningsobjekt

| Fält | Typ | Beskrivning |
|---|---|---|
| `id` | sträng | Unikt ID för övningen, t.ex. `"k2-2-3-001"` |
| `name` | sträng | Visningsnamn, t.ex. `"Uppgift 1"` |
| `exercise` | sträng | Uppgiftstext i HTML. Matematik skrivs med LaTeX-notation: `\\( ... \\)` för inline-formler |
| `image` | sträng eller null | Sökväg till bild om uppgiften har en, annars `null` |
| `inputtype` | sträng | Antingen `"button"` (flervalsfråga) eller `"field"` (fritextinmatning) |
| `answerformat` | sträng | Beskrivning av förväntat svarsformat, visas som ledtråd för studenten |
| `error.message` | sträng | Feedback som visas vid fel svar |
| `correct.message` | sträng | Feedback som visas vid rätt svar |

## Typ 1: Flervalsfråga (`inputtype: "button"`)

Har fältet `multichoice` med ett eller flera frågobjekt (vanligtvis `q1`):

```json
"multichoice": {
  "q1": {
    "label": "Vad är svaret?",
    "options": ["Alt A", "Alt B", "Alt C"],
    "correct": "Alt B"
  }
}
```

- `label`: frågans rubrik
- `options`: array med svarsalternativ (strängar)
- `correct`: det korrekta alternativet (måste matcha exakt ett värde i `options`)

## Typ 2: Fritextinmatning (`inputtype: "field"`)

Har fältet `expectedanswer` med ett objekt där nyckeln är fältets etikett och värdet är det förväntade svaret:

```json
"expectedanswer": {
  "Svar": "1.667"
}
```

Stöder flera delfrågor med separata fält, t.ex. `{"a": "3", "b": "5"}`.

## Hur övningarna laddas på webbsidan

I varje Rmd-fil som ska ha övningar finns ett R-kodblock som:

1. Läser JSON-filen
2. Injicerar övningsdata som ett JavaScript-objekt i sidan (`window.exerciseData`)
3. Lägger in en platshållar-div som JavaScript-koden sedan renderar

```r
local({
  path <- file.path("exercises/k2-2-3.json")
  if (file.exists(path)) {
    json <- paste(readLines(path, encoding="UTF-8", warn=FALSE), collapse="")
    cat(sprintf(
      '<script>window.exerciseData=window.exerciseData||{};window.exerciseData["%s"]=%s;</script>\n',
      "k2-2-3", json
    ))
    cat('<div class="exercise-section" data-section-id="k2-2-3"></div>\n')
  }
})
```

- Nyckeln i `window.exerciseData` är avsnittets ID (t.ex. `"k2-2-3"`)
- `data-section-id`-attributet på div:en måste matcha samma ID
- JavaScript-koden på sidan hittar div:en via `data-section-id` och renderar övningarna

## Sammanfattning av konventioner

- Ett JSON-fält per avsnitt, namngett efter avsnittets ID
- Övnings-ID:n följer mönstret `[avsnitt-id]-[tresiffrigt nummer]`, t.ex. `k2-2-3-001`
- HTML och LaTeX-matematik (`\\( ... \\)`) kan användas i `exercise`, `error.message` och `correct.message`
- Rätt svar jämförs som sträng — decimaltecken är punkt, inte komma
